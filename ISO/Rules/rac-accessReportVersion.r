findReport {
  racGlobalSet ();
# rac-accessReportVersion.r
# Policy4
# input parameter is the name of the report that is checked
# retrieve most recent report and list prior versions
  racFindRepColl (*File, *Rep);
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/*Rep";
  isData (*Coll, *File, *Status);
  if (*Status == "0") {
    writeLine ("stdout", "Input file *File is not valid");
    fail;
  }
  msiGetSystemTime (*Tim, "unix");
  *T = double(*Tim);
  *Q1 = select META_DATA_ATTR_VALUE where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = 'Audit-Date';
  foreach (*R1 in *Q1) {
    *Val = double(*R1.META_DATA_ATTR_VALUE);
  }
  *Date = timestrf(datetime(double(*Val)), "%Y %m %d"); 
  writeLine ("stdout", "Most recent version of *File is in collection *Coll and should be updated on *Date");
# list prior versions of report
  if (*Rep == GLOBAL_REPORTS ) {
    *Collv = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_VERSIONS;
    *Q2 = select DATA_NAME, DATA_CREATE_TIME where COLL_NAME = '*Collv' and DATA_NAME like '*File..%' and DATA_REPL_NUM = "0";
    foreach (*R2 in *Q2) {
      *Fil = *R2.DATA_NAME;
      *V = *R2.DATA_CREATE_TIME;
      *Date = timestrf(datetime(double(*V)), "%Y %m %d");
      writeLine ("stdout", "Version *Fil created on *Date");
    }
  }
  racWriteManifest ("Archive-PAA", *Archive, "stdout");
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
racFindRepColl (*File, *Rep) {
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_REPORTS = "Reports"
GLOBAL_VERSIONS = "Versions"
# find the collection that houses a report
# input parameter is the name of the report that is checked
# list of generated reports that are not archive specific and are manifests
  *List1 = list("EA", "ERCSA", "INTA", "NPRA", "RCA", "SEA");
# list of generated reports that are archive specific and are manifests
  *List2 = list("AFA", "AIPCRA", "CINCA", "IPA", "PAA", "SAPA", "SIA", "SIPCRA", "TA");
  *Listg1 = join_list(*List1, *List2);
# determine which collection holds the report
  *Rep = GLOBAL_REPORTS; 
  splitPathByKey(*File, ".", *Head, *End);
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
INPUT *File=$"Archive-AIP", *Archive=$"Archive-A"
OUTPUT ruleExecOut
