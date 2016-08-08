setAuditDate {
  racGlobalSet ();
# Policy36
# rac-setAuditDate.r
# set the attribute Audit-Date on a document
# determine where the document is located
# determine whether the report is a manifest or a version
  msiGetSystemTime (*Tim, "human");
  racFindRepColl (*File, *Rep);
  *Coll = GLOBAL_ACCOUNT ++ "/*RelColl/*Rep";
  *Path = "*Coll/*File";
  writeLine ("stdout", "Set the attribute Audit-Date on *Path on *Tim");
  *Q1 = select META_DATA_ATTR_VALUE, META_DATA_ATTR_UNITS where COLL_NAME = *Coll and DATA_NAME = *File and META_DATA_ATTR_NAME = "Audit-Date";
  foreach (*R1 in *Q1) {
    *Nam = "Audit-Date";
    *Val = *R1.META_DATA_ATTR_VALUE;
    *Unit = *R1.META_DATA_ATTR_UNITS;
    deleteAVUMetadata (*Path, *Nam, *Val, *Unit, *Status);
  }
  msiGetSystemTime (*Tim, "unix");
  *Period = double(*Days) * 3600. * 24.;
  *New = str(double(*Tim) + *Period);
  addAVUMetadata (*Path, "Audit-Date", *New, "", *Status);
  *Date = timestrf(datetime(double(*New)), "%Y %m %d");
  writeLine ("stdout", "  New Audit-Date is *Date");
  *Doc = "Archive-PAA";
  *Loc = *RelColl;
  if (*RelColl == GLOBAL_REPOSITORY) { *Doc = "Archive-RAA"; }
  racWriteManifest (*Doc, *Loc, "stdout");
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
racFindRepColl (*File, *Rep) {
# find the collection that houses a report
# input parameter is the name of the report that is checked
# list of generated reports that are not archive specific and are manifests
  *List1 = list("EA", "ERCSA", "INTA", "NPRA", "RCA", "SEA");
# list of generated reports that are archive specific and are manifests
  *List2 = list("AFA", "AIPCRA", "CINCA", "IPA", "PAA", "SAPA", "SIA", "SIPCRA", "TA");
  *Listg1 = join_list(*List1, *List2);
# determine which collection holds the report
  *Rep = GLOBAL_REPORTS;
  splitPathByKey (*File, ".", *Head, *End);
  foreach (*R in *Listg1) {
    *Tf = "Archive-" ++ *R;
    if (*Tf == *Head) {
      *Rep = GLOBAL_MANIFESTS;
      break;
    }
  }
}
join_list(*l1, *l2) {
  if (size(*l1) == 0) then { *l2; }
  else { cons(hd(*l1),join_list(tl(*l1), *l2)); }
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

INPUT *File=$"Archive-DCP", *RelColl="Archive-A", *Days="365"
OUTPUT ruleExecOut
