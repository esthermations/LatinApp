import
  dom,
  jsconsole,
  json,
  strformat,
  strutils

type
  Word = object
    word: string
    kind: string

const
  defaultResult = """<div class="noResult">nūlla resultāta</div>"""

var
  searchBox: InputElement
  resultBox: Element
  loadButton: Element
  jsonData: JsonNode = nil

proc informUser(s: string) =
  console.log(s)

func wrapInDivClass(s: cstring, class: string): string =
  fmt"""<div class="{class}">{$s}</div>"""

### Convert a JsonNode containing a Word to a Word type
func jsonToWord(n: JsonNode): Word =
  Word(word: n["w"].getStr(), kind: n["k"].getStr())

### Search our JSON data for the given string
proc search(s: cstring): seq[Word] =
  assert jsonData != nil
  let arr = jsonData{$s}
  var ret: seq[Word]
  for elem in arr:
    ret.add elem.jsonToWord()
  return ret

func purifyInput(s: cstring): cstring =
  multiReplace($s, ("æ", "ae")).cstring

### Perform a search whenever the user enters a letter into the search box
proc onSearchInput() {.exportc.} =
  assert searchBox != nil
  var searchString = searchBox.value.purifyInput()
  var words = search(searchString)
  resultBox.innerHTML = ""
  if words.len == 0:
    if searchString.len == 0:
      resultBox.innerHTML = defaultResult
    else:
      resultBox.innerHTML = searchString.wrapInDivClass("noResult")
  else:
    for word in words:
      resultBox.innerHTML &=
        wrapInDivClass(word.word, "result") &
        wrapInDivClass(word.kind, "resultKind") &
        "<br>"

### Parse JSON from the string in memory
proc onLoadButtonPressed() {.exportc.} =
  const jsonString = staticRead("../out.json")
  loadButton.disabled = true
  jsonData = parseJson(jsonString)
  loadButton.innerHTML = "Factum!"
  searchBox.disabled = false

### Entry point for the whole .... thing
proc onPageLoad() {.exportc.} =
  informUser "Page has loaded!"

  searchBox = document.getElementById("searchBox").InputElement
  searchBox.disabled = true # Enabled when we load the Json

  resultBox = document.getElementById("resultBox")
  resultBox.innerHTML = defaultResult

  loadButton = document.getElementById("loadButton")
  loadButton.innerHTML = "Data JSON carricāre"
