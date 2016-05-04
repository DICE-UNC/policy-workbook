testCheckretention {
# test an AVU called DATA_EXPIRATION for a retention period
  *Collhome = "/$rodsZoneClient/home/$userNameClient";
  *Coll = "*Collhome/*Relcoll";
  msiGetSystemTime (*Tim, "unix");
  *Q1 = select META_DATA_ATTR_VALUE where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = 'DATA_EXPIRATION';
  foreach (*R1 in *Q1) {
    *Val = double(*R1.META_DATA_ATTR_VALUE);
    if (double(*Tim) > *Val) {
      *Th = timestrf(datetime(*Val), "%Y %m %d");
      writeLine ("stdout", "*Coll/*File retention period has expired, *Th");
    }
  }
}
INPUT *Relcoll="test", *File="file1.txt"
OUTPUT ruleExecOut
  
