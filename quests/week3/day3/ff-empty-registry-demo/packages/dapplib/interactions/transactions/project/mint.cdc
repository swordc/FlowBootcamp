import FungibleToken from Flow.FungibleToken
import RegistryFTContract from Registry.RegistryFTContract

transaction(recipient: Address, amount: UFix64) {
    let tenant: &RegistryFTContract.Tenant{RegistryFTContract.ITenant}
    let receiver: &RegistryFTContract.Vault{FungibleToken.Receiver}

    prepare(signer: AuthAccount) {
        self.tenant = signer.borrow<&RegistryFTContract.Tenant{RegistryFTContract.ITenant}>(from: RegistryFTContract.TenantStoragePath)
                            ?? panic("Can't borrow tenant")
        
        self.receiver = getAccount(recipient)
            .getCapability(RegistryFTContract.ReceiverPublicPath)
            .borrow<&RegistryFTContract.Vault{FungibleToken.Receiver}>()
            ?? panic("Can't borrow reciver ref")
    }

    execute {
        let minter <- self.tenant.minterRef().mintTokens(amount: amount)
        
        self.receiver.deposit(from: <-minter)
    }
}