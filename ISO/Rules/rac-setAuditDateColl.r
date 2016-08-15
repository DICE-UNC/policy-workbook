setAuditDateColl {
  racGlobalSet ();
# Policy80
# rac-setAuditDateColl.r
# set the attribute Audit-Date on files in a collection for file missing an Audit-Date
  *Rep = "";
  *Doc = "Archive-PAA";
  splitPathByKey (*RelColl, "/", *Archive, *Tail);
  if (*Archive == GLOBAL_REPOSITORY) { *Rep = *Archive; }
  else {
    racCheckArchive (*Archive, *Stat);
    if (*Stat == "0") { *Rep = *Archive; }
  }
  msiGetSystemTime (*Tim, "human");
  *Coll = GLOBAL_ACCOUNT ++ "/*RelColl";
  writeLine ("stdout", "Set the attribute Audit-Date on files in *Coll on *Tim");
  msiGetSystemTime (*Tim, "unix");
  *Period = double(*Days) * 3600. * 24.;
  *New = str(double(*Tim) + *Period);
  *Q1 = select DATA_NAME, COLL_NAME where COLL_NAME like "*Coll%";
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Col = *R1.COLL_NAME;
    *Path = "*Col/*File";
    *Q2 = select count(META_DATA_ATTR_ID) where DATA_NAME = *File and COLL_NAME = *Col and META_DATA_ATTR_NAME = "Audit-Date";
    foreach (*R2 in *Q2) {
      *Num = *R2.META_DATA_ATTR_ID;
      if (*Num == "0" ) {
        addAVUMetadata (*Path, "Audit-Date", *New, "", *Status);
        *Date = timestrf(datetime(double(*New)), "%Y %m %d");
        writeLine ("stdout", "  New Audit-Date for *Path is *Date");
      }
    }
  }
  if (*Rep != "") { racWriteManifest (*Doc, *Archive, "stdout"); }
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
racCheckArchive (*Archive, *Stat) {
# check whether a valid archive is specified
  *Coll = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
  *Q1 = select count(META_COLL_ATTR_ID) where COLL_NAME = *Coll and META_COLL_ATTR_NAME = "Repository-Archives" and META_COLL_ATTR_VALUE = *Archive;
  *Stat = "1";
  foreach (*R1 in *Q1) { *Num = *R1.META_COLL_ATTR_ID; }
  if (*Num >= "1") {*Stat = "0"; }
}
splitPathByKey(*Name, *Delim, *Head, *Tail) {
# construct a path split function
  *L = strlen(*Name);
  *Head = *Name;
  *Tail = "";
  for (*i=0; *i<*L; *i=*i+1) {
    *C = substr(*Name, *i, *i+1);
    if (*C == *Delim) {
      *Head = substr(*Name, 0, *i);
      *Tail = substr(*Name, *i+1, *L);
      break;
    }
  }
}
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

INPUT *RelColl=$"Archive-A/Reports", *Days=$"365"
OUTPUT ruleExecOut
