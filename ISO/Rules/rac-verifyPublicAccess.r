verifyPublicAccess = main24
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_REPOSITORY = "Repository"
main24 {
# rac-verifyPublicAccess.r
# Policy24
# list the access permissions on the collection GLOBAL_REPOSITORY
  *Coll = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
  *lacc.totalPersons = str(0);
  *Q1 = select COLL_OWNER_NAME, COLL_ID where COLL_NAME = "*Coll";
  foreach (*R1 in *Q1) { 
    *CollID = *R1.COLL_ID;
    *Owner = *R1.COLL_OWNER_NAME;
  }
  writeLine ("stdout", "Owner of *Coll is *Owner");
  writeLine ("stdout", "Name            Number of access permissions");
  *Q2 = select COLL_ACCESS_USER_ID, COLL_ACCESS_TYPE where COLL_ACCESS_COLL_ID = *CollID;
  foreach (*R2 in *Q2) {
    *Userid = *R2.COLL_ACCESS_USER_ID;
    *Type = *R2.COLL_ACCESS_TYPE;
    *Q3 = select USER_NAME where USER_ID = '*Userid';
    foreach (*R3 in *Q3) {*Name = *R3.USER_NAME;}
    if (!contains(*lacc, *Name)) {
      *lacc.*Name = str(1);
      *lacc.totalPersons = str(int(*lacc.totalPersons) + 1);
    }
    *Q4 = select count(USER_NAME) where USER_GROUP_ID = '*Userid';
    foreach (*R4 in *Q4) {
      *Num = *R4.USER_NAME;
      if(int(*Num) > 1) {
        *Q5 = select USER_NAME where USER_GROUP_ID = '*Userid';
        foreach (*R5 in *Q5) {
          *Usg = *R5.USER_NAME;
          if (*Usg != *Name) {
            if (contains(*lacc, *Usg)) {
              *lacc.*Usg = str(int(*lacc.*Usg) + 1);
            } else {
              *lacc.*Usg = str(1);
              *lacc.totalPersons = str(int(*lacc.totalPersons) + 1);
            }
          }
        }
      }
    }
  }
  foreach (*L in *lacc) {
    *C1 = *L;
    *C2 = *lacc.*L;
    if (strlen(*C1) < 8) {*C1 = "*C1\t";}
    if (strlen(*C1) < 16) {*C1 = "*C1\t";}
    writeLine("stdout", "*C1   *C2");
  }
}
INPUT null
OUTPUT ruleExecOut
