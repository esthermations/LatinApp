import
  xmlparser,
  xmltree,
  strutils,
  strformat,
  streams,
  json

import
  Util

const
  inPath = "./ReducedWiktionary.xml"
  outPath = "./out.json"

proc getWordTemplates*(latinSection: string): seq[string] =
  const templatePatterns = [
    "{{la-noun|",
    # "{{la-noun-form",
    "{{la-proper noun|",
    "{{la-num-adj|",
    "{{la-adj|",
    # "{{la-adj-form",
    "{{la-verb|",
    # "{{la-verb-form",
    "{{la-adv|",
    "{{la-part|",
    #"{{la-part-form",
    # "{{la-pronoun-form",
    "{{la-det|",
    # "{{la-det-form",
  ]
  var ret: seq[string]
  defer: return ret
  for line in latinSection.splitLines():
    for pattern in templatePatterns:
      if line.strip().startsWith(pattern):
        ret.add line.strip()



when isMainModule:
  # Grabbed from a previous run on the same data
  const numLatinPages = 807878

  var
    inFile = newFileStream(inPath, fmRead)
    outFile = newFileStream(outPath, fmWrite)
    line = ""
    saving = false
    savedXml = ""
    outJson: JsonNode = parseJson("{}")
    pagesSaved = 0

  if not inFile.isNil():
    while inFile.readLine(line):

      if line.contains("<page>"):
        saving = true

      if saving:
        savedXml.add(line)
        savedXml.add('\n')

      if line.contains("</page>"):
        saving = false
        # Finish process
        let
          page = parseXml(savedXml)
          title = page.getTitle()
          words = page.child("text").innerText.getWordTemplates()
          shouldDiscard: bool =
            words.len == 0 or title.len == 0

        if not shouldDiscard:
          outJson[title] = %words

        inc pagesSaved
        let percent = (pagesSaved.float * 100.0 / numLatinPages.float)
        crPrintUpdate fmt"{pagesSaved} ({percent:>7.3f}%)"

        savedXml = ""

    inFile.close()
    outFile.write(outJson.pretty())
    outFile.close()
