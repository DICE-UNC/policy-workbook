testStruct {
# test loops over structures
  *nam = "test";
  *Meta.*nam = "1";
  foreach (*L in *Meta) {
    *V = *Meta.*L;
    writeLine ("stdout", "*V");
  }
}
INPUT null
OUTPUT ruleExecOut
