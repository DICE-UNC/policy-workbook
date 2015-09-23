myTestRule {
# hipaa-update-user-info.r
# Input parameter is:
#  Path of file containing information
# Output parameter is:
#   Format of the file is
#   user-name|field|new-value
#   hippaAdmin|info|<Training>Course1</Training>
#  Status
  checkPathInput (*Path);
  msiLoadUserModsFromDataObj(*Path,*Status);
  writeLine("stdout", "Change info on a user account");
}
INPUT *Path"/UNC-CH/home/HIPAA/Reports/updateUserInfo"
OUTPUT ruleExecOut
