testRule {
        *A = list(10, 30, 20, 50);
	*I = 0;
	foreach (*R in *A) {
  		*I = *I +1;
  		writeLine ("stdout", "*I th element is *R");
	}
}
INPUT null
OUTPUT ruleExecOut
