ruleStorage {
# rda-storageCost.r
# Total the cost for files on each storage vault for each user
# Get list of users
  *Quser = select USER_NAME;
  foreach (*Row in *Quser) {
    *User = *Row.USER_NAME;
    writeLine("stdout", "Storage for *User");
    *Path = "/$rodsZoneClient/home/*User/%";
    *Q = select sum(DATA_SIZE),DATA_RESC_NAME where COLL_NAME like '*Path';
    foreach (*R in *Q) {
      *Size = *R.DATA_SIZE;
      *V = *R.DATA_RESC_NAME;
      *Qresc = select META_RESC_ATTR_VALUE where RESC_NAME = '*V' and META_RESC_ATTR_NAME = 'Storage_Cost';
      foreach (*Rowc in *Qresc) {
        *Cost = int(*Rowc.META_RESC_ATTR_VALUE);
      }
      *Scost = *Cost * int(*Size);
      writeLine ("stdout", "    Storage cost on *V is *Scost");
    }
  }
}
INPUT null
OUTPUT ruleExecOut
