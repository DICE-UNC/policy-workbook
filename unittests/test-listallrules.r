testlistallrules {
# List core rules
  writeLine ("stdout", "Core rules");
  foreach (*R in listcorerules) {
    if (*R like "ac*" && *R != "actionStart") {
      writeLine ("stdout", *R);
    }
  }
  writeLine ("stdout", "------------------------------------------");
  writeLine ("stdout", "App rules\nactionStart");
  foreach (*R in listcorerules) {
    if (*R like "ac*") {
      #noop
    } else {
      writeLine ("stdout", *R);
    }
  }
}
INPUT null
OUTPUT ruleExecOut
