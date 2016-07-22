splitPathByKey {
# test whether an arbitrary string can be split
  *Str = "file.txt";
  msiSplitPathByKey (*Str, ".", *Head, *End);
  writeLine ("stdout", "*Str, *Head, *End");
  *Str1 = "file";
  msiSplitPathByKey (*Str1, ".", *Head, *End);
  writeLine ("stdout", "*Str1, *Head, *End");
}
INPUT null
OUTPUT ruleExecOut
