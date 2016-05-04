setAccessApproval {
# hipaa-check-access-approval-flag.r
# The rule checks the ACCESS_APPROVAL flag on files in a collection
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Collrel";
  checkCollInput (*Coll);
  *Q1 = select DATA_NAME, DATA_ID, COLL_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *FileId = *R1.DATA_ID;
    *Coll1= *R1.COLL_NAME;
    *Path = "*Coll1/*File";
    *Count = 0;
    *Q2 = select  META_DATA_ATTR_VALUE where  DATA_ID = *FileId and META_DATA_ATTR_NAME = 'ACCESS_APPROVAL';
    foreach(*R2 in *Q2) {
      *Count = 1;
      *Val = *R2.META_DATA_ATTR_VALUE;
      if(*Val != "0") {
        writeLine("stdout","*Path has ACCESS_APPROVAL = *Val");
      }
    }
    if (*Count == 0) {
      writeLine("stdout", "*Path has no ACCESS_APPROVAL");
    }
  }
}
INPUT *Collrel = "archive"
OUTPUT ruleExecOut
