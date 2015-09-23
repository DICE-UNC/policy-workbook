IntegrityACL {
# rda-acl.r
#Rule to identify access controls on a file in a collection for a specific person
#Input
#  Collection that will be analyzed
#Output
# List of files that the person can access
# Generate home collection name for admin running the rule
  checkUserInput (*User, $rodsZoneClient);
  *Path= "/$rodsZoneClient/home/$userNameClient/*Coll";
  checkCollInput (*Path);

  #Get USER_ID for the input user name
  *Query = select USER_ID where USER_NAME = '*User';
  *Userid = "";
  foreach(*Row in *Query) {
    *Userid = *Row.USER_ID;
  }

  *Query3 = select DATA_ID, DATA_NAME, COLL_NAME where COLL_NAME like '*Path%';
  foreach(*Row3 in *Query3) {
    *Dataid = *Row3.DATA_ID;
    *File = *Row3.DATA_NAME;
    *Col = *Row3.COLL_NAME;
    *Path = *Col ++ "/*File";
    writeLine("stdout","*Col/*File");
    #Find ACL for the file
    *Query4 = select DATA_ACCESS_TYPE, DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = '*Dataid';

    #Loop over access controls for each file
    foreach(*Row4 in *Query4) {
      *Userdid = *Row4.DATA_ACCESS_USER_ID;
      *Datatype = *Row4.DATA_ACCESS_TYPE;
      if(*Userid == *Userdid) {
        *Query5 = select TOKEN_NAME where TOKEN_NAMESPACE = 'access_type' and TOKEN_ID = '*Datatype';
        foreach (*Row5 in *Query5) {*Access = *Row5.TOKEN_NAME;}
        *Query6 = select USER_NAME where USER_ID = '*Userdid';
        foreach (*Row6 in *Query6) {*Usern = *Row6.USER_NAME;}
        writeLine("stdout","    User *Usern has access control *Access");
      }
    }
  }
}

INPUT *Coll =$"rules", *User =$"rwmoore"
OUTPUT ruleExecOut
