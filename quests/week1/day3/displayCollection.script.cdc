import Artist from "./contract.cdc"

// Return an array of formatted Pictures that exist in the account with the a specific address.
// Return nil if that account doesn't have a Picture Collection.
pub fun main(address: Address): [String]? {
    let collectionRef = getAccount(address).getCapability<&Artist.Collection>(/public/AritistCollection).borrow()
       
    if let collectionRef = collectionRef {
        let size = collectionRef.pics.length
        var idx = 0
        let res:[String] = []
        while idx < size {
            let picRef = &collectionRef.pics[idx] as &Artist.Picture
            res.append(picRef.canvas.pixels)
            idx = idx + 1
        }
        return res
    } else {
        return nil
    }

}