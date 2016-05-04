testInherit {
# turn on inheritance on a collection
  msiSetACL ("recursive", "inherit", "", "/lifelibZone/home/mweshy/Class-INLS624");
  writeLine ("stdout", "Set inheritance on collection Class-INLS624 for rwmoore");
}
INPUT null
OUTPUT ruleExecOut
