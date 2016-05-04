missingQuota {
# sils-missing-quota.r
  *rs = select USER_ID, USER_NAME;
  *Count = 0;
  foreach(*Row in *rs){
    *Usr = *Row.USER_ID;
    *Name = *Row.USER_NAME;
# get quota
    *Q = select count(QUOTA_USER_ID) where QUOTA_USER_ID = *Usr;
    foreach(*R in *Q) {
      *User = *R.QUOTA_USER_ID;
      if(*User == "0") {
        writeLine("stdout", "No quota for *Name");
        *Count = *Count + 1;
      }
    }
  }
  writeLine("stdout", "Missing quotas for *Count users");
}
input null
output ruleExecOut
