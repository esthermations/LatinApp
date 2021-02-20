import unittest
import WikiText

suite "getWords":
  test "Noun: spīritus":
    const s = staticRead("./data/spiritus.txt")
    check s.getWords() == @[Word(w: "spīritus", k: WordKind.Noun)]
  test "Noun: ē":
    const s = staticRead("./data/e.txt")
    check s.getWords() == @[Word(w: "ē", k: WordKind.Noun)]
  test "Noun: bē":
    const s = staticRead("./data/be.txt")
    check s.getWords() == @[Word(w: "bē", k: WordKind.Noun)]
  test "NounForm: gladi":
    const s = staticRead("./data/gladi.txt")
    check s.getWords() == @[Word(w: "gladi", k: WordKind.NounForm)]
  test "NounForm: gladiō":
    const s = staticRead("./data/gladio.txt")
    check s.getWords() == @[Word(w: "gladiō", k: WordKind.NounForm)]
  test "ProperNoun: Rōma":
    const s = staticRead("./data/roma.txt")
    check s.getWords() == @[Word(w: "Rōma", k: WordKind.ProperNoun)]
  test "ProperNoun: Abaddōn":
    const s = staticRead("./data/abaddon.txt")
    check s.getWords() == @[Word(w: "Abaddōn", k: WordKind.ProperNoun)]
  test "Numeral":
    const s = staticRead("./data/unus.txt")
    check s.getWords() == @[
      Word(w: "ūnus", k: WordKind.Adjective),
      Word(w: "ūnus", k: WordKind.Numeral),
    ]
  test "Adjective":
    const s = staticRead("./data/pulcher.txt")
    check s.getWords() == @[Word(w: "pulcher", k: WordKind.Adjective)]
  test "AdjectiveForm":
    const s = staticRead("./data/beatorum.txt")
    check s.getWords() == @[Word(w: "beātōrum", k: WordKind.AdjectiveForm)]
  test "Verb":
    const s = staticRead("./data/scribo.txt")
    check s.getWords() == @[Word(w: "scrībō", k: WordKind.Verb)]
  test "VerbForm":
    const s = staticRead("./data/ivi.txt")
    check s.getWords() == @[Word(w: "īvī", k: WordKind.VerbForm)]
  test "Adverb":
    const s = staticRead("./data/feliciter.txt")
    check s.getWords() == @[Word(w: "fēlīciter", k: WordKind.Adverb)]
  test "Participle":
    const s = staticRead("./data/sciens.txt")
    check s.getWords() == @[Word(w: "sciēns", k: WordKind.Participle)]
  test "ParticipleForm":
    const s = staticRead("./data/dormientes.txt")
    check s.getWords() == @[Word(w: "dormientēs", k: WordKind.ParticipleForm)]
  test "PronounForm":
    const s = staticRead("./data/eis.txt")
    check s.getWords() == @[Word(w: "eīs", k: WordKind.PronounForm)]
  test "Determiner":
    const s = staticRead("./data/ille.txt")
    check s.getWords() == @[Word(w: "ille", k: WordKind.Determiner)]
  test "Conjunction":
    const s = staticRead("./data/si.txt")
    check s.getWords() == @[Word(w: "sī", k: WordKind.Conjunction)]
  test "Multiple Kinds: hoc/hōc":
    const s = staticRead("./data/hoc.txt")
    check s.getWords() == @[
      Word(w: "hoc", k: WordKind.DeterminerForm),
      Word(w: "hōc", k: WordKind.DeterminerForm),
      Word(w: "hōc", k: WordKind.Adverb),
    ]
  test "Multiple Kinds: eō":
    const s = staticRead("./data/eo.txt")
    check s.getWords() == @[
      Word(w: "eō", k: WordKind.Verb),
      Word(w: "eō", k: WordKind.Adverb),
      Word(w: "eō", k: WordKind.PronounForm)
    ]
