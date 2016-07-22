acPostProcForPut = main26
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_OWNER = "rwmoore"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_VERSIONS = "Versions"
main26 {
# rac-setReportUpdateDate.re
# Policy2
# check whether a file has been put into GLOBAL_ACCOUNT/GLOBAL_REPOSITORY/GLOBAL_REPORTS and version the file
  *Path = $objPath;
  msiSplitPath (*Path, *Coll, *File);
  racFindRep (*Coll, *Rep);
  if (*Rep != "") {
# Create a version in GLOBAL_VERSIONS
    *Colh = GLOBAL_ACCOUNT ++ "/*Rep";
    msiDataObjChksum(*Path, "forceChksum=", *Chksum);
    msiGetSystemTime (*Tim, "unix");
    racVersionFile(*File, *Rep, *Coll);
# verify Archive-Report is set for the collection
    racVerifyAuditReport (*Coll, *Tim)
# add attribute for Audit-Date to the file
    racSetAuditDateFile (*File, *Colh, *Coll, *Tim)
  }
}
