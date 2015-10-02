CopyfileACLAVU {
# odum-copy-ACL-AVU.r
# rule to set ACL and AVU as copy files to an archive collection
  checkRescInput (*Res, *DestZone);
# Loop over files in a staging area, /$rodsZoneClient/home/$userNameClient/*stage
# Put all files into collection /*DestZone/home/$userNameClient#$rodsZoneClient/*Coll
  *Src = "/$rodsZoneClient/home/$userNameClient/*Stage";
  *Dest= "/*DestZone/home/$userNameClient" ++ "#$rodsZoneClient/" ++ *Coll;
  checkCollInput (*Src);
  checkCollInput (*Dest);
  createLogFile(*Dest, "log", "Check", *Res, *LPath, *Lfile, *L_FD);
 
#Get USER_ID for the input user name
  *Query = select USER_ID where USER_NAME = '$userNameClient';
  *Userid = "";
  foreach(*Row in *Query) {
    *Userid = *Row.USER_ID;
  }
  if(*Userid == "") {
    writeLine("stdout","Input user name *User is unknown");
    fail;
  }

#============ find files to stage
  *Query = select DATA_NAME, DATA_ID where COLL_NAME = '*Src';
  foreach(*Row in *Query) {
    *File = *Row.DATA_NAME;
    *Sdataid = *Row.DATA_ID;
    *Src1 = *Src ++ "/" ++ *File;
    *Dest1 = *Dest ++ "/" ++ *File;
#Check whether file already exists
    *Query1 = select count(DATA_ID) where COLL_NAME = '*Dest' and DATA_NAME = '*File';
    foreach(*Row1 in *Query1) {*DataID = *Row1.DATA_ID;}
# Move file and set access permission
    if(*DataID == "0") {
      msiDataObjCopy(*Src1,*Dest1,"destRescName=*Res", *Status);
      msiSetACL("default","own",$userNameClient, *Dest1);
# copy ACLs
#Find ACL for the file
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
INPUT *Stage =$"stage", *Coll=$"Archive", *DestZone=$"tempZone", *Res=$"demoResc"
OUTPUT ruleExecOut

