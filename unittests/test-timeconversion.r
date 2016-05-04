# Exercise 52
# This rule gets the system time in Unix, and converts to "human" format.

convertTime {
	*Unixtime = time();
	 msiGetSystemTime(*Humantime, "human");
	writeLine("stdout", "*Humantime");
}

INPUT null
OUTPUT ruleExecOut
