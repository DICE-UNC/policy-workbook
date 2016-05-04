testRule {
# illustrate a for loop
  for (*I = 0; *I < 6; *I=*I+1) {
    writeLine ("stdout", "Iteration *I");
  }
}
INPUT null
OUTPUT ruleExecOut
