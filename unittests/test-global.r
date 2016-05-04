main = testGlobal
GLOBAL_MANIFEST = "Manifests"
testGlobal {
  *M = GLOBAL_MANIFEST;
  writeLine("stdout", "*M");
}
INPUT null
OUTPUT ruleExecOut
