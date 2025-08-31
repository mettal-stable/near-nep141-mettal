# near-nep141-mettal

A NEAR Protocol NEP-141 (Fungible Token) implementation for Mettal tokens including PSLD and MXND tokens.

## Overview

This project implements NEP-141 compliant fungible tokens on the NEAR blockchain, specifically designed for Mettal's token ecosystem. The contract supports standard FT operations with additional issuer functionality for controlled token minting.

## Quick Start

### Local Development with Sandbox

The fastest way to get started is using the NEAR sandbox for local development:

```bash
# 1. Launch sandbox and deploy contracts
./scripts/launch-sandbox.sh

# 2. In another terminal, deploy contracts and create accounts
./scripts/sandbox-deploy-contracts.sh
```

### Building the Contract

Install [`cargo-near`](https://github.com/near/cargo-near) and build:

```bash
cargo near build
```

### Running Tests

```bash
cargo test
```

## Development Environment Setup

### Prerequisites

1. **NEAR CLI** - Install the latest near-cli-rs:
   ```bash
   npm install -g near-cli-rs
   ```

2. **NEAR Sandbox** - For local development:
   ```bash
   npm install -g near-sandbox
   ```

3. **Rust and Cargo** - Install from [rustup.rs](https://rustup.rs/)

4. **cargo-near** - NEAR contract development toolkit:
   ```bash
   cargo install cargo-near
   ```

5. **jq** - For JSON processing in scripts:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install jq

   # macOS
   brew install jq
   ```

### Local Development with Sandbox

#### Starting the Sandbox

```bash
# Launch sandbox with automatic near-cli configuration
./scripts/launch-sandbox.sh
```

This script will:
- Configure near-cli for sandbox connection
- Start the NEAR sandbox on localhost:3030
- Deploy PSLD and MXND contracts
- Set up the local development environment

#### Creating Accounts and Deploying

```bash
# Create required accounts and deploy contracts
./scripts/sandbox-deploy-contracts.sh
```

This will create:
- `mettal.test.near` - Main organization account
- `issuer.test.near` - Token issuer account
- `psld-mettal.test.near` - PSLD token contract
- `mxnd-mettal.test.near` - MXND token contract

#### Stopping the Sandbox

```bash
# Kill all sandbox processes
./scripts/kill-sandbox.sh
```

## Deployment

## Deployment

### Sandbox Development (Recommended for Development)

Use the provided scripts for local development:

```bash
# Start sandbox environment
./scripts/launch-sandbox.sh

# Deploy contracts (in another terminal)
./scripts/sandbox-deploy-contracts.sh
```

### Testnet Deployment

For testnet deployment, use the configuration files in `scripts/testnet/`:

```bash
# Deploy PSLD token
./scripts/common/deploy_functions.sh testnet ./scripts/testnet/psld-testnet.json

# Deploy MXND token
./scripts/common/deploy_functions.sh testnet ./scripts/testnet/mxnd-testnet.json
```

### Configuration Files

The project uses JSON configuration files for deployment parameters:

**PSLD Token Configuration** (`scripts/testnet/psld-testnet.json`):
```json
{
  "network": "testnet",
  "contractId": "psld.mettal.testnet",
  "wasmPath": "./target/near/near_nep141_mettal.wasm",
  "initArgs": {
    "owner_id": "mettal.testnet",
    "issuer_id": "issuer.mettal.testnet",
    "metadata": {
      "spec": "ft-1.0.0",
      "name": "Mettal PSLD",
      "symbol": "PSLD",
      "decimals": 6
    }
  }
}
```

**MXND Token Configuration** (`scripts/testnet/mxnd-testnet.json`):
```json
{
  "network": "testnet",
  "contractId": "mxnd.mettal.testnet",
  "wasmPath": "./target/near/near_nep141_mettal.wasm",
  "initArgs": {
    "owner_id": "mettal.testnet",
    "issuer_id": "issuer.mettal.testnet",
    "metadata": {
      "spec": "ft-1.0.0",
      "name": "Mettal MXND",
      "symbol": "MXND",
      "decimals": 6
    }
  }
}
```

## Project Structure

```
├── src/
│   └── lib.rs                 # Main contract implementation
├── scripts/
│   ├── launch-sandbox.sh      # Start NEAR sandbox with config
│   ├── sandbox-deploy-contracts.sh  # Deploy contracts to sandbox
│   ├── kill-sandbox.sh        # Stop sandbox processes
│   ├── common/
│   │   └── deploy_functions.sh # Shared deployment functions
│   └── testnet/
│       ├── psld-testnet.json  # PSLD token configuration
│       └── mxnd-testnet.json  # MXND token configuration
├── tests/
│   └── test_basics.rs         # Integration tests
├── Cargo.toml                 # Rust dependencies
└── README.md                  # This file
```

## Contract Features

- **NEP-141 Compliant**: Full implementation of NEAR fungible token standard
- **Issuer Controls**: Designated issuer account can mint new tokens
- **Owner Management**: Contract owner can manage issuer permissions
- **Standard Operations**: Transfer, balance queries, allowances
- **Metadata Support**: Token name, symbol, decimals, icon
- **Storage Management**: Automatic storage deposit handling

## Usage Examples

### Interacting with Deployed Contracts

```bash
# Check token balance
near view psld.mettal.testnet ft_balance_of '{"account_id": "user.testnet"}' --network-config testnet

# Transfer tokens
near call psld.mettal.testnet ft_transfer '{"receiver_id": "recipient.testnet", "amount": "1000000"}' --accountId user.testnet --deposit 0.000000000000000000000001 --network-config testnet

# Check token metadata
near view psld.mettal.testnet ft_metadata --network-config testnet

# Issue new tokens (issuer only)
near call psld.mettal.testnet issue '{"account_id": "user.testnet", "amount": "1000000"}' --accountId issuer.mettal.testnet --network-config testnet
```

### Sandbox Development Examples

```bash
# After running launch-sandbox.sh and sandbox-deploy-contracts.sh

# Check PSLD balance
near view psld-mettal.test.near ft_balance_of '{"account_id": "mettal.test.near"}' --network-config sandbox

# Issue PSLD tokens
near call psld-mettal.test.near issue '{"account_id": "mettal.test.near", "amount": "1000000"}' --accountId issuer.test.near --network-config sandbox

# Transfer PSLD tokens
near call psld-mettal.test.near ft_transfer '{"receiver_id": "issuer.test.near", "amount": "100000"}' --accountId mettal.test.near --deposit 0.000000000000000000000001 --network-config sandbox
```

## Troubleshooting

### Sandbox Issues

If you encounter issues with the sandbox:

```bash
# Kill all sandbox processes
./scripts/kill-sandbox.sh

# Check if ports are free
lsof -i:3030,4000,9001

# Restart sandbox
./scripts/launch-sandbox.sh
```

### Near-CLI Configuration

If near-cli commands fail:

```bash
# Check network connections
near config show-connections

# Verify sandbox connection exists
near config show-connections | grep sandbox
```

### Build Issues

```bash
# Clean and rebuild
cargo clean
cargo near build

# Check Rust version
rustc --version

# Update cargo-near
cargo install cargo-near --force
```

## Production Deployment

For mainnet deployment:

1. Update configuration files to use mainnet accounts
2. Build with production optimizations:
   ```bash
   cargo near build --release
   ```
3. Test thoroughly on testnet first
4. Use proper account security practices
5. Consider multi-signature accounts for contract ownership

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License.

## Useful Links

- [cargo-near](https://github.com/near/cargo-near) - NEAR smart contract development toolkit for Rust
- [near CLI](https://near.cli.rs) - Interact with NEAR blockchain from command line
- [NEAR Rust SDK Documentation](https://docs.near.org/sdk/rust/introduction)
- [NEAR Documentation](https://docs.near.org)
- [NEAR StackOverflow](https://stackoverflow.com/questions/tagged/nearprotocol)
- [NEAR Discord](https://near.chat)
- [NEAR Telegram Developers Community Group](https://t.me/neardev)
- NEAR DevHub: [Telegram](https://t.me/neardevhub), [Twitter](https://twitter.com/neardevhub)
