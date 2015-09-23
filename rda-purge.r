purgeDiskCache {
# rda-purge.r
  checkRescInput (*CacheRescName, $rodsZoneClient);
  checkCollInput (*Collection);
  delay("<PLUSET>30s</PLUSET><EF>24h</EF>") {
    *Q1 = select sum(DATA_SIZE) where RESC_NAME = '*CacheRescName';
    foreach (*R1 in *Q1) {
      *TotalSize = *R1.DATA_SIZE;
    }
    *usedSpace = double(*TotalSize);
    *MaxSpAlwd = *MaxSpAlwdTBs * 1024^4;
    if ( *usedSpace > *MaxSpAlwd ) then {
      msiGetIcatTime(*Time, "unix");
      *Q2 = select DATA_NAME, COLL_NAME, DATA_SIZE, order(DATA_CREATE_TIME) where DATA_RESC_NAME = '*CacheRescName' AND COLL_NAME like '*Collection%';
      foreach (*R2 in *Q2) {
        *D = *R2.DATA_NAME;
        *C = *R2.COLL_NAME;
        *S = *R2.DATA_SIZE;
        *usedSpace = *usedSpace - double(*S);
        if ( *usedSpace < *MaxSpAlwd ) {
          break;
        }
        msiDataObjTrim(*C/*D,"*CacheRescName”, “null”, “1”, “1",*status);
        writeLine("stdout”, “*C/*D on *CacheRescName has been purged");
      }
      if ( *usedSpace < *MaxSpAlwd ) {
        break;
      }
    }
  }
}
input *MaxSpAlwdTBs = $1, *Collection = "/tempZone", *CacheRescName = "demoResc"
output ruleExecOut
