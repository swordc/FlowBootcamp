import Artist from "./contract.cdc"

// Print a Picture and store it in the authorizing account's Picture Collection.
transaction(width: UInt8, height: UInt8, pixels: String) {
    let collectionRef: &Artist.Collection

    prepare(account: AuthAccount) {
        self.collectionRef = account.borrow<&Artist.Collection>(from: /storage/AritistCollection)
            ?? panic("Couldn't borrow collection ref")
    }

    execute {
        let printerRef = getAccount(0x1cf0e2f2f715450).getCapability<&Artist.Printer>(/public/ArtistPicturePrinter).borrow()
            ?? panic("Couldn't borrow printer ref")
        let canvas = Artist.Canvas(width:width, height:height, pixels:pixels)
        let pic <-printerRef.print(canvas:canvas)
        if pic != nil {
            log("----------print suc".concat(pixels))
            self.collectionRef.deposit(picture: <-pic!)
        } else {
            log("----------print err".concat(pixels))
            destroy pic
        }
    }

}

