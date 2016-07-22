checkFormat = mainc
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_SIPS = "SIPS"
mainc {
# Policy function to verify allowed data format
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  racFormatCheck (*File, *Coll, *Archive, *S4);
  writeLine ("stdout", "Status for format check is *S4");
}
racFormatCheck (*File, *Coll, *Archive, *S4) {
# Policy function to check the format of a SIP
# Required format type is Audit-Format saved as an attribute on GLOBAL_SIPS
  *S4 = "0";
  *F = "";
  msiGetSystemTime (*Tim, "human");
  *Q0 = select DATA_TYPE_NAME where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R0 in *Q0) {  *F = *R0.DATA_TYPE_NAME; }
  if (*F == "") {
    splitPathByKey (*File, ".", *Head, *F);
  }
  *C = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *C and META_COLL_ATTR_NAME = "Audit-Format";
  foreach (*R1 in *Q1) {
    *Form = *R1.META_COLL_ATTR_VALUE;
    if (*Form == *F) {
      *S4 = "1";
      break;
    }
  }
  if (*S4 != "1") { *S4 = "2"; }
  addAVUMetadata ("*Coll/*File", "Audit-CheckFormat", *S4, *Tim, *Stat);
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
INPUT *Archive=$"Archive-A", *File=$"rec3"
OUTPUT ruleExecOut
