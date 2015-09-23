myTestRule {
# rda-userID.r
#List information about the person running the rule
  *Query = select USER_ID, USER_CREATE_TIME where USER_NAME = '$userNameClient';
  foreach (*Row in *Query) {
    *userid = *Row.USER_ID;
    *usercreate =  *Row.USER_CREATE_TIME;
    *usercreatetime = datetime(double(*usercreate));
    writeLine("stdout", "User: $userNameClient  UserID: *userid  CreateTime: *usercreatetime");
  }
}
INPUT null
OUTPUT ruleExecOut
