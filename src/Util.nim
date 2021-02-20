import xmltree

### Get the actual Wikitext for this page.
func getPageText*(n: XmlNode): string =
  let text = n.child("revision").child("text")
  if text == nil:
    return ""
  else:
    return text.innerText()

### Get the <title> child element of an XmlNode
func getTitle*(n: XmlNode): string =
  return n.child("title").innerText

### Print a carriage return and then the given string and flush output, so we
### don't have a new line every time we log something.
proc crPrintUpdate*(s: string) =
  write(stdout, "                       \r")
  write(stdout, s)
  flushFile(stdout)

