setMetadata = main41
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_REPORTS = "Reports"
main41 {
# Policy41
# rac-setMetadata.r
# assign required metadata attributes to a collection
# in-collection-name |Attribute |Value |Units
  msiGetSystemTime (*Tim, "human");
  *Path = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_REPORTS ++ "/*Smeta";
  writeLine ("stdout", "Loaded metadata from *Path on *Tim");
  msiLoadMetadataFromDataObj(*Path,*Status);
}
INPUT *Smeta=$"Archive-META", *Archive=$"Archive-A"
OUTPUT ruleExecOut
