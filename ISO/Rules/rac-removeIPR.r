verifyIPR = main34
GLOBAL_REPORTS = "/lifelibZone/home/rwmoore/Reports"
GLOBAL_ARCHIVES = "/lifelibZone/home/rwmoore/Archives"
GLOBAL_MANIFESTS = "Manifests"
main34 {
# Policy34
# rac-verifyIPR
# remove all accounts that conflict with IPR given by Audit-IPR
  *Coll = GLOBAL_ARCHIVES ++ "/*RelColl"; 
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_NAME = "Archive-IPR";
  foreach (*R1 in *Q1) {
    *Nam = *R1.META_COLL_ATTR_VALUE;
  }
}
INPUT *RelColl="ARCHIVE_A"
OUTPUT ruleExecOut
