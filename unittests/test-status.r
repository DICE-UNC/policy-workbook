mytestRule {
# check that value of *Status flag is integer
  *Path ="/$rodsZoneClient/home/$userNameClient/foo1"; 
  msiIsData (*Path, *DataID, *Status);
  if (*Status == 0) {
    writeLine("stdout", "Status flag is an integer");
  }
}
INPUT null
OUTPUT ruleExecOut
