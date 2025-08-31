#!/bin/bash

cp -u ~/.near-sandbox/validator_key.json ~/.near-credentials/sandbox/test.near.json
# replace "secret_key" in the json file with "private_key"
sed -i 's/secret_key/private_key/g' ~/.near-credentials/sandbox/test.near.json

# Function to create a sandbox account
create_sandbox_account() {
    local account_name="$1"
    echo "Creating $account_name account..."
    near account create-account fund-myself "$account_name" "5 NEAR" \
        autogenerate-new-keypair \
        save-to-legacy-keychain \
        sign-as test.near \
        network-config sandbox \
        sign-with-legacy-keychain \
        send
}

# Create required accounts
create_sandbox_account "mettal.test.near"
create_sandbox_account "issuer.test.near"
create_sandbox_account "mxnd-mettal.test.near"
create_sandbox_account "psld-mettal.test.near"

# deploy and init functions
. ./scripts/common/deploy_functions.sh
# Deploy first contract (PSLD)
main sandbox ./scripts/sandbox/psld.config.sandbox.json
# Deploy second contract (MXND)
main sandbox ./scripts/sandbox/mxnd.config.sandbox.json
