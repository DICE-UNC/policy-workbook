verifyReportUpdates {
  racGlobalSet ();
# rac-verifyReportUpdates.r
# Policy3
# input parameter is the name of the report that is checked
# list of reports that are not archive specific and are manifests
  *List1 = list("DIRA", "ERR", "NPRA", "PL", "RAA", "RCA", "SEA");
# list of reports that are not archive specific and are versioned
  *List2a = list("APU", "BPR", "BR", "CE", "CM", "CollP", "CP", "CR", "EAP", "FAR", "FR", "IA", "ILA", "MS", "OP", "PIP");
  *List2b = list("PMA", "PPA", "PPRS", "PR", "PSP", "QAR", "SE", "SOP", "SP", "SRF", "SSA", "STFP", "TAR", "TC", "TSE", "TW");
# list of reports that are archive specific and are manifests
  *List3 = list("AIPCRA", "ALRA", "BDA", "INTA", "IPA", "PAA", "SIA", "SIPCRA");
# list of reports that are archive specific and are versioned
  *List4a = list("AFA", "AIP", "ALA", "ARA", "AU", "ARUA", "CFR", "CID", "CINCA", "CIRA", "DAR", "DCP", "DCR", "DD", "DIDA");
  *List4b = list("DIP", "HVOA", "IDCA", "INP", "IP", "MA", "META", "PMRA", "SAPA", "SAR", "SIP", "SL", "SSR", "STAR", "TRA", "URA");
  *List2 = join_list(*List2a, *List2b);
  *List4 = join_list(*List4a, *List4b);
  *Listm = join_list(*List1, *List3);
  *Listv = join_list(*List2, *List4);
  writeLine ("stdout", "Required manifests \n *Listm");
  writeLine ("stdout", "Required reports \n *Listv");
  if (*Archive != "") {
    racCheckArchive (*Archive, *Stat);
    if (*Stat != "0") {
      writeLine ("stdout", "Input value of *Archive is either not correct or not registered");
      fail;
    }
  }
# determine which collection holds the report from the file name
  splitPathByKey(*File, ".", *Head, *Tail);
  *Found = 0;
  racsetColl (*List1, *Head, GLOBAL_MANIFESTS, GLOBAL_REPOSITORY, *Rep, *Col, *Found);
  racsetColl (*List2, *Head, GLOBAL_REPORTS, GLOBAL_REPOSITORY, *Rep, *Col, *Found);
  if (*Archive != "") {
    racsetColl (*List3, *Head, GLOBAL_MANIFESTS, *Archive, *Rep, *Col, *Found);
    racsetColl (*List4, *Head, GLOBAL_REPORTS, *Archive, *Rep, *Col, *Found);
  }
  msiGetSystemTime (*Tim, "unix");
  *T = double(*Tim);
  *Val = 0.;
  *Coll = GLOBAL_ACCOUNT ++ "/*Col/*Rep";
  *Q0 = select count(DATA_ID) where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R0 in *Q0) {*Num = *R0.DATA_ID;}
  if (*Num == "0" ) { writeLine ("stdout", "File *File does not exist in *Coll"); }  
  else {
    *Q1 = select META_DATA_ATTR_VALUE where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = 'Audit-Date';
    foreach (*R1 in *Q1) {
      *Val = double(*R1.META_DATA_ATTR_VALUE);
      *Tim = timestrf(datetime(double(*T)),"%Y %m %d");
      *Aud = timestrf(datetime(double(*Val)),"%Y %m %d");
      writeLine ("stdout", "Current date is *Tim,  Audit date is  *Aud");
    }
    if (*Val == 0.) { writeLine ("stdout", "*File is missing Audit-Date attribute"); } 
    else {
      if (*T > *Val) {
        *Date = timestrf(datetime(double(*Val)), "%Y %m %d"); 
        writeLine ("stdout", "*File needs to be updated, *Date has passed");
      }
      else { writeLine("stdout", "Report *Coll/*File is up to date"); }
    }
  }
}
racsetColl (*List1, *Head, *Repv, *Colv, *Rep, *Col, *Found) {
# Policy function to check which collection holds a file
  foreach (*R1 in *List1) {
    *Tf = "Archive-" ++ *R1;
    if (*Tf == *Head) {
      *Rep = *Repv;
      *Col = *Colv;
      *Found = 1;
      break;
    }
  }
}
join_list(*l1, *l2) {
  if (size(*l1) == 0) then { *l2; }
  else { cons(hd(*l1),join_list(tl(*l1), *l2)); }
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
INPUT *Archive=$"Archive-A", *File=$"Archive-AU.docx"
OUTPUT ruleExecOut
