import Artist from 0x01

pub fun main(){
  let accounts: [Address] = [0x01, 0x02, 0x03, 0x04, 0x05]
  for acct in accounts {
    printPictures(address: acct)
  }
}
pub fun printPictures(address:Address) {
  let collectionRef = getAccount(address).getCapability<&Artist.Collection>(/public/PictureCollection).borrow()
  log(address.toString().concat(" collects:"))
  
  if let collectionRef = collectionRef {
    let size = collectionRef.pics.length
    var idx = 0
    while idx < size {
      let picRef = &collectionRef.pics[idx] as &Artist.Picture
      log("^^^^^^^")
      Artist.display(canvas: picRef.canvas)
      idx = idx+1
    }
  } else {
    log("no collections")
  }
}