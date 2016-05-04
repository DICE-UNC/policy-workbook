testRule {
#test wild card
  *A = "file.txt";
  if (*A like "\*e.txt") {
    writeLine ("stdout", "Found text file");
  }
  if (*A like "fil*" ) {
    writeLine ("stdout", "File *A contains fil");
  }
}
INPUT null
OUTPUT ruleExecOut
