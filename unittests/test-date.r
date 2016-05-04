testdata {
# check how to transform for datetime variable to double
  *T0 = time();
  writeLine ("stdout", "*T0");
  *T10 = 01453168082. - 7. * 24. *3600 -8. * 3600. - 53. * 60.;
  writeLine("stdout", "*T10");
}
INPUT null
OUTPUT ruleExecOut
