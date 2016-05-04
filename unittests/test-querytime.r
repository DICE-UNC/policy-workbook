testquery {
  *Coll = "/$rodsZoneClient/home/$userNameClient%";
  *Per = 24. * 3600.;
  msiGetSystemTime (*Tim, "unix");
  *Q1 = select DATA_NAME, COLL_NAME, DATA_CREATE_TIME where COLL_NAME like *Coll;
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Coll = *R1.COLL_NAME;
    *Date = double (*R1.DATA_CREATE_TIME);
    if (*Tim - *Date <= *Per) {
      writeLine ("stdout", "File created in the last day *Coll / *File");
    }
  }
}
INPUT null
OUTPUT ruleExecOut
