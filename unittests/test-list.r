testRule {
# demonstrate list extension
  *A = list ("The", "quick", "brown", "fox");
  *B = list ("jumped", "over");
  foreach (*A) {
    writeLine("stdout", "*A");
  }
  *S = size(*A);
  for (*I=*S; *I>0; *I=*I-1) {
    *B = cons (elem(*A,*I-1),*B);
  }
  foreach (*B) {
    writeLine ("stdout", "    *B");
  }
}
INPUT null
OUTPUT ruleExecOut
