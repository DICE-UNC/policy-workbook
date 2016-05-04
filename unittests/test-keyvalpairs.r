testKeyVlaPairs {
# add two key value pairs
  *Path = "/$rodsZoneClient/home/$userNameClient/*File";
  msiAddKeyVal(*Keyval, "row2col1", "384");
  msiAddKeyVal(*Keyval, "row2col2", "9");
  msiAssociateKeyValuePairsToObj(*Keyval,*Path,"-d");
}
INPUT *File="foo1"
OUTPUT ruleExecOut
