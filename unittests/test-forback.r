testRule {
# illustrate for loop that decrements
  for (*I = 6; *I > 0; *I=*I-1) {
    writeLine("stdout","Iteration *I");
  }
}
INPUT null
OUTPUT ruleExecOut
