myTestRule {
# hipaa-accountImport.r
# Input parameters are:
#  Path
#   File format for user accounts is
#     User-name|User-ID|User-type|Zone|
#     guest|001|rodsuser|tempZone|
# Output parameter is:
#  Status
  checkPathInput (*Path);
  msiCreateUserAccountsFromDataObj(*Path,*Status);
  writeLine("stdout", "Add user accounts defined in file *Path");
}
INPUT *Path="/$rodsZoneClient/home/$userNameClient/Accounts/Account-2015-08-27.22:12:56"
OUTPUT ruleExecOut
