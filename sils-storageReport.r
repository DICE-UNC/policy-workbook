main {
# sils-storageReport.r
  *rs = select USER_ID, USER_NAME;
  *Total = 0.0;
  *Max = 0.0;
  foreach(*Row in *rs){
    *Usr = *Row.USER_ID;
    *Name = *Row.USER_NAME;
# get quota
    *Query1 = select sum(QUOTA_USAGE) where QUOTA_USAGE_USER_ID = *Usr;
    foreach(*Row1 in *Query1) {
      *Use = double(*Row1.QUOTA_USAGE);
      if (*Use > 0.0) {
        *Gb = *Use/(1024.*1024.*1024.);
        writeLine("stdout", "Usage is *Gb Gbytes by *Name");
        *Total = *Total + *Use;
      }
      if(*Use >= *Max) {
        *Max = *Use;
        *Usem = *Name;
      }
    }
  }
  writeLine("stdout", "Total usage is *Total bytes");
  writeLine("stdout", "Maximum usage is *Max bytes by *Usem");
}
input null
output ruleExecOut
