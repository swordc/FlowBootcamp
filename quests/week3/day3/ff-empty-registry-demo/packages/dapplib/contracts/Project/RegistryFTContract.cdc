import RegistryInterface from Project.RegistryInterface
import RegistryService from Project.RegistryService
import FungibleToken from Flow.FungibleToken

pub contract RegistryFTContract: RegistryInterface, FungibleToken {

    // Maps an address (of the customer/DappContract) to the amount
    // of tenants they have for a specific RegistryContract.
    access(contract) var clientTenants: {Address: UInt64}

    // ITenant
    //
    // An interface to allow the Tenant owner
    // to expose the totalSupply field
    //
    pub resource interface ITenant {
        pub var totalSupply: UFix64
    }

    // Tenant
    //
    // Requirement that all conforming multitenant smart contracts have
    // to define a resource called Tenant to store all data and things
    // that would normally be saved to account storage in the contract's
    // init() function
    //
    // In this case, the Tenant has two things:
    // 1) totalSupply
    // 2) an FTMinter resource
    // 
    pub resource Tenant: ITenant {

        pub var totalSupply: UFix64

        pub fun updateTotalSupply(delt: Fix64) {
            if (delt >= 0.0) {
                self.totalSupply = self.totalSupply + (delt as UFix64)
            } else {
                self.totalSupply = self.totalSupply - (delt as UFix64)
            }
        }

        access(self) let minter: @FTMinter

        pub fun minterRef(): &FTMinter {
            return &self.minter as &FTMinter
        }

        init() {
            self.totalSupply = 0

            self.minter <- create FTMinter()
        }

        destroy() {
            destroy self.minter
        }
    }

    // instance
    // instance returns an Tenant resource.
    //
    pub fun instance(authNFT: &RegistryService.AuthNFT): @Tenant {
        let clientTenant = authNFT.owner!.address
        if let count = self.clientTenants[clientTenant] {
            self.clientTenants[clientTenant] = self.clientTenants[clientTenant]! + (1 as UInt64)
        } else {
            self.clientTenants[clientTenant] = (1 as UInt64)
        }

        return <-create Tenant()
    }

    // getTenants
    // getTenants returns clientTenants.
    //
    pub fun getTenants(): {Address: UInt64} {
        return self.clientTenants
    }

    // Named Paths
    //
    pub let TenantStoragePath: StoragePath
    pub let TenantPublicPath: PublicPath

    pub let VaultStoragePath: StoragePath
    pub let ReceiverPublicPath: PublicPath
    pub let BalancePublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    //
    // NFTContract
    //

    // Normally, this data would be moved to the Tenant.
    // HOWEVER, this Contract must implement the NonFungibleToken
    // standard, so we have to keep this here. This means we will
    // keep track of this totalSupply as well as each Tenant's totalSupply
    // upon minting an NFT.
    pub var totalSupply: UFix64

    // Events
    // TokensInitialized
    //
    // The event that is emitted when the contract is created
    pub event TokensInitialized(initialSupply: UFix64)

    // TokensWithdrawn
    //
    // The event that is emitted when tokens are withdrawn from a Vault
    pub event TokensWithdrawn(amount: UFix64, from: Address?)

    // TokensDeposited
    //
    // The event that is emitted when tokens are deposited to a Vault
    pub event TokensDeposited(amount: UFix64, to: Address?)

    // TokensMinted
    //
    // The event that is emitted when new tokens are minted
    pub event TokensMinted(amount: UFix64)

    // TokensBurned
    //
    // The event that is emitted when tokens are destroyed
    pub event TokensBurned(amount: UFix64)

    // MinterCreated
    //
    // The event that is emitted when a new minter resource is created
    pub event MinterCreated(totalAmount: UFix64)
    // NFT Resource
    //
    // Has an id field and a metadata dictionary that can hold
    // any extra information.
    //
    pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {

        // holds the balance of a users tokens
        pub var balance: UFix64

        // initialize the balance at resource creation time
        init(balance: UFix64) {
            self.balance = balance
        }

        // withdraw
        //
        // Function that takes an integer amount as an argument
        // and withdraws that amount from the Vault.
        // It creates a new temporary Vault that is used to hold
        // the money that is being transferred. It returns the newly
        // created Vault to the context that called so it can be deposited
        // elsewhere.
        //
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        // deposit
        //
        // Function that takes a Vault object as an argument and adds
        // its balance to the balance of the owners Vault.
        // It is allowed to destroy the sent Vault because the Vault
        // was a temporary holder of the tokens. The Vault's balance has
        // been consumed and therefore can be destroyed.
        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @RegistryFTContract.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        destroy() {
            RegistryFTContract.totalSupply = RegistryFTContract.totalSupply - self.balance
        }
    }

    // FTMinter
    //
    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
    pub resource FTMinter {
        pub var totalAmount: UFix64

        pub fun mintTokens(tenant: &Tenant{ITenant}, amount: UFix64): @RegistryFTContract.Vault {
            pre {
                amount > UFix64(0): "Amount minted must be greater than zero"
                amount <= self.totalAmount: "Amount minted must be less than the allowed amount"
            }
            tenant.updateTotalSupply(delt: Fix64(amount))
            RegistryFTContract.totalSupply = RegistryFTContract.totalSupply + amount
            self.totalAmount = self.totalAmount - amount
            emit TokensMinted(amount: amount)
            return <-create Vault(balance: amount)
        }

        init() {
            self.totalAmount = 1000000.0
        }
    }
    
    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 0.0)
    }

    init() {
        // Initialize the total supply
        self.totalSupply = 0.0
        // Initialize clientTenants
        self.clientTenants = {}

        // Set Named paths
        self.TenantStoragePath = /storage/RegistryFTContractTenant
        self.TenantPublicPath = /public/RegistryFTContractTenant

        self.VaultStoragePath = /storage/RegistryFTContractVault
        self.ReceiverPublicPath = /public/RegistryFTContractReceiver
        self.BalancePublicPath = /public/RegistryFTContractBalance
        self.MinterStoragePath = /storage/RegistryFTContractMinter
    }
}