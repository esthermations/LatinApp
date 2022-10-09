# This script reduces an XML export of Wiktionary down to only <page>..</page>
# sections that contain Latin words, and deletes all sections other than the
# Latin section of those pages.

import
  xmlparser,
  xmltree,
  strutils,
  strformat,
  streams,
  json,
  os

import
  util

func getLatinSection(s: string): string =
  let idx = s.find("==Latin==")
  assert idx != -1
  let fin = s.find("----", start = idx)
  if fin == -1:
    s[idx ..< s.len]
  else:
    s[idx ..< fin]

proc hasLatinEntry(n: XmlNode): bool =
  n.getPageText().contains("==Latin==")

func shouldLoadPage(n: XmlNode): bool =
  n.hasLatinEntry() and
    not n.getTitle().startsWith("Wiktionary:") and
    not n.getTitle().startsWith("Reconstruction:")

when isMainModule:
  # Grabbed from a previous run on the same data. Just used for calculating %
  # complete - not actually functional.
  const numLatinPages = 820_000

  let
    inPath = commandLineParams()[0]
    outPath = "./ReducedWiktionary.xml"

  var
    inFile = newFileStream(inPath, fmRead)
    outFile = newFileStream(outPath, fmWrite)
    line = ""
    saving = false
    thisPageXml = ""
    outXml: XmlNode = parseXml("<mediawiki></mediawiki>")
    pagesSaved = 0

  if not inFile.isNil():
    while inFile.readLine(line):

      if line.contains("<page>"):
        saving = true

      if saving:
        thisPageXml.add(line)
        thisPageXml.add('\n')

      if line.contains("</page>"):
        saving = false
        # Finish process
        var page = parseXml(thisPageXml)

        if shouldLoadPage(page):
          let
            pageTitle = page.getTitle()
            latinSection = page.getPageText().getLatinSection()
            shouldDiscard = latinSection.len == 0 or pageTitle.len == 0

          if not shouldDiscard:
            var
              titleXml = newElement("title")
              textXml = newElement("text")

            titleXml.add newText(pageTitle)
            textXml.add newText(latinSection)

            page.clear()
            page.add titleXml
            page.add textXml
            outXml.add page

          inc pagesSaved
          let percent = (pagesSaved.float * 100.0 / numLatinPages.float)
          crPrintUpdate fmt"{pagesSaved} ({percent:>7.3f}%)"

        thisPageXml = ""

    inFile.close()
    outFile.write($outXml)
    outFile.close()
