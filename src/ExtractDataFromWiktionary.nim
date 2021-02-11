import xmltree, xmlparser
import strutils, strformat
import streams
import json

import WikiText

const
  inPath = "C:/Users/Esther O'Keefe/Downloads/enwiktionary-20210201-pages-articles.xml/enwiktionary-20210201-pages-articles.xml"
  outPath = "./out.json"


# Print a carriage return and then the given string and flush output, so we
# don't have a new line every time we log something.
proc crPrintUpdate(s: string) =
  write(stdout, '\r')
  write(stdout, s)
  flushFile(stdout)


# Get the actual Wikitext for this page.
func getPageText(n: XmlNode): string =
  let text = n.child("revision").child("text")
  if text == nil:
    return ""
  else:
    return text.innerText()


proc getLatinSection(s: string): string =
  let idx = s.find("==Latin==")
  assert idx != -1
  var fin = s.find("----", start = idx)
  if fin == -1:
    return s[idx ..< s.len]
  else:
    return s[idx ..< fin]


func getTitle(n: XmlNode): string =
  return n.child("title").innerText

proc hasLatinEntry(n: XmlNode): bool =
  return n.getPageText().contains("==Latin==")

func shouldLoadPage(n: XmlNode): bool =
  return n.hasLatinEntry() and
         not n.getTitle().startsWith("Wiktionary:")

when isMainModule:

  # Grabbed from a previous run on the same data
  const numLatinPages = 808_502

  var
    inFile = newFileStream(inPath, fmRead)
    outFile = newFileStream(outPath, fmWrite)
    line = ""
    saving = false
    savedXml = ""
    outJson: JsonNode = parseJson("[]")
    pagesSaved = 0

  if not inFile.isNil():
    while inFile.readLine(line):

      if pagesSaved == 10_000:
        break

      if line.contains("<page>"):
        saving = true

      if saving:
        savedXml.add(line)
        savedXml.add('\n')

      if line.contains("</page>"):
        saving = false
        # Finish process
        let page = parseXml(savedXml)

        if shouldLoadPage(page):
          let
            pageText = page.getPageText()
            latinSection = pageText.getLatinSection().processWikiText()

          let j = %* {
            "title": page.getTitle(),
            "content": latinSection
          }

          outJson.add(j)
          inc pagesSaved
          let percent = (pagesSaved.float * 100.0 / numLatinPages.float)
          crPrintUpdate fmt"{pagesSaved} ({percent:>7.3f}%)"

        savedXml = ""

    inFile.close()

    outFile.write(outJson.pretty())
    outFile.close()
