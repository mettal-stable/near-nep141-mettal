#!/bin/bash
set -ex

# Function to cleanup sandbox processes
cleanup_sandbox() {
    echo "Cleaning up sandbox processes..."
    # Kill processes by name
    pkill -f near-sandbox 2>/dev/null || true
    # Kill processes listening on sandbox ports
    kill $(lsof -ti:3030,4000,9001 2>/dev/null) 2>/dev/null || true
    echo "Sandbox cleanup completed."
}

# Set trap to cleanup on script exit
trap cleanup_sandbox EXIT INT TERM

# Check if sandbox connection already exists
if near config show-connections 2>&1 | grep -q "network_connection.sandbox"; then
    echo "Sandbox connection already exists, skipping creation..."
else
    echo "Creating sandbox connection..."
    near config add-connection \
        --network-name sandbox --connection-name sandbox \
        --rpc-url http://localhost:3030/ \
        --wallet-url http://localhost:4000/wallet \
        --explorer-transaction-url http://localhost:9001/transactions/ \
        --linkdrop-account-id test.near \
        --faucet-url http://localhost:3030/faucet
fi

# Start NEAR sandbox from clean state
SANDBOX_HOME=~/.near-sandbox
rm -rf $SANDBOX_HOME
SANDBOX_BINARY=~/.npm-global/bin/near-sandbox
$SANDBOX_BINARY --home $SANDBOX_HOME localnet -v 1
$SANDBOX_BINARY --home $SANDBOX_HOME init
$SANDBOX_BINARY --home $SANDBOX_HOME run &

# Wait for sandbox to be ready
sleep 10

# copy testnet keys
mkdir -p ~/.near-credentials/sandbox/
cp -u ~/.near-credentials/testnet/*mettal* ~/.near-credentials/sandbox/

wait
