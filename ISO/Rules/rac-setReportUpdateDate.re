acPostProcForPut {
  racGlobalSet ();
# rac-setReportUpdateDate.re
# Policy26
# check whether a file has been put into GLOBAL_REPORTS and version the file
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
