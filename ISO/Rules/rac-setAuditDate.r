setAuditDate = main36
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
main36 {
# Policy36
# rac-setAuditDate.r
# set the attribute Audit-Date on a document
# determine where the document is located
# determine whether the report is a manifest or a version
  racFindRepColl (*File, *Rep);
  *Coll = GLOBAL_ACCOUNT ++ "/*RelColl/*Rep";
  writeLine ("stdout", "*Coll");
  *Path = "*Coll/*File";
  writeLine ("stdout", "*Path");
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
}
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
INPUT *File=$"Archive-TA", *RelColl="Archive-A", *Days="365"
OUTPUT ruleExecOut
