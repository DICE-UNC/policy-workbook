ruleSetUse {
# rda-useSet.r
# Sets metadata attribute Use_Agreement to RECEIVED
  checkUserInput (*User, $rodsZoneClient);
  msiAddKeyVal(*Keyval, "Use_Agreement", "RECEIVED");
  msiAssociateKeyValuePairsToObj(*Keyval,*User,"-u");
  writeLine("stdout", "Set use agreement for *User");
}
INPUT *User = "rwmoore"
OUTPUT ruleExecOut
