CopyACLAVU {
# hipaa-acl-AVU-copy.r
#Rule to copy  access controls and AVUs to a file in a collection
#Input
#  Collection that will be used as source
#  Zone that will receive copies of AVUs and ACLs
#Policy assumes that the account names are the same for both src and dest
#Output
#  List of files that were updated
# Generate home collection name for user running the rule
  *Collsrc= "/$rodsZoneClient/home/$userNameClient/" ++ *Coll;
  *Colldest = "/*Zone/home/$userNameClient" ++ "#" ++ "$rodsZoneClient" ++ "/" ++ *Coll;

  #Verify input path is a collection
  checkCollInput (*Collsrc);
 
  #Verify output path is a collection
  checkCollInput (*Colldest);

  *Query3 = select DATA_NAME, DATA_ID where COLL_NAME = '*Collsrc';
  foreach(*Row3 in *Query3) {
    *File = *Row3.DATA_NAME;
    *Sdataid = *Row3.DATA_ID;
    *Pathsrc = *Collsrc ++ "/" ++ *File;
    *Pathdest = *Colldest ++ "/" ++ *File;
# verify destination file exists
    isData (*Colldest, *File, *Status);
    *Status1 == "0";
    if (*Status == "0" ) {
      writeLine("stdout","Destination file *Pathdest does not exist");
      msiDataObjCopy(*Pathsrc, *Pathdest, "verifyChksum=", *Status1);
    }
    if (*Status1 == "0") {
      msiSetACL("default","own","$userNameClient#$rodsZoneClient", *Dest1);
      *Query4 = select DATA_ACCESS_TYPE, DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = '*Sdataid';
#Loop over access controls for the file
      foreach(*Row4 in *Query4) {
        *Userdid = *Row4.DATA_ACCESS_USER_ID;
        *Datatype = *Row4.DATA_ACCESS_TYPE;
        if(*Userid != *Userdid) {
          *Query5 = select TOKEN_NAME where TOKEN_NAMESPACE = 'access_type' and TOKEN_ID = '*Datatype';
          foreach (*Row5 in *Query5) {*Access = *Row5.TOKEN_NAME;}
          *Query6 = select USER_NAME, USER_ZONE where USER_ID = '*Userdid';
          foreach (*Row6 in *Query6) {
            *Usern = *Row6.USER_NAME;
            *Userz = *Row6.USER_ZONE;
          }
          msiSetACL("default","*Access","*Usern#*Userz", *Dest1);
          writeLine("stdout","*Path has access control *Access for user *Usern");
        }
# copy AVUs
        *Q2 = select META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE, META_DATA_ATTR_UNITS where DATA_ID = '*DataID';
        foreach (*R2 in *Q2) {
          *Attn = *R2.META_DATA_ATTR_NAME;
          *Attv = *R2.META_DATA_ATTR_VALUE;
          *Attu = *R2.META_DATA_ATTR_UNITS;
# This policy uses a micro-service developed by the iPlant Collaborative
          msiSetAVU ("-d", *Dest1, *Attn, *Attv, *Attu);
        }
      }
      writeLine("*Lfile", "Moved file *Src1 to *Dest1");
# Delete file from staging area
      msiDataObjUnlink("objPath=*Src1++++forceFlag=", *Status);
    }
  }
}
INPUT *Coll =$"sub1", *Zone = "tempZone"
OUTPUT ruleExecOut
