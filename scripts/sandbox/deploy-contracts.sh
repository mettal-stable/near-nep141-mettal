#!/bin/bash

# get sandbox master account credentials
cp -u ~/.near-sandbox/validator_key.json ~/.near-credentials/sandbox/test.near.json
# replace "secret_key" in the json file with "private_key"
sed -i 's/secret_key/private_key/g' ~/.near-credentials/sandbox/test.near.json

# Function to create a sandbox account
create_sandbox_account() {
    local account_name="$1"
    local pubkey="$2"
    echo "Creating $account_name account..."
    near --quiet account create-account fund-myself "$account_name" "5 NEAR" \
        use-manually-provided-public-key "$pubkey" \
        sign-as test.near \
        network-config sandbox \
        sign-with-legacy-keychain \
        send
}

# Function to create a sandbox account from a testnet account
recreate_account_from_testnet() {
    local testnet_account_name="$1"
    local sandbox_account_name="$2"
    echo "Recreating $sandbox_account_name account from testnet..."
    # copy keys replacing the name
    sed "s/$testnet_account_name/$sandbox_account_name/g" \
         ~/.near-credentials/testnet/"$testnet_account_name".json > ~/.near-credentials/sandbox/"$sandbox_account_name".json
    # get the public key from the json file
    local pubkey=$(jq -r '.public_key' ~/.near-credentials/sandbox/"$sandbox_account_name".json)
    echo "Public key for $sandbox_account_name: $pubkey"
    create_sandbox_account "$sandbox_account_name" "$pubkey"
}

# Create accounts from testnet keys
recreate_account_from_testnet "mettal.testnet" "mettal.test.near"
recreate_account_from_testnet "issuer.mettal.testnet" "issuer.test.near"
recreate_account_from_testnet "activator.mettal.testnet" "activator.test.near"
recreate_account_from_testnet "mxnd.mettal.testnet" "mxnd-mettal.test.near"
recreate_account_from_testnet "penmt.mettal.testnet" "penmt-mettal.test.near"
recreate_account_from_testnet "usdpe.mettal.testnet" "usdpe-mettal.test.near"

# Create alice.test.near account with provided public key
create_sandbox_account "alice.test.near" "ed25519:42xXyToBjLXny1T725FhaV3sh9tTvUrKemsKmqfNQJa9"
# Save alice.test.near credentials to sandbox directory
cat > ~/.near-credentials/sandbox/alice.test.near.json <<EOF
{
    "account_id": "alice.test.near",
    "public_key": "ed25519:42xXyToBjLXny1T725FhaV3sh9tTvUrKemsKmqfNQJa9",
    "private_key": "ed25519:3chdKAwFNKALYVvTwtone21YhHP1dt4aEHzkBKGqT2dQe5g1Qz3q9vBt3iZWCpiMjKLULiKoBekWMxgKB63SbfSm",
    "seedPhrase": "custom scatter broccoli frost bridge guess magnet ticket space steak lecture magic"
}
EOF

# Create treasury.test.near account with provided public key
create_sandbox_account "treasury.test.near" "ed25519:BCjr7ufp6QuijEYzpwpUXr2ZFq1fY4sbmoX81zMWjbfd"
# Save treasury.test.near credentials to sandbox directory
cat > ~/.near-credentials/sandbox/treasury.test.near.json <<EOF
{
    "account_id": "treasury.test.near",
    "public_key": "ed25519:BCjr7ufp6QuijEYzpwpUXr2ZFq1fY4sbmoX81zMWjbfd",
    "private_key": "ed25519:5JVDDLHwCSnNXcxsrvuviMExtfiACy5DCwbV5Rx73qNxTnouqaqur6pJJi6UkwdJMQ96MhDPQqwv7WwMSwr6fJns",
    "seedPhrase": "among cram grape brave teach swift early erode crisp chair paddle copy"
}
EOF



# deploy and init functions
. ./scripts/common/deploy_functions.sh
# Deploy & init PENMT token contract
deploy_stablecoin_contract sandbox ./scripts/sandbox/penmt.config.sandbox.json
# Deploy & init USDPE token contract
deploy_stablecoin_contract sandbox ./scripts/sandbox/usdpe.config.sandbox.json
# Deploy & init MXND token contract
deploy_stablecoin_contract sandbox ./scripts/sandbox/mxnd.config.sandbox.json

#
echo "----------------------------------"
echo "deploy sandbox contracts completed"
echo "----------------------------------"
