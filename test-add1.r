myaddition3times2Rule {
#rule to add three input variables and then multiple them by 2
	*D = *A + *B + *C; 
	*E = *D * 2;
	writeLine ("stdout", "(*A + *B + *C) * 2 = *E");
}
INPUT *A = 3, *B = 2, *C = 4
OUTPUT ruleExecOut
