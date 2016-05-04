testAsterisk {
# check syntax constructs
  *A = "file.txt"
  if (*A like "*.txt") { writeLine ("stdout", "Found a text file *A"); }
  *B = "filtxt";
  if (*B like "\*txt") { writeLine ("stdout", "Found a file *B"); }
  *C = "file\*txt";
  if (*C like "\*txt") { writeLine ("stdout", "Found a file *C"); }
  *D = "file1\nfile1"
  writeLine ("stdout", "Test new line; *D");
}
INPUT null
OUTPUT ruleExecOut
