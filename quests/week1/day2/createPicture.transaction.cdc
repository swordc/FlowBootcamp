import Artist from 0x01

transaction {
  let picture: @Artist.Picture?
  let pixels: String
  let collectionRef: &Artist.Collection

  prepare(acct: AuthAccount) {
    //
    self.pixels = "***** * *   *   * * *   *"
    let printerRef = getAccount(0x01).getCapability<&Artist.Printer>(/public/ArtistPicturePrinter).borrow()
      ?? panic("Couldn't borrow printer reference")
    let canvas = Artist.Canvas(width: printerRef.width, height: printerRef.height, pixels: self.pixels)
    self.picture <- printerRef.print(canvas: canvas)
    //
    var collectionRef = acct.borrow<&Artist.Collection>(from: /storage/PictureCollection)
    if collectionRef == nil {
      acct.save(<-Artist.createCollection(), to: /storage/PictureCollection)
      acct.link<&Artist.Collection>(/public/PictureCollection, target: /storage/PictureCollection)
      collectionRef = acct.borrow<&Artist.Collection>(from: /storage/PictureCollection)
    }
    self.collectionRef = collectionRef!
  }

  execute {
    if self.picture == nil {
      log("Picture exists with".concat(self.pixels))
      destroy self.picture
    } else {
      log("Picture create ".concat(self.pixels))
      self.collectionRef.deposit(picture: <-self.picture!)
    }
  }
}
