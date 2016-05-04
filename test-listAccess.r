listAccess {
# rule is test-listAccess.r
# Identify users who have access to a collection
  *Coll = "/$rodsZoneClient/home/$userNameClient/*RelColl";
  writeLine("stdout", "Name            Number of entries");
  *lacc.totalPersons = str(0);
  checkCollInput (*Coll);
  *Q1 = select DATA_NAME, DATA_ID where COLL_NAME = '*Coll';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *DataID = *R1.DATA_ID;
    *Q2 = select DATA_ACCESS_USER_ID, DATA_ACCESS_TYPE where DATA_ACCESS_DATA_ID = '*DataID';
    foreach (*R2 in *Q2) {
      *Userid = *R2.DATA_ACCESS_USER_ID;
      *Type = *R2.DATA_ACCESS_TYPE;
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
  }
  foreach (*L in *lacc) {
    *C1 = *L;
    *C2 = *lacc.*L;
    if (strlen(*C1) < 8) {*C1 = "*C1\t";}
    if (strlen(*C1) < 16) {*C1 = "*C1\t";}
    writeLine("stdout", "*C1   *C2");
  }
}
INPUT *RelColl="Reports"
OUTPUT ruleExecOut
