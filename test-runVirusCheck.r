runVirusCheck {
# use clamscan to check for viruses
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Relcoll";
  *Q0 = select DATA_NAME where COLL_NAME = '*Coll';
  foreach (*R0 in *Q0) {
    *File = *R0.DATA_NAME;
    *Path = "*Coll/*File";
    *Res = "LTLResc";
    *Q1 = select DATA_PATH where DATA_NAME = '*File' and COLL_NAME = '*Coll';
    foreach (*R1 in *Q1) {*Objpath = *R1.DATA_PATH;}
    acScanFileAndFlagObject (*Objpath, *Path, *Res);
    *Q2 = select META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE where DATA_NAME = '*File' and COLL_NAME = '*Coll' and META_DATA_ATTR_NAME like 'VIRUS_SCAN%';
    foreach (*R2 in *Q2) {
      *Nam = *R2.META_DATA_ATTR_NAME;
      *Val = *R2.META_DATA_ATTR_VALUE;
      writeLine ("stdout", "*Nam  *Val");
    }
  }
}
INPUT *Relcoll =$"test"
OUTPUT ruleExecOut
