import strutils, re, unittest

const desiredSectionHeaders = [
  "Noun",
  "Verb",
  "Adverb",
  "Participle",
  "Pronoun",
  "Proper Noun"
]

func getHeaderName(s: string): string =
  return s.strip(chars = {'='} + Whitespace)

func isDesiredHeader(s: string): bool =
  return s.getHeaderName() in desiredSectionHeaders

func isSectionHeader(s: string): bool =
  return s.startsWith("===")

test "isSectionHeader":
  check "===Noun===".isSectionHeader()
  check "===Verb===".isSectionHeader()
  check not "Hello".isSectionHeader()

type
  WordKind = enum
    Noun,
    ProperNoun,
    Verb,
    VerbForm,
    Adverb,
    Part,
    PartForm,
    PronounForm,
    Determiner

let
  # Regex patterns for extracting macronised words from WikiText templates
  templatePatterns = [
    Noun: re"{{la-noun\|([^<]+)",
    ProperNoun: re"{{la-proper noun\|([^<]+)",
    Verb: re"{{la-verb\|[^\|]+\|(.+)}}",
    VerbForm: re"{{la-verb-form\|(.+)}}",
    Adverb: re"{{la-adv\|([^\|]+)(?:}}|\|-}})",
    Part: re"{{la-part\|([^\|]+).*}}",
    PartForm: re"{{la-part-form\|(.+)}}",
    PronounForm: re"{{la-pronoun-form\|(.+)}}",
    Determiner: re"{{la-det\|([^<]+)"
  ]

proc getMacronisation*(latinSection: string): string =
  for line in latinSection.splitLines():
    if line.startsWith("{{"):
      # Speed: only do regex testing if it passes a simpler test
      for pattern in templatePatterns:
        if line.match(pattern):
          var matches: array[1, string]
          discard line.match(pattern = pattern, matches = matches)
          return matches[0]

