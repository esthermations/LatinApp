import
  dom,
  json,
  strformat,
  strutils,
  tables

import LatinWords
import LatinWords/Types

type
  SearchResult = object
    word: string
    desc: string

const
  defaultResult = """<div class="noResult">nūlla resultāta</div>"""

var
  searchBox: InputElement
  resultBox: Element
  loadButton: Element
  wikitextTemplateJson: JsonNode = nil
  cachedResults = initTable[string, seq[SearchResult]]()

func wrapInWiktionaryLink(s: string): string =
  let noMacrons = s.deMacronise()
  return fmt"""<a href="https://en.wiktionary.org/wiki/{$noMacrons}#Latin" target="_blank">{$s}</a>"""

func `$`(n: NounIdentifier): string =
  let nsLink = n.nomSing.wrapInWiktionaryLink()
  return fmt"{$n.c} {$n.n} of {$nsLink}"

func `$`(v: VerbIdentifier): string =
  let fppLink = v.firstPrincipalPart.wrapInWiktionaryLink()
  return fmt"{$v.p} {$v.n} {$v.a} {$v.v} {$v.m} of {$fppLink}"

func toSearchResult(w: WordForm): SearchResult =
  case w.kind
  of WordKind.Noun: return SearchResult(word: w.word, desc: $w.nounID)
  of WordKind.Verb: return SearchResult(word: w.word, desc: $w.verbID)
  else: return SearchResult(word: w.word, desc: "?")


func wrapInDivClass(s: cstring, class: string): string =
  fmt"""<div class="{class}">{$s}</div>"""

func wordFormsToSearchResults(w: AllWordForms): seq[SearchResult] =
  let dictionaryForm = getDictionaryForm(w)
  var wordForms: seq[WordForm]
  case w.kind
  of WordKind.Unknown:
    discard
  of WordKind.Noun:
    for n in Number:
      for c in NounCase:
        let
          id = (dictionaryForm, n, c)
          word = w.nounForms[n][c]
        wordForms.add WordForm(word: word, kind: WordKind.Noun, nounID: id)
  of WordKind.Verb:
    for m in Mood:
      for v in Voice:
        for a in Aspect:
          for n in Number:
            for p in Person:
              let
                id = (dictionaryForm, m, v, a, n, p)
                word = w.verbForms[m][v][a][n][p]
              wordForms.add WordForm(word: word, kind: WordKind.Verb, verbID: id)

  var ret: seq[SearchResult]
  for wf in wordForms:
    ret.add wf.toSearchResult()
  return ret



proc searchTemplateAndUpdateCache(t: cstring): seq[SearchResult] =
  let
    wordForms = getAllWordForms($t)
    results = wordFormsToSearchResults(wordForms)

  if wordForms.kind == WordKind.Unknown:
    echo "Unknown word kind: ", $t
    return @[]

  defer:
    let key = getDictionaryForm(wordForms).deMacronise()
    echo "Key: ", $key
    if cachedResults.hasKey(key):
      echo "returning cached results:", $cachedResults[key]
      return cachedResults[key]
    else:
      echo "no cached results, returning nothing."
      return @[]

  for result in results:
    let key = result.word.deMacronise()
    if key.len > 0:
      echo "Caching word: ", key
      if cachedResults.hasKey(key):
        cachedResults[key].add result
      else:
        cachedResults[key] = @[result]


### Search our JSON data for the given string
proc search(s: cstring): seq[SearchResult] =
  assert wikitextTemplateJson != nil

  if cachedResults.hasKey($s):
    echo "Returning cached result for ", $s
    return cachedResults[$s]

  # Otherwise, we need to create a result, if we can.

  # If this word matches a WikiText template, generate results from that
  # template.
  var templates = wikitextTemplateJson{$s}

  echo (
    if templates == nil:
    "No cached template results"
  else:
    "Templates: " & $templates
  )

  # No such template, and no such stored result, so try and guess a word form
  # and see if we have a template for that.
  if templates == nil:
    let wf = guessWordForm($s)
    # Otherwise, we have a word! Maybe.
    if wf.len > 0:
      for w in wf:
        let word = getDictionaryForm(w).deMacronise()
        let dictionaryFormTemplates = wikitextTemplateJson{word}
        if dictionaryFormTemplates != nil:
          if templates == nil:
            templates = %[]
          for t in dictionaryFormTemplates:
            # Update the cache with new words.
            echo "Caching template: ", $t
            discard searchTemplateAndUpdateCache(t.getStr())

  if cachedResults.hasKey($s):
    return cachedResults[$s]

  if templates != nil:
    var ret: seq[SearchResult]
    for t in templates:
      assert t != nil
      ret &= searchTemplateAndUpdateCache(t.getStr())
    return ret

  return @[]

func purifyInput(s: cstring): cstring =
  multiReplace($s, ("æ", "ae")).cstring


### Perform a search whenever the user enters a letter into the search box
proc onSearchInput() {.exportc.} =
  assert searchBox != nil
  var searchString = searchBox.value.purifyInput()
  var results = search(searchString)
  resultBox.innerHTML = ""
  if results.len == 0:
    if searchString.len == 0:
      resultBox.innerHTML = defaultResult
    else:
      resultBox.innerHTML = searchString.wrapInDivClass("noResult")
  else:
    var previousWord = ""
    for result in results:
      if result.word != previousWord:
        resultBox.innerHTML &= "<br>" & wrapInDivClass(result.word, "result")
      resultBox.innerHTML &= wrapInDivClass(result.desc, "resultDesc")
      previousWord = result.word

### Parse JSON from the string in memory
proc onLoadButtonPressed() {.exportc.} =
  const str = staticRead("../out.json")
  loadButton.disabled = true
  wikitextTemplateJson = parseJson(str)
  loadButton.innerHTML = "Factum!"
  searchBox.disabled = false
  echo "Json loaded!"

### Entry point for the whole .... thing
proc onPageLoad() {.exportc.} =
  echo "Page has loaded!"

  searchBox = document.getElementById("searchBox").InputElement
  searchBox.disabled = true # Enabled when we load the Json

  resultBox = document.getElementById("resultBox")
  resultBox.innerHTML = defaultResult

  loadButton = document.getElementById("loadButton")
  loadButton.innerHTML = "Data JSON carricāre"
