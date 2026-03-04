# near-nep141-mettal

A NEAR Protocol NEP-141 (Fungible Token) implementation for Mettal tokens including PENMT and MXND tokens.

## Overview

This project implements NEP-141 compliant fungible tokens on the NEAR blockchain, specifically designed for Mettal's token ecosystem. The contract supports standard FT operations with additional issuer functionality for controlled token minting.

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


### Testnet Deployment

For testnet deployment, use the configuration files in `scripts/testnet/`:

```bash
# Deploy PENMT token
bash scripts/testnet/penmt-deploy-init.sh

# Deploy MXND token
bash scripts/testnet/mxnd-deploy-init.sh

# Re-Deploy code only all contracts
bash scripts/testnet/redeploy-contracts.sh
```

### Configuration Files

The project uses JSON configuration files for deployment parameters:

**PENMT Token Configuration** (`scripts/testnet/penmt-testnet.json`):
```json
{
  "network": "testnet",
  "contractId": "penmt.mettal.testnet",
  "wasmPath": "./target/near/near_nep141_mettal.wasm",
  "initArgs": {
    "owner_id": "mettal.testnet",
    "issuer_id": "issuer.mettal.testnet",
    "metadata": {
      "spec": "ft-1.0.0",
      "name": "Mettal PENMT",
      "symbol": "PENMT",
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
│       ├── penmt-testnet.json  # PENMT token configuration
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
near view penmt.mettal.testnet ft_balance_of '{"account_id": "user.testnet"}' --network-config testnet

# Transfer tokens
near call penmt.mettal.testnet ft_transfer '{"receiver_id": "recipient.testnet", "amount": "1000000"}' --accountId user.testnet --deposit 0.000000000000000000000001 --network-config testnet

# Check token metadata
near view penmt.mettal.testnet ft_metadata --network-config testnet

# Issue new tokens (issuer only)
near call penmt.mettal.testnet issue '{"account_id": "user.testnet", "amount": "1000000"}' --accountId issuer.mettal.testnet --network-config testnet
```

## Integration Tests

### Launch Sandbox for integration testing

1. start the sandbox blockchain
```bash
bash scripts/sandbox/launch-sandbox.sh
```

2. On a new terminal, deploy the contracts:
```bash
bash scripts/sandbox/deploy-contracts.sh
```

3. See https://github.com/mettal-stable/mettal-blockchain-backend-services.git to run the API Service and the integration tests


## Manual Testing

### Local test with Sandbox

#### 1. Start the Sandbox

```bash
# Launch sandbox with automatic near-cli configuration
bash scripts/sandbox/launch-sandbox.sh
```

This script will:
- Configure near-cli for sandbox connection
- Start the NEAR sandbox on localhost:3030

#### 2. Deploy contracts and create users

In a different terminal:
```bash
# Launch sandbox with automatic near-cli configuration
bash scripts/sandbox/deploy-contracts.sh
```

This script will:
- create issuer, activator, token contract accounts, test-user accounts, etc
- Deploy PENMT and MXND contracts

After this you can run the tests in the repo mettal-blockchain-backend-services, to test a cycle against the sandbox

#### Stopping the Sandbox

```bash
# Kill all sandbox processes
bash scripts/sandbox/kill-sandbox.sh
```

### Sandbox Development Examples

```bash
# After running launch-sandbox.sh and sandbox-deploy-contracts.sh

# Check PENMT balance
near view penmt-mettal.test.near ft_balance_of '{"account_id": "mettal.test.near"}' --network-config sandbox

# Issue PENMT tokens
near call penmt-mettal.test.near issue '{"account_id": "mettal.test.near", "amount": "1000000"}' --accountId issuer.test.near --network-config sandbox

# Transfer PENMT tokens
near call penmt-mettal.test.near ft_transfer '{"receiver_id": "issuer.test.near", "amount": "100000"}' --accountId mettal.test.near --deposit 0.000000000000000000000001 --network-config sandbox
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
