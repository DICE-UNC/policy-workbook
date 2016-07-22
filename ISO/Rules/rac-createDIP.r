createDIP = main50
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_DIPS = "DIPS"
GLOBAL_OWNER = "rwmoore"
GLOBAL_STORAGE = "LTLResc"
main50 {
# Policy 50
# rac-createDIP
# create a metadata file that contains all metadata associated with an AIP
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_ARCHIVES;
  *Path = "*Coll/*Aip";
  *Buf = "Create a DIP";
  msiGetDataObjAIP (*Path, *Buf);
  *Dest = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_DIPS;
  isColl (*Dest, "stdout", *Stat);
  *Path = "*Dest/*Aip-meta";
  *Res = GLOBAL_STORAGE;
  *Per = GLOBAL_OWNER;
# create the DIP
  *Dfile = "destRescName=*Res++++forceFlag=";
  msiDataObjCreate(*Path, *Dfile, *L_FD);
  msiDataObjWrite(*L_FD, *Buf, *Wlen);
  msiDataObjClose(*L_FD, *Status);
  msiFreeBuffer(*Buf);
  msiDataObjRepl(*Path, "updateRepl=++++verifyChksum=", *Stat);
  msiSetACL("default", "own", *Per, *Path);
}
INPUT *Archive=$"Archive-A", *Aip=$"rec3"
OUTPUT ruleExecOut
