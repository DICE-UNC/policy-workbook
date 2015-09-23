setAccessApproval {
# hipaa-check-access-approval.r
# The rule checks the ACCESS_APPROVAL flag on files in a collection
  checkCollInput (*Coll);
  *Q1 = select DATA_NAME, DATA_ID, COLL_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *FileId = *R1.DATA_ID;
    *Coll1= *R1.COLL_NAME;
    *Path = "*Coll1/*File";
    *Q2 = select META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE where COLL_NAME = *Coll1 and DATA_NAME = *File;
    *Count = 0;
    foreach(*R2 in *Q2) {
      *Name = *R2.META_DATA_ATTR_NAME;
      *Val = *R2.META_DATA_ATTR_VALUE;
      if(*Name == "ACCESS_APPROVAL") {
        *Count = 1;
        if(*Val != "0") {
          writeLine("stdout","*Path has ACCESS_APPROVAL != 0”);
          break;
        }
      }
    }
    if (*Count == 0) {
      writeLine("stdout", "*Path has no ACCESS_APPROVAL”);
    }
  }
}
INPUT *Coll = "/UNC-CH/home/HIPAA/Archives"
OUTPUT ruleExecOut
