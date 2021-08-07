import Artist from "./contract.cdc"

// Create a Picture Collection for the transaction authorizer.
transaction {
    prepare(account: AuthAccount) {
        var collectionRef = account.borrow<&Artist.Collection>(from: /storage/AritistCollection)
        if collectionRef == nil {
            account.save(<-Artist.createCollection(), to: /storage/AritistCollection)
            account.link<&Artist.Collection>(/public/AritistCollection, target: /storage/AritistCollection)
            log("Collection creation succ".concat(account.address.toString()))
        } else {
            log("Duplicated collection creation")
        }
    }
}