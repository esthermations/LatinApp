import unittest
import WikiText

suite "getMacronisation":
  test "Noun":
    const s = staticRead("./data/spiritus.txt")
    check s.getMacronisation() == "spīritus"
  test "ProperNoun":
    const s = staticRead("./data/roma.txt")
    check s.getMacronisation() == "Rōma"
  test "Verb":
    const s = staticRead("./data/eo.txt")
    check s.getMacronisation() == "eō"
  test "VerbForm":
    const s = staticRead("./data/ivi.txt")
    check s.getMacronisation() == "īvī"
  test "Adverb":
    const s = staticRead("./data/feliciter.txt")
    check s.getMacronisation() == "fēlīciter"
  test "Part": # Participle
    const s = staticRead("./data/sciens.txt")
    check s.getMacronisation() == "sciēns"
  test "PartForm": # Participle form
    const s = staticRead("./data/dormientes.txt")
    check s.getMacronisation() == "dormientēs"
  test "PronounForm":
    const s = staticRead("./data/eis.txt")
    check s.getMacronisation() == "eīs"
  test "Determiner":
    const s = staticRead("./data/ille.txt")
    check s.getMacronisation() == "ille" # No macrons here

