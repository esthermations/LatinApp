import
  dom,
  jsconsole,
  json,
  strformat


const
  defaultResult = """<div class="noResult">nūlla resultāta</div>"""

var
  searchBox: InputElement
  resultBox: Element
  loadButton: Element
  jsonData: JsonNode = nil

proc informUser(s: string) =
  console.log(s)

### Search our JSON data for the given string
proc search(s: cstring): cstring =
  assert jsonData != nil
  return jsonData{$s}.getStr()

### Perform a search whenever the user enters a letter into the search box
proc onSearchInput() {.exportc.} =
  assert searchBox != nil
  var searchString = searchBox.value
  var result = search(searchString)
  if result.len == 0:
    resultBox.innerHTML = defaultResult
  else:
    resultBox.innerHTML = fmt"""<div class="result">{$result}</div>"""

### Parse JSON from the string in memory
proc onLoadButtonPressed() {.exportc.} =
  const jsonString = staticRead("../out.json")
  jsonData = parseJson(jsonString)
  loadButton.innerHTML = "Factum!"
  searchBox.disabled = false
  loadButton.disabled = true

### Entry point for the whole .... thing
proc onPageLoad() {.exportc.} =
  informUser "Page has loaded!"

  searchBox = document.getElementById("searchBox").InputElement
  searchBox.disabled = true # Enabled when we load the Json

  resultBox = document.getElementById("resultBox")
  resultBox.innerHTML = defaultResult

  loadButton = document.getElementById("loadButton")
  loadButton.innerHTML = "Data JSON carricāre"
