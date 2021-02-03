import xmltree, xmlparser
import strutils, strformat
import streams
import json

const
  inPath  = "C:/Users/Esther O'Keefe/Downloads/enwiktionary-20210201-pages-articles.xml/enwiktionary-20210201-pages-articles.xml"
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


proc hasLatinEntry(n: XmlNode): bool =
  return n.getPageText().contains("==Latin==")


proc countPages(path: string): int =
  let f = newFileStream(path, fmRead)
  var
    line = ""
    count = 0
  echo ""
  if f != nil:
    while f.readLine(line):
      if line.contains("<page>"):
        inc count
        crPrintUpdate fmt"Pages total: {count}"
  return count


proc countLatinPages(path: string): int =
  let f = newFileStream(path, fmRead)
  var
    line = ""
    count = 0
  echo ""
  if f != nil:
    while f.readLine(line):
      if line.contains("==Latin=="):
        inc count
        crPrintUpdate fmt"Latin pages: {count}"
  return count

when isMainModule:

  let
    numPages = countPages(inPath)
    numLatinPages = countLatinPages(inPath)

  echo "Num pages:       ", numPages
  echo "Num latin pages: ", numLatinPages

  var
    inFile   = newFileStream(inPath, fmRead)
    outFile  = newFileStream(outPath, fmWrite)
    line     = ""
    saving   = false
    savedXml = ""
    outJson: JsonNode = parseJson("[]")
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
          title = page.child("title")

        if page.hasLatinEntry():
          let j = %* { "title": title.innerText, "content": page.getPageText() }
          outJson.add(j)
          inc pagesSaved
          let percent = (pagesSaved.float * 100.0 / numLatinPages.float)
          crPrintUpdate fmt"{pagesSaved} ({percent}%)"

        savedXml = ""

    inFile.close()

    outFile.write($outJson)
    outFile.close()
