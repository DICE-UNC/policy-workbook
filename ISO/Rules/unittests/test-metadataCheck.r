checkMetadata = mainm
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_SIPS = "SIPS"
mainm {
# test SIP metadata is all present
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  racMetadataCheck (*File, *Coll, *Archive, *S5);
  writeLine ("stdout", "Status for metadata check is *S5");
}
racMetadataCheck (*File, *Coll, *Archive, *S5) {
# Policy function to check SIP has required metadata
# Required metadata are stored as attributes on GLOBAL_ACCOUNT/*Archive/GLOBAL_SIPS 
  msiGetSystemTime (*Tim, "human");
  *S5 = "0";
  *Q1 = select META_COLL_ATTR_NAME, META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_VALUE = "RequiredSIP"; 
  foreach (*R1 in *Q1 ) {
    *Name = *R1.META_COLL_ATTR_NAME;
# check presence of metadata attribute on the SIP
    *Q2 = select count(META_DATA_ATTR_NAME) where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = *Name;
    foreach (*R2 in *Q2) {
      *Num = *R2.META_DATA_ATTR_NAME;
      if (*Num == "0") {
        *S5 = "1";
        break;
      }
    }
  }
  if (*S5 != "1" ) { *S5 = "2"; }
    addAVUMetadata ("*Coll/*File", "Audit-CheckMetadata", *S5, *Tim, *Stat);
}
INPUT *Archive=$"Archive-A", *File=$"rec3"
OUTPUT ruleExecOut
