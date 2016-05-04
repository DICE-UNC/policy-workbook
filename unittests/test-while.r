testRule {
# illustrate a while loop
  *N = 5;
  *I = 0;
  while (*I < *N) {
    *I = *I + 1;
    writeLine("stdout", "Iteration *I");
  }
}
INPUT null
OUTPUT ruleExecOut
