integrityACL {
# rda-integrityACL.r
#Rule to analyze files in a collection
#  Verify that a specific ACL is present on each file in collection
#Input
#  Collection that will be analyzed
#  Name of person to check for presence of ACL on file
#  Required ACL value, expressed as an integer
#Output
#  Names of files that are missing the required ACL
# Generate home collection name for user running the rule
  *Coll= "/$rodsZoneClient/home/$userNameClient/" ++ *Coll;

  #Verify input path is a collection
  checkCollInput (*Coll);
  checkUserInput (*User, $rodsZoneClient);
  #Get USER_ID for the input user name
  *Query = select USER_ID where USER_NAME = '*User';
  *Userid = "";
  foreach(*Row in *Query) {
    *Userid = *Row.USER_ID;
  }

  #Get DATA_ACCESS_DATA_ID number that corresponds to requested access control
  *Query2 = select TOKEN_ID where TOKEN_NAMESPACE = 'access_type' and TOKEN_NAME = '*Acl';
  foreach(*Row2 in *Query2) {
    *Access = *Row2.TOKEN_ID;
  }
  writeLine("stdout", "Access control number of *Acl is *Access");
  *Count = 0;
 
  #Loop over files in the collection
  *Query3 = select DATA_ID,DATA_NAME where COLL_NAME = '*Coll';
  foreach(*Row3 in *Query3) {
    *Dataid = *Row3.DATA_ID;
    *File = *Row3.DATA_NAME;
    *Path = *Coll ++ "/" ++ *File
    #Find ACL for each file
    *Query4 = select DATA_ACCESS_TYPE, DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = '*Dataid';

    #Loop over access controls for each file
    *Attrfound = 0;
    foreach(*Row4 in *Query4) {
      *Userdid = *Row4.DATA_ACCESS_USER_ID;
      if(*Userdid == *Userid) {
        *Attrfound = 1;
        *Datatype = *Row4.DATA_ACCESS_TYPE;
        if(*Datatype < *Access) {
          writeLine("stdout", "* Path has wrong access permission, *Datatype");
        }
      } 
    }
    if(*Attrfound == 0) {
      writeLine("stdout", "*Path is missing access controls for  *User");
      *Count = *Count + 1;
    }
  }
  writeLine("stdout", "Number of files in *Coll missing access control for *User is *Count");
}
INPUT *Coll =$"rules", *User=$"rwmoore", *Acl =$"own"
OUTPUT ruleExecOut
