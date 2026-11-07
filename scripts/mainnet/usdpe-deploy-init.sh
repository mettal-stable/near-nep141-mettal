#!/bin/bash

# Get the absolute path where this script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# make it relative to cwd
SCRIPT_DIR=$(realpath --relative-to="$PWD" "$SCRIPT_DIR")
echo "Script directory: $SCRIPT_DIR"
# get common functions
. "$SCRIPT_DIR/../common/deploy_functions.sh"
# Run main function
deploy_stablecoin_contract mainnet "$SCRIPT_DIR/usdpe.config.mainnet.json"
