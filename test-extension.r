testExtension {
# test-extension.r
# check whether the extension is always from the end of the file
  *Test = "file.ex1.ex2";
  msiSplitPathByKey (*Test, ".", *Head, *Type);
  writeLine ("stdout", "Split *Test into head *Head and type *Type");
  *Type1 = ext(*Test);
  writeLine ("stdout", "Extract extension from *Test as *Type1");
}
ext(*p) {
    *b = trimr(*p, ".");
    *ext = if *b == *p then "no ext" else substr(*p, strlen(*b)+1, strlen(*p));
    *ext;
}
INPUT null
OUTPUT ruleExecOut
