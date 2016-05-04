ruleExample {
# rule to write Class-INLS624 path name to the screen
# test-writePath.r
  *Relcoll = "Class-INLS624";
  *Home = "/$rodsZoneClient/home/$userNameClient";
  *Path = "*Home/*Relcoll";
  writeLine ("stdout", "Path name for Class-INLS624 is *Path");
}
INPUT null
OUTPUT ruleExecOut
