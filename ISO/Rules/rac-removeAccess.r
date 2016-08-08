removeAccess {
  racGlobalSet ();
# Policy30
# rac-removeAccess.r
# set access permission to null for specified account
# records changes in a manifest file, Archive-ALRA
  *Home = GLOBAL_ACCOUNT;
  *Coll = "*Home/*Rep/" ++ GLOBAL_ARCHIVES;
# check if access exists on collection
  msiGetSystemTime (*Tim, "human");
#Get USER_ID for the input user name
  *Query = select USER_ID where USER_NAME = '*Acc';
  *Userid = "";
  foreach(*Row in *Query) { *Userid = *Row.USER_ID; }
  if(*Userid == "") {
    writeLine("stdout", "Input user name *User is unknown");
    fail;
  }
  else {writeLine("stdout", "On *Tim, removing access for User *Acc for  account ID  *Userid");}
# loop over subcollections
  *Q1 = select COLL_ID, COLL_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *C = *R1.COLL_NAME;
    *Cid = *R1.COLL_ID;
# find ACL for collection
    *Q2 = select count(COLL_ACCESS_USER_ID) where COLL_ACCESS_COLL_ID = '*Cid' and COLL_ACCESS_USER_ID = *Userid;
    foreach (*R2 in *Q2) {
      *Num = *R2.COLL_ACCESS_USER_ID;
      msiSetACL("default", "null", *Acc, *C);
      writeLine ("stdout", "  Removed access for *Acc from collection *C");
    }
  }
# loop over files in archives
  *rs = select DATA_ID, DATA_NAME, COLL_NAME where COLL_NAME like '*Coll%';
  foreach(*r in *rs) {
    *fn = *r.DATA_ID;
    *File = *r.DATA_NAME;
    *C = *r.COLL_NAME;
# Find ACL for the file
    *Query4 = select count(DATA_ACCESS_USER_ID) where DATA_ACCESS_DATA_ID = '*fn' and DATA_ACCESS_USER_ID = *Userid;
# Loop over access controls for each file
    foreach(*Row4 in *Query4) {
      *Num = *Row4.DATA_ACCESS_USER_ID;
      if (int(*Num) > 0) {
        *Path = "*C/*File";
        msiSetACL("default", "null", *Acc, *Path);
        writeLine ("stdout", "  Removed access for *Acc from file *Path");
      }
    }
  }
  racWriteManifest( "Archive-ALRA", *Rep, "stdout" );
}
racGlobalSet = maing
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_DIPS = "DIPS"
GLOBAL_EMAIL = "rwmoore@renci.org"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_METADATA = "Metadata"
GLOBAL_OWNER = "rwmoore"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_RULES = "Rules"
GLOBAL_SIPS = "SIPS"
GLOBAL_STORAGE = "LTLResc"
GLOBAL_VERSIONS = "Versions"
maing{}
racWriteManifest( *OutFile, *Rep, *Source ) {
# create manifest file
  *Coll = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_MANIFESTS;
  *Res = GLOBAL_STORAGE;
  isColl (*Coll, "stdout", *Status);
  isData (*Coll, *OutFile, *Status);
  *Lfile = "*Coll/*OutFile";
  if (*Status == "0") {
# create manifest file
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
    msiDataObjClose (*L_FD, *Status);
  }
# update manifest file with information from *Source
  msiDataObjOpen("objPath=*Lfile++++openFlags=O_RDWR", *L_FD);
  msiDataObjLseek(*L_FD, "0", "SEEK_END", *Status);
  msiDataObjWrite(*L_FD, *Source, *Wlen);
  msiDataObjClose(*L_FD, *Status);
  msiDataObjRepl(*Lfile, "updateRepl=++++verifyChksum=", *Stat);
}
INPUT *Acc=$"public", *Rep=$"Archive-A"
OUTPUT ruleExecOut

