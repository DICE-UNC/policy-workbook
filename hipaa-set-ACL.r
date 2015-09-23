setACL {
# hipaa-set-ACL.r
# For each file with META_DATA_ATTR_NAME = ACL_EXPIRY
#  Check value for whether period is over
#  And set access to public and anonymous
  msiGetSystemTime(*Time, "unix");
  *T = double(*Time);
  *C = "/$rodsZoneClient/home/$userNameClient/" ++ *Coll;
  checkCollInput (*Coll);
  *Query = select DATA_NAME,META_DATA_ATTR_VALUE where COLL_NAME = '*C' and META_DATA_ATTR_NAME = 'ACL_EXPIRY';
  foreach(*Row in *Query) {
    *V = *Row.META_DATA_ATTR_VALUE;
    *Val = double(*V);
    *File = *Row.DATA_NAME
    *Path = *C ++ "/" ++ *File;
    if(*T > *Val) {
#  Time period has elapsed, provide public access
       msiSetACL("default", "read", "public", *Path);
       msiSetACL("default", "read", "anonymous", *Path);
#  Remove the metadata attribute
       *Str1 = "ACL_EXPIRY=*V";
       msiString2KeyValPair(*Str1, *kvp1);
       msiRemoveKeyValuePairsFromObj(*kvp1, *Path, "-d");
       writeLine("stdout", "Changed access to public for *Path");
    }
  }
}
INPUT *Coll=$"test"
OUTPUT ruleExecOut
