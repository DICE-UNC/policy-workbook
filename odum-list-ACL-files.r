deleteAccess {
# odum-list-ACL-files.r
# rule to list access on all files in a collection for designated account
  checkUserInput (*Usern, $rodsZoneClient);
  *c = "/$rodsZoneClient/home/$userNameClient";
  *Q = select USER_ID where USER_NAME = '*Usern';
  foreach (*r1 in *Q) {*Userid = *r1.USER_ID;}
# loop over files in home collection
  *Coll = "*c%";
  writeLine("stdout","User *Usern has access to the following files");
  *rs = select DATA_ID, DATA_NAME, COLL_NAME where COLL_NAME like '*Coll';
  foreach(*r in *rs) {
    *fn = *r.DATA_ID;
    *Coll = *r.COLL_NAME;
    *File = *r.DATA_NAME;
    *Path = "*Coll/*File";
# Find ACL for the file
    *Query4 = select DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = '*fn';
# Loop over access controls for each file
    foreach(*Row4 in *Query4) {
      *Userdid = *Row4.DATA_ACCESS_USER_ID;
      if(*Userid == *Userdid) {
        writeLine("stdout","*Path");
      }
    }
  }
}
INPUT *Usern = "lbrieger"
OUTPUT ruleExecOut
