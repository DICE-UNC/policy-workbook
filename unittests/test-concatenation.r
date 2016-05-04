checkConcatenation {
  *C = "test";
  *D = "start"++*C;
  writeLine ("stdout", "*D");
}
INPUT null
OUTPUT ruleExecOut
