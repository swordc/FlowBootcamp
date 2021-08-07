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

pub resource Printer
{
  pub let records : {String:Bool}
  init()
  {
    self.records = {}
  }
  pub fun print(canvas: Canvas) : @Picture?
  {
    if self.records.containsKey(canvas.pixels) {
      log("plag picture")
      return nil
    }
    log("new picture")
    self.records[canvas.pixels] = true
    return <- create Picture(canvas:canvas)
  }
} 

pub fun serializeStringArray(_ lines: [String]): String {
  var buffer = ""
  for line in lines {
    buffer = buffer.concat(line)
  }

  return buffer
}

pub resource Picture {

  pub let canvas: Canvas
  
  init(canvas: Canvas) {
    self.canvas = canvas
  }
}

pub fun main() {
  let pixelsX = [
    "*   *",
    " * * ",
    "  *  ",
    " * * ",
    "*   *"
  ]
  let canvasX = Canvas(
    width: 5,
    height: 5,
    pixels: serializeStringArray(pixelsX)
  )
  let letterX <- create Picture(canvas: canvasX)
  log(letterX.canvas)
  destroy letterX

  // test
  let printer <- create Printer()
  let p1 <- printer.print(canvas:canvasX)
  let p2 <- printer.print(canvas:canvasX)

  destroy printer
  destroy p1
  destroy p2
}