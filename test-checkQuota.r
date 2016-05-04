testcheckQuota {
# test-checkQuota.r
# Calculate storage quota for your collection
  *Q0 = select USER_ID where USER_NAME = '$userNameClient';
  foreach (*R0 in *Q0) {
    *Uid = *R0.USER_ID;
    *Q = select QUOTA_OVER where QUOTA_USER_ID = *Uid;
    foreach(*R in *Q) {
      *Over = -double(*R.QUOTA_OVER)/1024./1024./1024.;
    }
# get usage
    *Q2 = select sum(QUOTA_USAGE) where QUOTA_USAGE_USER_ID = *Uid;
    foreach(*R2 in *Q2) {
      *Usage = double(*R2.QUOTA_USAGE)/1024./1024./1024.;
    }
  }
  *Quota = (*Over + *Usage);
  *Usname = "$userNameClient\t";
  writeLine("stdout","*Usname has Quota *Quota GBytes and has used *Usage GBytes");
  if(*Over < 0.0) {
    writeLine("stdout", "Quota *Quota GBytes exceeded by *Usname, Usage is *Usage GbBytes");
  }
}
INPUT null 
OUTPUT ruleExecOut
