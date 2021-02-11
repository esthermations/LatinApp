import strutils, strformat, sugar, re

const desiredSectionHeaders = [
# "Pronunciation", # Most pages just have e.g. {{la-IPA|grātīs}}
  "Noun",
  "Verb",
  "Adverb",
  "Participle",
]

func getHeaderName(s: string): string =
  return s.strip(chars = {'='} + Whitespace)

func isDesiredHeader(s: string): bool =
  return s.getHeaderName() in desiredSectionHeaders

func isSectionHeader(s: string): bool =
  return s.startsWith("===")

static: assert "===Noun===".isSectionHeader()
static: assert "===Verb===".isSectionHeader()
static: assert not "Hello".isSectionHeader()

func shouldBeDeleted(s: string): bool =
  return s.startsWith("#*") or
         s.startsWith("#:") or
         s.startsWith("}}")

# TODO: Templatise this!
# It would take three parameters:
#   1. the regex pattern
#   2. the number of expected matches (for matches.len)
#   3. the final format string

func laNoun(line: string): string =
  const pattern = re"{{la-noun\|(.+)<([1-4])>}}"
  var matches: array[2, string]
  if s.match(pattern = pattern, matches = matches):
    return fmt"{mathes[0]} ({matches[1]} declension)\n"
  else:
    return line

func doReplacements(s: string): string =
  for r in replacements:
    if r.shouldReplace(s):
      return r.replace(s)
  # Base case: no replacements are valid, just return the line.
  return s


# These take the form {{la-noun|macronised_spelling<declension>}}
# {{la-noun|fābella<1>}}


# {{la-adv|grātīs|-}}

func processWikiText*(s: string): string =
  var
    deleting = false
    output = ""
  for line in s.splitLines(keepEol = true):
    if line.isSectionHeader():
      # Start deleting if we're starting an undesired section
      deleting = not line.isDesiredHeader()

    if deleting or line.shouldBeDeleted():
      continue # Don't add the line to the output
    else:
      output.add(line.doReplacements())

  return output


