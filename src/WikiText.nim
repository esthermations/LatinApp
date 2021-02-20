import strutils, re

type
  WordKind* {.pure.} = enum
    Noun,
    NounForm,
    ProperNoun,
    Numeral,
    Adjective,
    AdjectiveForm,
    Verb,
    VerbForm,
    Adverb,
    Participle,
    ParticipleForm,
    PronounForm,
    Determiner,
    DeterminerForm,
    Conjunction

  Word* = object
    w*: string   ### Word
    k*: WordKind ### Kind

let
  # Regex patterns for extracting macronised words from WikiText templates
  templatePatterns = [
    Noun: re"{{la-noun\|([^<\|/]+)",
    NounForm: re"{{la-noun-form\|([^\|}]+)",
    ProperNoun: re"{{la-proper noun\|([^<\|]+)",
    Numeral: re"{{la-num-adj\|([^<\|]+)",
    Adjective: re"{{la-adj\|([^<\|/]+)",
    AdjectiveForm: re"{{la-adj-form\|([^}]+)",
    Verb: re"{{la-verb\|[^\|]+\|([^\|}]+)",
    VerbForm: re"{{la-verb-form\|([^<\|]+)}}",
    Adverb: re"{{la-adv\|([^\|]+)(?:}}|\|-}})",
    Participle: re"{{la-part\|([^\|]+).*}}",
    ParticipleForm: re"{{la-part-form\|(.+)}}",
    PronounForm: re"{{la-pronoun-form\|(.+)}}",
    Determiner: re"{{la-det\|([^<]+)",
    DeterminerForm: re"{{la-det-form\|([^}]+)",
    Conjunction: re"{{head\|la\|conjunction\|head=([^}]+)"
  ]

proc getWords*(latinSection: string): seq[Word] =
  var ret: seq[Word]
  defer: return ret
  for line in latinSection.splitLines():
    # Speed: only do regex testing if it passes a simpler test
    if line.startsWith("{{"):
      for kind in WordKind:
        let pattern = templatePatterns[kind]
        if line.match(pattern):
          var matches: array[1, string]
          discard line.match(pattern = pattern, matches = matches)
          ret.add Word(w: matches[0], k: kind)


