/*!
Mettal NEP-141 Fungible Token implementation
with mint, burn and compliance functions.
*/
use near_contract_standards::fungible_token::metadata::{
    FungibleTokenMetadata, FungibleTokenMetadataProvider,
};
use near_contract_standards::fungible_token::{
    events, FungibleToken, FungibleTokenCore, FungibleTokenResolver,
};
use near_contract_standards::storage_management::{
    StorageBalance, StorageBalanceBounds, StorageManagement,
};
use near_sdk::borsh::BorshSerialize;
use near_sdk::collections::LazyOption;
use near_sdk::json_types::U128;
use near_sdk::store::IterableSet;
use near_sdk::{
    assert_one_yocto, env, log, near, require, AccountId, BorshStorageKey, NearToken,
    PanicOnDefault, PromiseOrValue,
};

#[derive(PanicOnDefault)]
#[near(contract_state)]
pub struct Contract {
    owner_id: AccountId,
    issuer_id: AccountId,
    token: FungibleToken,
    metadata: LazyOption<FungibleTokenMetadata>,
    frozen_accounts: IterableSet<AccountId>,
}

#[derive(BorshSerialize, BorshStorageKey)]
#[borsh(crate = "near_sdk::borsh")]
enum StorageKey {
    FungibleToken,
    Metadata,
    FrozenAccounts,
}

#[near]
impl Contract {
    /// Initializes the contract owned by the given `owner_id`
    /// the issuer_id is the account that is allowed to mint new tokens.
    #[init]
    pub fn new(owner_id: AccountId, issuer_id: AccountId, metadata: FungibleTokenMetadata) -> Self {
        require!(!env::state_exists(), "Already initialized");
        metadata.assert_valid();
        Self {
            owner_id,
            issuer_id,
            token: FungibleToken::new(StorageKey::FungibleToken),
            metadata: LazyOption::new(StorageKey::Metadata, Some(&metadata)),
            frozen_accounts: IterableSet::new(StorageKey::FrozenAccounts),
        }
    }

    fn assert_owner_calling(&self) {
        assert!(
            env::predecessor_account_id() == self.owner_id,
            "can only be called by the owner"
        );
    }
    // returns account ID of the owner.
    pub fn get_owner_id(self) -> AccountId {
        self.owner_id
    }
    #[payable]
    pub fn set_owner_id(&mut self, owner_id: AccountId) {
        self.assert_owner_calling();
        assert!(env::is_valid_account_id(owner_id.as_bytes()));
        self.owner_id = owner_id.into();
    }

    // owner can add/remove minters
    #[payable]
    pub fn set_issuer(&mut self, issuer_id: AccountId) {
        assert_one_yocto();
        self.assert_owner_calling();
        self.issuer_id = issuer_id;
    }

    pub fn get_issuer(self) -> AccountId {
        self.issuer_id
    }

    pub fn assert_issuer_calling(&self) {
        assert!(
            self.issuer_id == env::predecessor_account_id(),
            "not the issuer"
        );
    }

    // issuer can mint
    #[payable]
    pub fn ft_mint(&mut self, amount: U128, memo: Option<String>) {
        assert_one_yocto();
        self.assert_issuer_calling();
        self.token
            .internal_deposit(&env::predecessor_account_id(), amount.into());
        events::FtMint {
            owner_id: &env::predecessor_account_id(),
            amount,
            memo: memo.as_deref(),
        }
        .emit();
    }

    // anyone can burn their tokens
    #[payable]
    pub fn ft_burn(&mut self, amount: U128, memo: Option<String>) {
        assert_one_yocto();
        self.assert_not_frozen(env::predecessor_account_id());
        self.token
            .internal_withdraw(&env::predecessor_account_id(), amount.into());
        events::FtBurn {
            owner_id: &env::predecessor_account_id(),
            amount,
            memo: memo.as_deref(),
        }
        .emit();
    }

    // Frozen accounts
    #[payable]
    pub fn freeze_account(&mut self, account_id: AccountId) {
        assert_one_yocto();
        self.assert_issuer_calling();
        self.frozen_accounts.insert(account_id);
    }
    #[payable]
    pub fn unfreeze_account(&mut self, account_id: AccountId) {
        assert_one_yocto();
        self.assert_issuer_calling();
        self.frozen_accounts.remove(&account_id);
    }
    pub fn assert_not_frozen(&self, account_id: AccountId) {
        assert!(!self.is_account_frozen(account_id), "Account is frozen");
    }
    pub fn is_account_frozen(&self, account_id: AccountId) -> bool {
        self.frozen_accounts.contains(&account_id)
    }
    pub fn get_frozen_accounts(&self, start: u64, limit: u64) -> Vec<&AccountId> {
        self.frozen_accounts
            .iter()
            .skip(start as usize)
            .take(limit as usize)
            .collect()
    }
}

#[near]
impl FungibleTokenCore for Contract {
    #[payable]
    fn ft_transfer(&mut self, receiver_id: AccountId, amount: U128, memo: Option<String>) {
        self.assert_not_frozen(env::predecessor_account_id());
        self.token.ft_transfer(receiver_id, amount, memo)
    }

    #[payable]
    fn ft_transfer_call(
        &mut self,
        receiver_id: AccountId,
        amount: U128,
        memo: Option<String>,
        msg: String,
    ) -> PromiseOrValue<U128> {
        self.assert_not_frozen(env::predecessor_account_id());
        self.token.ft_transfer_call(receiver_id, amount, memo, msg)
    }

    fn ft_total_supply(&self) -> U128 {
        self.token.ft_total_supply()
    }

    fn ft_balance_of(&self, account_id: AccountId) -> U128 {
        self.token.ft_balance_of(account_id)
    }
}

#[near]
impl FungibleTokenResolver for Contract {
    #[private]
    fn ft_resolve_transfer(
        &mut self,
        sender_id: AccountId,
        receiver_id: AccountId,
        amount: U128,
    ) -> U128 {
        let (used_amount, burned_amount) =
            self.token
                .internal_ft_resolve_transfer(&sender_id, receiver_id, amount);
        if burned_amount > 0 {
            log!("Account @{} burned {}", sender_id, burned_amount);
        }
        used_amount.into()
    }
}

#[near]
impl StorageManagement for Contract {
    #[payable]
    fn storage_deposit(
        &mut self,
        account_id: Option<AccountId>,
        registration_only: Option<bool>,
    ) -> StorageBalance {
        self.token.storage_deposit(account_id, registration_only)
    }

    #[payable]
    fn storage_withdraw(&mut self, amount: Option<NearToken>) -> StorageBalance {
        self.token.storage_withdraw(amount)
    }

    #[payable]
    fn storage_unregister(&mut self, force: Option<bool>) -> bool {
        #[allow(unused_variables)]
        if let Some((account_id, balance)) = self.token.internal_storage_unregister(force) {
            log!("Closed @{} with {}", account_id, balance);
            true
        } else {
            false
        }
    }

    fn storage_balance_bounds(&self) -> StorageBalanceBounds {
        self.token.storage_balance_bounds()
    }

    fn storage_balance_of(&self, account_id: AccountId) -> Option<StorageBalance> {
        self.token.storage_balance_of(account_id)
    }
}

#[near]
impl FungibleTokenMetadataProvider for Contract {
    fn ft_metadata(&self) -> FungibleTokenMetadata {
        self.metadata.get().unwrap()
    }
}
