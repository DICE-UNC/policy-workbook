checkGroup {
# dmp-check-group.r
# List the persons that can access a collection
  checkCollInput (*Coll);
  writeLine("stdout", "Collection *Coll can be manipulated by");
  *Q1 = select COLL_ID where COLL_NAME = '*Coll';
  foreach (*R1 in *Q1) {*CollID = *R1.COLL_ID;}
  *Q2 = select COLL_ACCESS_USER_ID, COLL_ACCESS_TYPE where COLL_ACCESS_COLL_ID = '*CollID';
  foreach (*R2 in *Q2) {
    *UserID = *R2.COLL_ACCESS_USER_ID;
    *Type = *R2.COLL_ACCESS_TYPE;
    *Q5 = select TOKEN_NAME where TOKEN_NAMESPACE = 'access_type' and TOKEN_ID = '*Type';
    foreach (*R5 in *Q5) {*Access = *R5.TOKEN_NAME;}
    if (*Access == 'own' || *Access == 'create object') {
      *Q3 = select USER_NAME where USER_ID = '*UserID';
      foreach (*R3 in *Q3) {
        *Usr = *R3.USER_NAME;
        writeLine("stdout","    *Usr");
      }
      *Q6 = select count(USER_NAME) where USER_GROUP_ID = '*UserID';
      foreach (*R6 in *Q6) {
        *Nsg = *R6.USER_NAME;
        if(int(*Nsg) > 1) {
          *Q7 = select USER_NAME where USER_GROUP_ID = '*UserID';
          foreach (*R7 in *Q7) {
            *Usg = *R7.USER_NAME;
            writeLine("stdout", "        *Usg");
          }
        }
      }
    }
  }
}
INPUT *Coll = '/dfcmain/home/rwmoore/rules'
OUTPUT ruleExecOut
