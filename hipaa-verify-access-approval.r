AccessCheck {
# hipaa-verify-access-approval.r
# The rule checks the ACCESS_APPROVAL flag on each collection
# If the value is "0", public and anonymous access is removed for all files in the collection
# Get USER_ID corresponding to public and anonymous accounts
  *Qa = select USER_ID where USER_NAME = 'public';
  foreach(*Ra in *Qa) {*UserIdPublic = *Ra.USER_ID;}
  *Qb = select USER_ID where USER_NAME = 'anonymous';
  foreach(*Rb in *Qb) {*UserIdAnon = *Rb.USER_ID;}
  writeLine("stdout", "UserID for public is *UserIdPublic");
  writeLine("stdout", "UserID for anonymous is *UserIdAnon");
# get all collection names where ACCESS_APPROVAL is set
  *Q = select COLL_NAME where META_COLL_ATTR_NAME = "ACCESS_APPROVAL" and META_COLL_ATTR_VALUE = '0';
  foreach (*R in *Q) {
    *Coll = *R.COLL_NAME;
# Get list of files in the collection
    *Q1 = select DATA_ID, DATA_NAME where COLL_NAME = '*Coll';
    foreach(*R1 in *Q1) {
      *FileId = *R1.DATA_ID;
# Check for public access on file
      *Q2 = select DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = '*FileId';
      foreach (*R2 in *Q2) {
        *UserId = *R2.DATA_ACCESS_USER_ID;
        if (*UserId == *UserIdPublic) {
          *File = *R1.DATA_NAME;
          *Path = "*Coll/*File" ;
          msiSetACL("default", "null",  "public", *Path);
          writeLine("stdout", "Reset access for public in *File in *Coll");
        }
        if (*UserId == *UserIdAnon) {
          *File = *R1.DATA_NAME;
          *Path = "*Coll/*File";
          msiSetACL("default", "null", "anonymous", *Path);
          writeLine("stdout", "Reset access for anonymous in *File in *Coll");
        }
      }
    }
  }
}
INPUT null
OUTPUT ruleExecOut
