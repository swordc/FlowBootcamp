pub contract Artist {

  pub struct Canvas {

    pub let width: UInt8
    pub let height: UInt8
    pub let pixels: String

    init(width: UInt8, height: UInt8, pixels: String) {
      self.width = width
      self.height = height
      // The following pixels
      // 123
      // 456
      // 789
      // should be serialized as
      // 123456789
      self.pixels = pixels
    }
  }

  pub resource Collection {
    pub let pics : @[Picture]
    init() {
      self.pics <- []
    }
    pub fun deposit(picture: @Picture) {
      self.pics.append(<-picture)
    }
    destroy() {
      destroy self.pics
    }
  }

  pub fun createCollection(): @Collection {
    return <- create Collection()
  }

  pub resource Picture {

    pub let canvas: Canvas
    
    init(canvas: Canvas) {
      self.canvas = canvas
    }
  }

  pub resource Printer {

    pub let width: UInt8
    pub let height: UInt8
    pub let prints: {String: Canvas}

    init(width: UInt8, height: UInt8) {
      self.width = width;
      self.height = height;
      self.prints = {}
    }

    pub fun print(canvas: Canvas): @Picture? {
      // Canvas needs to fit Printer's dimensions.
      if canvas.pixels.length != Int(self.width * self.height) {
        return nil
      }

      // Canvas can only use visible ASCII characters.
      for symbol in canvas.pixels.utf8 {
        if symbol < 32 || symbol > 126 {
          return nil
        }
      }

      // Printer is only allowed to print unique canvases.
      if self.prints.containsKey(canvas.pixels) == false {
        let picture <- create Picture(canvas: canvas)
        self.prints[canvas.pixels] = canvas

        return <- picture
      } else {
        return nil
      }
    }
  }
  pub fun display(canvas: Canvas)
  {
    var width : UInt8 = canvas.width
    var height : UInt8 = canvas.height
    var s : String = canvas.pixels
    var w : UInt8 = 0
    var h : UInt8 = 0

    while h < height+2 {
      var line : String = ""
      
      if h == 0 || h == height+1 { line = line.concat("+") }
      else { line = line.concat("|") }
      //
      if h == 0 || h == height+1 {  
        w = 0
        while w < width {
          line = line.concat("-")
          w = w + 1
        }
      } else {
        line = line.concat( s.slice(
          from: Int((h-1)*width),
          upTo: Int((h-1)*width) + Int(width)
        ))
      }
      //
      if h == 0 || h == height+1 { line = line.concat("+")
      } else { line = line.concat("|") }
      
      log(line)
      h = h + 1
    }
}

  init() {
    self.account.save(
      <- create Printer(width: 5, height: 5),
      to: /storage/ArtistPicturePrinter
    )
    self.account.link<&Printer>(
      /public/ArtistPicturePrinter,
      target: /storage/ArtistPicturePrinter
    )
  }
}