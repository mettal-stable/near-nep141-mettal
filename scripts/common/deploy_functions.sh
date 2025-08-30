#!/bin/bash

# Mettal NEP-141 Token Contract Deployment Script
# This script deploys and initializes the Mettal token contract on NEAR

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to load configuration from JSON file
load_config() {
    local config_file=$1

    if [ ! -f "$config_file" ]; then
        log_error "Configuration file not found: $config_file"
        exit 1
    fi

    log_info "Loading configuration from: $config_file"

    # Read configuration values
    local network_in_config=$(jq -r '.network // "testnet"' "$config_file")
    # it should match $NETWORK
    if [ "$network_in_config" != "$NETWORK" ]; then
        log_error "Network in config ($network_in_config) does not match script argument ($NETWORK)"
        exit 1
    fi

    CONTRACT_ID=$(jq -r '.contractId // ""' "$config_file")
    WASM_PATH=$(jq -r '.wasmPath // ""' "$config_file")
    # Extract entire initArgs JSON object directly from config
    INIT_ARGS_JSON=$(jq -c '.initArgs' "$config_file")

    GAS=$(jq -r '.gas // "300"' "$config_file")

    log_success "Configuration loaded successfully"
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if near-cli is installed
    if ! command_exists near; then
        log_error "near-cli is not installed. Please install it first:"
        log_error "npm install -g near-cli"
        exit 1
    fi

    # Check if cargo-near is available (optional)
    if command_exists cargo-near; then
        log_info "cargo-near found"
    else
        log_warning "cargo-near not found. Make sure you have the WASM file ready."
    fi

    # Check if jq is installed for JSON processing
    if ! command_exists jq; then
        log_error "jq is not installed. Please install it:"
        log_error "Ubuntu/Debian: sudo apt-get install jq"
        log_error "macOS: brew install jq"
        exit 1
    fi

    log_success "Prerequisites check passed"
}


# Function to deploy contract
deploy_only() {

    log_info "Deploying contract to $CONTRACT_ID..."

    # Deploy the contract
    near contract deploy "$CONTRACT_ID" \
        use-file "$WASM_FILE" without-init-call \
        network-config "$NETWORK" \
        sign-with-keychain \
        send
}

# Function to deploy and initialize in one transaction
deploy_and_init() {

    log_info "Deploying and initializing contract: $CONTRACT_ID"

    # Use the entire initArgs JSON directly from config
    log_info "Initialization arguments:"
    echo "$INIT_ARGS_JSON" | jq .

    # Deploy and initialize in one transaction
    log_info "Deploying contract with initialization..."
    local deploy_init_output
    echo "$INIT_ARGS_JSON" | \
        near contract deploy "$CONTRACT_ID" use-file "$WASM_PATH" \
        with-init-call new json-args "$(cat)" \
        prepaid-gas "$GAS Tgas" \
        attached-deposit '0 NEAR' \
        network-config $NETWORK \
        sign-with-keychain \
        send
}

# Function to show usage
show_usage() {
    cat << EOF
Mettal NEP-141 Token Contract Deployment Script

USAGE:
    $0 <NETWORK> <CONFIG_FILE>

DESCRIPTION:
    This script deploys and initializes the Mettal NEP-141 token contract on NEAR.
    All deployment parameters must be specified in a JSON configuration file.

OPTIONS:
    --only-deploy               Deploy and initialize separately (for debugging)
    -h, --help                  Show this help message

CONFIG FILE:
    All deployment parameters must be specified in a JSON file. Gas is specified in TGAS units (1 TGAS = 1e12 gas units). Example:
    {
      "network": "testnet",
      "contractId": "mettal-token.testnet",
      "initArgs": {
        "owner_id": "owner.testnet",
        "issuer_id": "issuer.testnet",
        "metadata": {
          "spec": "ft-1.0.0",
          "name": "Mettal Token",
          "symbol": "METTAL",
          "decimals": 18,
          "icon": "https://example.com/icon.png"
        }
      },
      "gas": "300",
      "deposit": "0"
    }

EOF
}


# Main execution
main() {
    NETWORK=$1
    CONFIG_FILE=$2
    DEPLOY_ONLY=false
    shift 2
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --only-deploy)
                DEPLOY_ONLY=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    log_info "Starting Mettal NEP-141 Token Contract Deployment"
    log_info "Network: $NETWORK"
    log_info "Config file: $CONFIG_FILE"
    log_info "Project root: $PROJECT_ROOT"

    # Check prerequisites
    check_prerequisites

    # Load configuration from file (always required)
    load_config "$CONFIG_FILE"

    # Validate required parameters (should be set by config)
    if [ -z "$CONTRACT_ID" ]; then
        log_error "CONTRACT_ID is required. Please set it in the config file: $CONFIG_FILE"
        exit 1
    fi

    # Choose deployment method
    if [ "${DEPLOY_ONLY:-true}" = true ]; then
        log_info "Using deploy only"
        deploy_only "$CONTRACT_ID" "$NETWORK"
    else
        if [ -z "$INIT_ARGS_JSON" ] || [ "$INIT_ARGS_JSON" = "null" ]; then
            log_error "initArgs is required. Please set it in the config file: $CONFIG_FILE"
            exit 1
        fi
        log_info "Using deploy + init in one transaction"
        deploy_and_init "$CONTRACT_ID" "$INIT_ARGS_JSON" "$NETWORK" "$GAS" "$DEPOSIT"
    fi
}

