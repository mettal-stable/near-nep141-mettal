# 🚀 Mettal NEP-141 Token Deployment Scripts

A comprehensive toolkit for deploying the Mettal NEP-141 fungible token contract to NEAR blockchain with multiple deployment methods and configuration options.

## 📁 Files Overview

| File | Description |
|------|-------------|
| `mxnd_deploy_init.sh` | 🐚 **Main deployment script** (near-cli based) |
| `deploy_init.ts` | 📝 **TypeScript deployment script** (near-api-js based) |
| `deploy-config.json` | ⚙️ **Default configuration** (testnet) |
| `deploy-config-mainnet.json` | ⚙️ **Mainnet configuration template** |
| `package.json` | 📦 **Node.js dependencies** |
| `tsconfig.json` | ⚙️ **TypeScript configuration** |

## ⚡ Quick Start

### Prerequisites
```bash
# Install near-cli
npm install -g near-cli

# Install jq for JSON processing
sudo apt-get install jq  # Ubuntu/Debian
# OR
brew install jq          # macOS

# Ensure you have NEAR account with sufficient balance
```

### Fastest Deployment (Recommended)
```bash
# 1. Edit deploy-config.json with your account details
# 2. Deploy atomically (default behavior)
./mxnd_deploy_init.sh --use-config
```

## 🎯 Deployment Methods

### Method 1: JSON Configuration (Recommended) ⭐

**Edit `deploy-config.json`:**
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
      "icon": "https://mettal.finance/logo.png"
    }
  }
}
```

**Deploy:**
```bash
# Atomic deployment (default - recommended)
--use-config                Use default config file (deploy-config.json)
    --only-deploy               Deploy and initialize separately (default: atomic)
    -h, --help                  Show this help message
```

### Method 2: Environment Variables

```bash
```bash
export ACCOUNT_ID=your-account.testnet
export CONTRACT_ID=mettal-token.testnet
export OWNER_ID=owner.testnet
export ISSUER_ID=issuer.testnet
export TOKEN_NAME="Mettal Token"
export TOKEN_SYMBOL="METTAL"

./mxnd_deploy_init.sh  # Atomic deployment by default
```
```

### Method 3: Command Line Arguments

```bash
./mxnd_deploy_init.sh \
  --network testnet \
  --account your-account.testnet \
  --contract mettal-token.testnet \
  --owner owner.testnet \
  --issuer issuer.testnet \
  --token-name "Mettal Token" \
  --symbol METTAL  # Atomic deployment by default
```

## 🔧 Configuration File Format

### Complete Configuration Schema
```json
{
  "network": "testnet",
  "deployerAccount": "deployer.testnet",
  "contractId": "mettal-token.testnet",
  "initArgs": {
    "owner_id": "owner.testnet",
    "issuer_id": "issuer.testnet",
    "metadata": {
      "spec": "ft-1.0.0",
      "name": "Mettal Token",
      "symbol": "METTAL",
      "decimals": 18,
      "icon": "https://mettal.finance/logo.png",
      "reference": "https://mettal.finance",
      "reference_hash": null
    }
  },
  "gas": "300000000000000",
  "deposit": "0",
  "wasmPath": "../../../target/near/near_nep141_mettal.wasm"
}
```

### Field Descriptions

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `network` | string | Network (`testnet` or `mainnet`) | ✅ |
| `deployerAccount` | string | Account deploying the contract | ✅ |
| `contractId` | string | Target contract account ID | ✅ |
| `initArgs.owner_id` | string | Contract owner account | ✅ |
| `initArgs.issuer_id` | string | Account allowed to mint tokens | ✅ |
| `initArgs.metadata` | object | Token metadata | ✅ |
| `gas` | string | Gas limit (default: 300 TGas) | ❌ |
| `deposit` | string | NEAR deposit (default: 0) | ❌ |
| `wasmPath` | string | Path to WASM file | ❌ |

## ⚡ Atomic vs Separate Deployment

### Atomic Deployment (Default - Recommended) ⭐
```bash
./mxnd_deploy_init.sh --use-config  # Default behavior
```

**✅ Advantages:**
- Single transaction = lower gas costs
- Atomic operation (all-or-nothing)
- Production-ready
- Faster deployment

### Separate Deployment
```bash
./mxnd_deploy_init.sh --use-config --only-deploy
```

**✅ Advantages:**
- More control over deployment process
- Can deploy to existing accounts
- Better for debugging
- Step-by-step verification

### Separate Deployment
```bash
./mxnd_deploy_init.sh --use-config
```

**✅ Advantages:**
- More control over deployment process
- Can deploy to existing accounts
- Better for debugging
- Step-by-step verification

**❌ Limitations:**
- Higher gas costs
- Two separate transactions

## 📝 TypeScript Deployment

### Setup
```bash
npm install
npm run build
```

### Usage
```typescript
import { deployToTestnet, createDefaultMetadata } from './deploy_init.js';

const metadata = createDefaultMetadata('Mettal Token', 'METTAL', 18);
const contract = await deployToTestnet(
  'mettal-token.testnet',
  'deployer.testnet',
  'ed25519:private-key',
  {
    owner_id: 'owner.testnet',
    issuer_id: 'issuer.testnet',
    metadata
  }
);
```

## 🔍 Contract Verification

After deployment, verify your contract:

```bash
# Check token metadata
near contract call-function as-read-only mettal-token.testnet ft_metadata \
  json-args {} network-config testnet

# Check contract owner
near contract call-function as-read-only mettal-token.testnet get_owner_id \
  json-args {} network-config testnet

# Check token issuer
near contract call-function as-read-only mettal-token.testnet get_issuer \
  json-args {} network-config testnet

# Check total supply
near contract call-function as-read-only mettal-token.testnet ft_total_supply \
  json-args {} network-config testnet
```

## 🛠️ Advanced Usage

### Custom Configuration Files
```bash
# Use custom config file (atomic by default)
./mxnd_deploy_init.sh --config my-config.json

# Use separate deployment
./mxnd_deploy_init.sh --config my-config.json --only-deploy
```

### Custom Gas and Deposit
```bash
./mxnd_deploy_init.sh \
  --use-config \
  --gas 500000000000000 \
  --deposit 1  # Atomic deployment by default
```

### Custom WASM Path
```bash
./mxnd_deploy_init.sh \
  --use-config \
  --wasm-path /path/to/custom.wasm  # Atomic deployment by default
```

## 🚨 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **"Account does not exist"** | Verify all account IDs exist on the network |
| **"Insufficient balance"** | Ensure deployer account has enough NEAR (at least 10 NEAR) |
| **"WASM file not found"** | Run `cargo near build non-reproducible-wasm` in project root |
| **"Permission denied"** | Run `chmod +x mxnd_deploy_init.sh` |
| **"Contract already exists"** | Use `--only-deploy` for existing contracts |
| **"jq not found"** | Install jq: `sudo apt-get install jq` |

### Debug Mode
```bash
# Enable verbose output
set -x
./mxnd_deploy_init.sh --use-config --atomic
set +x
```

### Check Prerequisites
```bash
# Verify near-cli
near --version

# Verify jq
jq --version

# Check WASM file
ls -la ../../../target/near/near_nep141_mettal.wasm
```

## 🔐 Security Best Practices

- ✅ **Never commit private keys** to version control
- ✅ **Use environment variables** for sensitive data
- ✅ **Test on testnet first** before mainnet deployment
- ✅ **Verify all parameters** before deployment
- ✅ **Use atomic deployment** for production
- ✅ **Backup configuration files** securely
- ✅ **Monitor gas costs** and account balances

## 📋 Contract Parameters

### Required Initialization Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `owner_id` | AccountId | Contract owner (can update settings) |
| `issuer_id` | AccountId | Account allowed to mint new tokens |
| `metadata.spec` | string | Token standard (always "ft-1.0.0") |
| `metadata.name` | string | Human-readable token name |
| `metadata.symbol` | string | Token symbol (e.g., "METTAL") |
| `metadata.decimals` | number | Decimal places (18 recommended) |

### Optional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `metadata.icon` | string | Token icon URL |
| `metadata.reference` | string | Token reference URL |
| `metadata.reference_hash` | string | Reference hash |

## 🎯 Examples

### Testnet Deployment
```bash
# Quick testnet deployment (atomic by default)
./mxnd_deploy_init.sh --use-config
```

### Mainnet Deployment
```bash
# Edit deploy-config-mainnet.json first (atomic by default)
./mxnd_deploy_init.sh --config deploy-config-mainnet.json
```

### Separate Deployment (for debugging)
```bash
# Deploy and initialize separately
./mxnd_deploy_init.sh --use-config --only-deploy
```

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify your NEAR account balance and permissions
3. Test with separate deployment first (use `--only-deploy`)
4. Check near-cli and jq installations
