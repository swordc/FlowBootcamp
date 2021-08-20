import KittyItems from Project.KittyItems
import NonFungibleToken from Flow.NonFungibleToken

transaction(itemID: UInt64) {
    let collectionRef: &KittyItems.Collection

    prepare(signer: AuthAccount) {
        self.collectionRef = signer.borrow<&KittyItems.Collection>(from: KittyItems.CollectionStoragePath)
                                   ?? panic ("Can't borrow collection")
    }

    execute {
        let burnItem <- self.collectionRef.withdraw(withdrawID: itemID)
        destroy burnItem
    }
}