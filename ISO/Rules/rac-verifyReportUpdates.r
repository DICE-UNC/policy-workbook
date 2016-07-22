checkForUpdate = main3
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
main3 {
# rac-verifyReportUpdates.r
# Policy3
# input parameter is the name of the report that is checked
# list of generated reports that are not archive specific and are manifests
  *List1 = list("EA", "ERCSA", "INTA", "NPRA", "RAA", "RCA", "SEA");
# list of generated reports that are not archive specific and are versioned
  *List1v = list("AUPA", "BDA", "DIRA", "ILA", "PLA", "PMA", "PPA", "SSA", "TSEA");
# list of generated reports that are archive specific and are manifests
  *List2 = list("AFA", "AIPCRA", "CINCA", "IPA", "PAA", "SIA", "SIPCRA", "TA");
# list of generated reports that are archive specific and are versioned
  *List2v = list("ALA", "ALRA", "ARA", "AURA", "CIRA", "DDA", "MA", "PMRA", "SAPA", "URA");
# list of management reports that are not archive specific
  *List3b = list("BPR", "BR", "CE", "CM", "CollP", "CP", "CR", "EAP", "FAR", "FR", "MS", "OP");
  *List3a = list( "PIP", "PR", "PSP", "SE", "SOP", "SP", "SRF", "STFP", "TAR", "TC", "TW");
# list of management reports that are archive specific
  *List4 = list("AIP", "AU", "CFR", "CID", "DAR", "DCP", "DCR", "DD", "DIP", "HVO", "INP", "IP", "META", "SAR", "SIP", "SL", "SSR", "STAR");
  *Listg1 = join_list(*List1, *List2);
  *Listg2 = join_list(*List1v, *List2v);
  *Listg = join_list(*Listg1, *Listg2);
  *List3 = join_list(*List3b, *List3a);
  *Listm = join_list(*List3, *List4);
  writeLine ("stdout", "Required generated reports \n *Listg");
  writeLine ("stdout", "Required management reports \n *Listm");
# determine which collection holds the report
  splitPathByKey(*File, ".", *Head, *Tail);
  *Rep = GLOBAL_REPORTS;
  foreach (*R in *Listg1) {
    *Tf = "Archive-" ++ *R;
    if (*Tf == *Head) {
      *Rep = GLOBAL_MANIFESTS;
      break;
    }
  }
  if (*Archive != "") { *Coll = GLOBAL_ACCOUNT ++ "/*Archive/*Rep"; }
  else { *Coll = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY ++ "/*Rep"; }
  msiGetSystemTime (*Tim, "unix");
  *T = double(*Tim);
  *Val = 0.;
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
INPUT *Archive=$"Archive-A", *File=$"Archive-AU.docx"
OUTPUT ruleExecOut
