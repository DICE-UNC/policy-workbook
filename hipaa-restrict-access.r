restrictAccess {
# hipaa-restrict-access.r
# The rule sets the ACCESS_APPROVAL flag to 0 on files in a collection
# Public and anonymous access is removed for all files in the collection
# Get USER_ID corresponding to public and anonymous accounts
  checkCollInput (*Coll);
  *Qa = select USER_ID where USER_NAME = 'public';
  foreach(*Ra in *Qa) {*UserIdPublic = *Ra.USER_ID;}
  *Qb = select USER_ID where USER_NAME = 'anonymous';
  foreach(*Rb in *Qb) {*UserIdAnon = *Rb.USER_ID;}
  writeLine("stdout", "UserID for public is *UserIdPublic");
  writeLine("stdout", "UserID for anonymous is *UserIdAnon");
  *Q1 = select DATA_NAME, DATA_ID, COLL_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *FileId = *R1.DATA_ID;
    *Coll1= *R1.COLL_NAME;
    *Path = "*Coll1/*File";
    *Q2 = select META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE where COLL_NAME = '*Coll1' and DATA_NAME = '*File';
    *Count = 0;
    foreach(*R2 in *Q2) {
      *Name = *R2.META_DATA_ATTR_NAME;
      *Val = *R2.META_DATA_ATTR_VALUE;
      if(*Name == "ACCESS_APPROVAL") {
        *Count = *Count + 1;
        if(*Val != "0") {
# remove old ACCESS_APPROVAL flag
          deleteAVUMetadata (*Path, "ACCESS_APPROVAL", *Val, "", *Status);
# Set ACCESS_APPROVAL flag to 0
          if (*Count == 1) {
            addAVUMetadata (*Path, "ACCESS_APPROVAL", "0", "", *Status);
            writeLine("stdout", "Set ACCESS_APPROVAL for *Coll1/*File");
          }
        }
      }
    }
    if (*Count == 0) {
# Set ACCESS_APPROVAL flag to 0
        addAVUMetadata (*Path, "ACCESS_APPROVAL", "0", "", *Status);
        writeLine("stdout", "Set ACCESS_APPROVAL for *Coll1/*File");
    }
# Check for public access on file
    *Q3 = select DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = '*FileId';
    foreach (*R3 in *Q3) {
      *UserId = *R3.DATA_ACCESS_USER_ID;
      if (*UserId == *UserIdPublic) {
        *File = *R1.DATA_NAME;
        *Path = "*Coll1/*File" ;
        msiSetACL("default", "null", "public", *Path);
        writeLine("stdout", "Restrict access for public in *File in *Coll1");
      }
      if (*UserId == *UserIdAnon) {
        *File = *R1.DATA_NAME;
        *Path = "*Coll1/*File";
        msiSetACL("default", "null", "anonymous", *Path);
        writeLine("stdout", "Restrict access for anonymous in *File in *Coll1");
      }
    }
  }
}
INPUT *Coll = "/UNC-CH/home/HIPAA/Archives"
OUTPUT ruleExecOut
