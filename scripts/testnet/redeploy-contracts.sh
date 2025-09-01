NETWORK="testnet"
# deploy and init functions
. ./scripts/common/deploy_functions.sh
# Deploy code only for PSLD contract
deploy_stablecoin_contract $NETWORK ./scripts/$NETWORK/psld.config.$NETWORK.json --only-deploy
# Deploy code only for MXND contract
deploy_stablecoin_contract $NETWORK ./scripts/$NETWORK/mxnd.config.$NETWORK.json --only-deploy
