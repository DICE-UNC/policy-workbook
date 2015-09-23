ruleStorage {
# rda-storage.r
# Total the size of files on each storage vault for each user
# Get list of users
  *Quser = select USER_NAME;
  *Totsize = 0.0;
  *Totnum = 0;
  *Numusers = 0;
  foreach (*Row in *Quser) {
    *Numusers = *Numusers + 1;
    *User = *Row.USER_NAME;
    *Path = "/$rodsZoneClient/home/*User/%";
    *Q = select sum(DATA_SIZE),count(DATA_ID), DATA_RESC_NAME where COLL_NAME like '*Path';
    foreach (*R in *Q) {
      *Size = double(*R.DATA_SIZE)/1024./1024./1024.;
      *Num = *R.DATA_ID;
      *V = *R.DATA_RESC_NAME;
      if(*Size > 0.) {
        writeLine ("stdout", "    Storage on *V is *Size GBytes, Number of files is *Num, *User");
        *Totsize = *Totsize + *Size;
        *Totnum = *Totnum + int(*Num);
      }
    }
  }
  writeLine("stdout", "Total storage is *Totsize GBytes for *Totnum files for *Numusers");
}
INPUT null
OUTPUT ruleExecOut
