testVirusCheck = mainv
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_RESPOSITRY = "Repository"
GLOBAL_SIPS = "SIPS"
GLOBAL_STORAGE = "LTLResc"
mainv {
# Policy function to check for viruses
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  racVirusCheck (*File, *Coll, *S2);
  writeLine ("stdout", "Status of virus check is *S2");
}
racVirusCheck (*File, *Coll, *S2) {
# policy function to evaluate a file for viruses
# use clamscan to check for viruses
  *Path = "*Coll/*File";
  *Res = GLOBAL_STORAGE;
  *S2 = "0";
  *Q1 = select DATA_PATH where DATA_NAME = '*File' and COLL_NAME = '*Coll';
  foreach (*R1 in *Q1) {*Objpath = *R1.DATA_PATH;}
  *Val = "0";
  *Text = "Passed Virus";
  *Name = "Audit-CheckVirus";
  acScanFileAndFlagObject (*Objpath, *Path, *Res);
  *Q2 = select count(META_DATA_ATTR_NAME) where DATA_NAME = '*File' and COLL_NAME = '*Coll' and META_DATA_ATTR_NAME like 'VIRUS_SCAN_PASSED%';
  foreach (*R2 in *Q2) {
    *Num = *R2.META_DATA_ATTR_NAME;
    if ( *Num == "0") {
      *Val = "1";
      *Text = "Failed Virus";
      *S2 = "1";
    }
  }
  if (*S2 != "1") { *S2 = "2"; }
  addAVUMetadata (*Path, *Name, *Val, *Text, *Stat);
}
INPUT *Archive=$"Archive-A", *File=$"rec3"
OUTPUT ruleExecOut
