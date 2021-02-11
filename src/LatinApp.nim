import
  dom,
  jsconsole,
  json

const
  defaultBgColour = "#B57EDC"
  defaultFgColour = "#000000"
  defaultFont = "48px Libre Baskerville"

var
  searchBox: InputElement
  resultBox: Element
  jsonData: JsonNode = nil

proc search(s: cstring): cstring =
  assert jsonData != nil
  for page in jsonData:
    if s == page{"title"}.getStr():
      return page{"content"}.getStr().cstring
  return "No results!"

proc onSearchInput() {.exportc.} =
  assert searchBox != nil
  var searchString = searchBox.value
  resultBox.innerText = search(searchString)

# Entry point for the whole .... thing
proc onPageLoad() {.exportc.} =
  console.log("Initialising!")

  const jsonString = staticRead("../out.json")
  jsonData = parseJson(jsonString)

  searchBox = document.getElementById("searchBox").InputElement
  resultBox = document.getElementById("resultBox")

  console.log("Initialised!")
