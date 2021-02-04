import
  jscanvas,
  dom,
  jsconsole,
  strutils,
  strformat,
  json

const
  defaultBgColour = "#B57EDC"
  defaultFgColour = "#000000"
  defaultFont = "48px Libre Baskerville"

type
  Canvas = tuple
    canvas: CanvasElement
    ctx: CanvasContext
    x, y, w, h: int
    bgColour, fgColour: string # hex colour in format #000000

var
  searchCanvas: Canvas
  resultCanvas: Canvas
  searchString: string = "type to search..."
  resultString: string = "- result!!\n- another result!"
  firstKeyPress = true
  jsonData: JsonNode = nil


proc clear(c: Canvas) =
  assert c.ctx != nil
  console.log(fmt"clear: {c.x} {c.y} {c.w} {c.h}")
  c.ctx.fillStyle = c.bgColour
  c.ctx.fillRect(c.x, c.y, c.w, c.h)

proc createCanvas(id: string,
                  x, y, w, h: int,
                  font: string = defaultFont,
                  bgColour: string = defaultBgColour,
                  fgColour: string = defaultFgColour): Canvas =
  var c: Canvas
  c.canvas = document.getElementById(id).CanvasElement
  c.x = x
  c.y = y
  c.w = w
  c.h = h
  c.ctx = c.canvas.getContext2d()
  c.ctx.font = font
  c.bgColour = bgColour
  c.fgColour = fgColour
  c.clear()
  return c

proc putText(c: Canvas, text: string) =
  c.clear()
  c.ctx.fillStyle = c.fgColour

  const yOffsetPerLine = 50
  var lineNumber = 0

  for line in text.split('\n'):
    console.log(fmt"Line: {line}")
    let yOffset = (lineNumber * yOffsetPerLine)
    c.ctx.fillText(line.cstring, 10, 50 + yOffset)
    inc lineNumber

proc onKeyDown(ev: KeyboardEvent) {.exportc.} =
  console.log("Key is: ", ev.key)
  if ev.code == "Backspace":
    searchString.delete(max(searchString.len - 1, 0), 999)
  else:
    # Clear the example string when the user types something
    if firstKeyPress:
      firstKeyPress = false
      searchString = ""

    if ev.key in ["Shift".cstring, "Alt", "Control"]:
      return

    searchString.add(ev.key)

  searchCanvas.putText(searchString)
  resultCanvas.putText(resultString)

# Entry point for the whole .... thing
proc onPageLoad() {.exportc.} =
  console.log("Initialising!")

  document.addEventListener("keydown", onKeyDown)

  jsonData = parseJson(document.getElementById("jsonData").innerText)

  searchCanvas = createCanvas(
    id = "searchCanvas",
    x = 0, y = 0, w = window.innerWidth, h = 100,
  )

  resultCanvas = createCanvas(
    id = "resultCanvas",
    x = 0, y = 0, w = window.innerWidth, h = window.innerHeight - 200,
  )

  console.log("Initialised!")
