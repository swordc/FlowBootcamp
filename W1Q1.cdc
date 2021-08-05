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
  display(canvas: canvasX)
}