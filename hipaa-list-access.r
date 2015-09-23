main {
# rule is hipaa-list-access.r
# Identify users who have access to a collection
  checkCollInput (*Coll);
  *Q1 = select DATA_NAME, DATA_ID where COLL_NAME = "*Coll";
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *DataID = *R1.DATA_ID;
    *Q2 = select DATA_ACCESS_USER_ID, DATA_ACCESS_TYPE where DATA_ACCESS_DATA_ID = '*DataID';
    foreach (*R2 in *Q2) {
      *Userid = *R2.DATA_ACCESS_USER_ID;
      *Type = *R2.DATA_ACCESS_TYPE;
      *Q3 = select USER_NAME where USER_ID = '*Userid';
      foreach (*R3 in *Q3) {*Name = *R3.USER_NAME;}
      writeLine("stdout","*Name has access to *File in *Coll");
    }
  }
}
input *Coll = "/dfcmain/home/rwmoore/test"
output ruleExecOut
