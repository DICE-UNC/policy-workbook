setDisposition {
# test-setDisposition.r
# The rule sets the DISPOSITION flag to 1 on files in a collection to indicate processing should be done
  checkCollInput (*Coll);
  *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Q2 = select count(META_DATA_ATTR_VALUE) where META_DATA_ATTR_NAME = 'DISPOSITION' and DATA_NAME = '*File' and COLL_NAME = '*Coll';
    foreach (*R2 in *Q2) {
      *Num = *R2.META_DATA_ATTR_VALUE;
    }
    if (int(*Num) > 0) {
      *Q3 = select META_DATA_ATTR_VALUE where META_DATA_ATTR_NAME = 'DISPOSITION' and DATA_NAME = '*File' and COLL_NAME = '*Coll';
      foreach (*R3 in *Q3) {
        *Val = *R3.META_DATA_ATTR_VALUE;
        *Str = "DISPOSITION=*Val";
        msiString2KeyValPair(*Str,*Kvp);
        msiRemoveKeyValuePairsFromObj(*Kvp,"*Coll/*File", "-d");
      }
    }
    *Str1 = "DISPOSITION=1";
    msiString2KeyValPair(*Str1,*Kvp1);
    msiAssociateKeyValuePairsToObj(*Kvp1, "*Coll/*File", "-d");
  }
}
INPUT *Coll =$"/$rodsZoneClient/home/$userNameClient/test"
OUTPUT ruleExecOut

