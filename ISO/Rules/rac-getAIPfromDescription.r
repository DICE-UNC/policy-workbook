getAIPfromDescription {
  racGlobalSet ();
# Policy70
# rac-getAIPfromDescription.r
# get information about an AIP from a term in the Audit-Description
  msiGetSystemTime (*Tim, "human");
  writeLine ("stdout", "Get an AIP with the term *Term on *Tim");
  *Q1 = select DATA_NAME, DATA_ID, DATA_COLL_ID where META_DATA_ATTR_NAME = "Audit-Description" and META_DATA_ATTR_VALUE like "%*Term%";
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Colid = *R1.DATA_COLL_ID;
    *Q3 = select COLL_NAME where COLL_ID = *Colid;
    foreach (*R3 in *Q3) { *Col = *R3.COLL_NAME; }
    *Daid = *R1.DATA_ID;
    writeLine ("stdout", "  *Col/*File has term *Term");
    *Q2 = select META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE where DATA_ID = *Daid;
    foreach (*R2 in *Q2) {
      *At = *R2.META_DATA_ATTR_NAME;
      *Va = *R2.META_DATA_ATTR_VALUE;
      writeLine ("stdout", "  *At    :    *Va");
    }
  }
# find the archive holding the record
  racSplitArchive (*Col, *Archive);
  racWriteManifest ("Archive-PAA", *Archive, "stdout");
}
racWriteManifest( *OutFile, *Rep, *Source ) {
# create manifest file
  *Coll = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_MANIFESTS;
  *Res = GLOBAL_STORAGE;
  isColl (*Coll, "stdout", *Status);
  isData (*Coll, *OutFile, *Status);
  *Lfile = "*Coll/*OutFile";
  if (*Status == "0") {
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
racGlobalSet = maing
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_DIPS = "DIPS"
GLOBAL_EMAIL = "rwmoore@renci.org"
GLOBAL_IMAGES = "Images"
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
racSplitArchive (*Coll, *Archive) {
# find the name of an archive in a collection path
  *Head = GLOBAL_ACCOUNT ++ "/";
  *La = strlen (*Head);
  *Lc = strlen (*Coll);
  *Archive = "";
  for (*I = *La; *I < *Lc; *I=*I+1) {
    *C = substr (*Coll, *I, *I+1);
    if (*C == "/") {
      *Archive = substr (*Coll, *La, *I);
      break;
    }
  }
# verify the name is correct
  *Coll = *Head ++ GLOBAL_REPOSITORY;
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_NAME = "Repository-Archives";
  *Found = 0;
  foreach (*R1 in *Q1) {
    *Nam = *R1.META_COLL_ATTR_VALUE;
    if (*Nam == *Archive) {
      *Found = 1;
      break;
    }
  }
  if (*Found == 0) { *Archive = ""; }
}
INPUT *Term=$"Height"
OUTPUT ruleExecOut
