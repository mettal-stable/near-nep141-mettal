# near-nep141-mettal

## How to Build Locally?

Install [`cargo-near`](https://github.com/near/cargo-near) and run:

```bash
cargo near build
```

## How to Test Locally?

```bash
cargo test
```

## How to Deploy?

### Automated Deployment (Recommended)

Deployment is automated with GitHub Actions CI/CD pipeline.

### Manual Deployment

For manual deployment, use the provided deployment scripts. All deployment parameters are configured through JSON config files for consistency and ease of use.

#### Prerequisites

1. Install [`near-cli`](https://github.com/near/near-cli):
   ```bash
   npm install -g near-cli
   ```

2. Install [`jq`](https://stedolan.github.io/jq/) for JSON processing:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install jq

   # macOS
   brew install jq
   ```

3. (Optional) Install [`cargo-near`](https://github.com/near/cargo-near) for enhanced contract building:
   ```bash
   cargo install cargo-near
   ```

#### Configuration

Create a JSON configuration file (e.g., `deploy-config.json`) with your deployment parameters:

```json
{
  "network": "testnet",
  "deployerAccount": "your-account.testnet",
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
  "gas": "300000000000000",
  "deposit": "0"
}
```

#### Deployment Commands

Navigate to the deployment script directory:
```bash
cd scripts/testnet/internal/
```

**Atomic Deployment (Recommended - Deploy + Init in one transaction):**
```bash
# Using default config file
./mxnd_deploy_init.sh

# Using custom config file
./mxnd_deploy_init.sh --config my-config.json
```

**Separate Deployment (For debugging):**
```bash
# Deploy and initialize separately
./mxnd_deploy_init.sh --only-deploy
```

#### Deployment Methods

- **Atomic Deployment** (Default): Deploys the contract and initializes it in a single transaction. This is the recommended approach for production deployments.
- **Separate Deployment**: Deploys the contract first, then initializes it in a separate transaction. Useful for debugging or when working with existing contracts.

#### TypeScript Deployment

A TypeScript deployment script is also available at `scripts/testnet/internal/deploy_init.ts` for programmatic deployment in Node.js environments.

### Production Deployment

For production deployments on mainnet:

1. Update your config file to use `"network": "mainnet"`
2. Ensure all account IDs are mainnet accounts
3. Use production-ready WASM builds
4. Test thoroughly on testnet first

## Useful Links

- [cargo-near](https://github.com/near/cargo-near) - NEAR smart contract development toolkit for Rust
- [near CLI](https://near.cli.rs) - Interact with NEAR blockchain from command line
- [NEAR Rust SDK Documentation](https://docs.near.org/sdk/rust/introduction)
- [NEAR Documentation](https://docs.near.org)
- [NEAR StackOverflow](https://stackoverflow.com/questions/tagged/nearprotocol)
- [NEAR Discord](https://near.chat)
- [NEAR Telegram Developers Community Group](https://t.me/neardev)
- NEAR DevHub: [Telegram](https://t.me/neardevhub), [Twitter](https://twitter.com/neardevhub)
