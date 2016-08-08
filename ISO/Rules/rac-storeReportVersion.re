acPostProcForPut (
  racGlobalSet();
# rac-storeReportVersion.re
# Policy1 
# check whether a file has been put into GLOBAL_ACCOUNT/GLOBAL_REPOSITORY/GLOBAL_REPORTS and version the file
  *Path = $objPath;
  msiSplitPath (*Path, *Coll, *File);
  racFindRep (*Coll, *Rep);
  if (*Rep != "") {
# Create a version in GLOBAL_VERSIONS
    msiDataObjChksum(*Path, "forceChksum=", *Chksum);
    racVersionFile(*File, *Rep);
  }
}    
