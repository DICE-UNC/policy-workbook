setSource = main39
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_AIPS = "AIPS"
GLOBAL_SIPS = "SIPS"
main39 {
# rac-setSource.r
# Policy39
# set Audit-Source and Audit-Depositor on a file within the GLOBAL_SIPS or GLOBAL_AIPS collection
  if (*Type == "AIP" || *Type == "SIP") {
  } else {
    writeLine ("stdout", "allowed values for \*Type are AIP or SIP");
    fail;
  } 
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  if (*Type == "AIP") { *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_AIPS; }
  *Path = "*Coll/*File";
# note that the *File name may be a relative path containing a subcollection
  msiSplitPath (*Path, *C, *F);
  isColl(*C, "stdout", *St);
  isData (*C, *F, *Status);
  if (*Status != "0") {
    if (*Source != "") {
      addAVUMetadata (*Path, "Audit-Source", *Source, "", *Stat);
      if (*Stat == "0" ) {writeLine ("stdout", "Added source metadata to Audit-Source, *Source, for *Coll");}
    }
    if (*Depositor != "") {
      addAVUMetadata (*Path, "Audit-Depositor", *Depositor, "", *Stat);
      if (*Stat == "0" ) {writeLine ("stdout", "Added depositor metadata to Audit-Depositor, *Depositor, for *Coll");}
    }
  }
}
INPUT *Source=$"DFC", *Depositor=$"rwmoore", *File=$"rec1", *Archive=$"Archive-A", *Type=$"SIP"
OUTPUT ruleExecOut
