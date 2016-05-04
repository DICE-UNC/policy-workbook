testACL {
# test setting ACL in remote zone
# local zone lifelibZone
# remote zone dfcmain
  msiSetACL( "default", "write", "*User", "/dfcmain/home/rwmoore#lifelibZone/archive/*File");
# see what is set in metadata catalog
  findZoneHostName("dfcmain", *Host, *Port);
  writeLine ("stdout", "*Host : *Port");
  remote (*Host, "<ZONE>dfcmain</ZONE>") {
    writeLine("stdout", "find file /dfcmain/home/rwmoore#lifelibZone/archive");
    msiSplitPathByKey (*User,"#",*Username,*Userzone);
    if (*Userzone == "") { *Userzone = "dfcmain"; }
    writeLine("stdout", "user name *User and zone *Userzone");
    *Q1 = select USER_ID where USER_NAME = '*Username' and USER_ZONE = '*Userzone';
    foreach (*R1 in *Q1) { 
      *Userid = *R1.USER_ID;
      writeLine("stdout", "Found userid *Userid for *User");   
      *Q2 = select DATA_ID where DATA_NAME = '*File' and COLL_NAME = '/dfcmain/home/rwmoore#lifelibZone/archive';
      foreach (*R2 in *Q2) {*Dataid = *R2.DATA_ID;}
      writeLine ("stdout", "Found dataid *Dataid for *File");
      *Q3 = select count(DATA_ACCESS_USER_ID) where DATA_ACCESS_DATA_ID = '*Dataid';
      foreach (*R3 in *Q3) { *Num = *R3.DATA_ACCESS_USER_ID; }
      writeLine ("stdout", "Found *Num access controls");
      if (int(*Num) > 0) {
        *Q4 = select DATA_ACCESS_TYPE, DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = '*Dataid';
        foreach (*R4 in *Q4) {
          *Userdid = *R4.DATA_ACCESS_USER_ID;
          *Datatype = *R4.DATA_ACCESS_TYPE;
          writeLine("stdout", "Found data access user id *Userdid, data access type *Datatype");
          *Q5 = select TOKEN_NAME where TOKEN_NAMESPACE = 'access_type' and TOKEN_ID = '*Datatype';
          foreach (*R5 in *Q5) { *Access = *R5.TOKEN_NAME; }
          *Q6 = select USER_NAME where USER_ID = '*Userdid';
          foreach (*R6 in *Q6) { *Usern = *R6.USER_NAME; }
          writeLine ("stdout", "User *Usern has access control *Access");
        }
      }
    }
  }
}
INPUT *File =$"file2", *User =$"rwmoore#lifelibZone" 
OUTPUT ruleExecOut

