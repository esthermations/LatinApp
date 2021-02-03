import jscanvas, dom, jsconsole
import strutils

var
  gCanvas  : CanvasElement = nil
  gCtx     : CanvasContext = nil
  gMessage : string = "We did the thing!"
  gFirstKeyPress = true

proc clearCanvas() =
  gCtx.fillStyle = "#B57EDC"
  gCtx.fillRect(0, 0, window.innerWidth, window.innerHeight)


proc onKeyDown(ev: KeyboardEvent) {.exportc.} =
  console.log("Key is: ", ev.key)
  if ev.code == "Backspace":
    gMessage.delete(max(gMessage.len - 1, 0), 999)
  else:
    if gFirstKeyPress:
      gFirstKeyPress = false
      gMessage = ""

    if ev.key in ["Shift".cstring, "Alt", "Control"]:
      return

    gMessage.add(ev.key)

  clearCanvas()
  gCtx.font = "48px Libre Baskerville"
  gCtx.fillStyle = "#000000"
  gCtx.fillText(gMessage.cstring, 10, 50)

# Entry point for the whole .... thing
proc onPageLoad() {.exportc.} =
  console.log("Initialising!")

  gCanvas = document.getElementById("hello").CanvasElement
  gCanvas.width  = window.innerWidth
  gCanvas.height = window.innerHeight

  gCtx = gCanvas.getContext2d()
  clearCanvas()

  document.addEventListener("keydown", onKeyDown)

  console.log("Initialised!")
