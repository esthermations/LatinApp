import strutils, strformat, sugar, re

const desiredSectionHeaders = [
# "Pronunciation", # Most pages just have e.g. {{la-IPA|grātīs}}
  "Noun",
  "Verb",
  "Adverb",
  "Participle",
  "Pronoun",
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

type WiktionaryTemplateKind = enum
  Noun,
  Verb,
  VerbForm,
  Adverb,
  PartForm,
  PronounForm,

let
  # Regex patterns for extracting macronised words from WikiText templates
  templatePatterns = [
    Noun: re"{{la-noun\|(.+)<[1-4]>}}",
    Verb: re"{{la-verb\|[^\|]+\|(.+)}}",
    VerbForm: re"{{la-verb-form\|(.+)}}",
    Adverb: re"{{la-adv\|([^\|]+)(?:}}|\|-}})",
    PartForm: re"{{la-part-form\|(.+)}}",
    PronounForm: re"{{la-pronoun-form\|(.+)}}",
  ]

proc getMacronisation*(latinSection: string): string =
  for line in latinSection.splitLines():
    for pattern in templatePatterns:
      if line.match(pattern):
        var matches: array[1, string]
        discard line.match(pattern = pattern, matches = matches)
        return matches[0]
