setMetadata {
  racGlobalSet ();
# Policy41
# rac-setMetadata.r
# assign required metadata attributes to a collection
# in-collection-name |Attribute |Value |Units
  msiGetSystemTime (*Tim, "human");
  *Path = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_REPORTS ++ "/*Smeta";
  writeLine ("stdout", "Loaded metadata from *Path on *Tim");
  msiLoadMetadataFromDataObj(*Path,*Status);
  racWriteManifest ("Archive-PAA", *Archive, "stdout");
}
racGlobalSet = maing
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_DIPS = "DIPS"
GLOBAL_EMAIL = "rwmoore@renci.org"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_METADATA = "Metadata"
GLOBAL_OWNER = "rwmoore"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_RULES = "Rules"
GLOBAL_SIPS = "SIPS"
GLOBAL_STORAGE = "LTLResc"
GLOBAL_VERSIONS = "Versions"
maing{}
racWriteManifest( *OutFile, *Rep, *Source ) {
# create manifest file
  *Coll = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_MANIFESTS;
  *Res = GLOBAL_STORAGE;
  isColl (*Coll, "stdout", *Status);
  isData (*Coll, *OutFile, *Status);
  *Lfile = "*Coll/*OutFile";
  if (*Status == "0") {
# create manifest file
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
    msiDataObjClose (*L_FD, *Status);
  }
# update manifest file with information from *Source
  msiDataObjOpen("objPath=*Lfile++++openFlags=O_RDWR", *L_FD);
  msiDataObjLseek(*L_FD, "0", "SEEK_END", *Status);
  msiDataObjWrite(*L_FD, *Source, *Wlen);
  msiDataObjClose(*L_FD, *Status);
  msiDataObjRepl(*Lfile, "updateRepl=++++verifyChksum=", *Stat);
}

selectRescUpdate (*Rlist, *Ulist, *Num, *Resource) {
# from list of resources *Rlist select a good copy *Ulist as source
  for(*J=0;*J<*Num;*J=*J+1) {
    if(elem(*Ulist,*J) == "1") {
      *Resource = elem(*Rlist,*J);
      break;
    }  # end of selection of resource with valid copy
  }  # end of loop over all resources
}

INPUT *Smeta=$"Archive-META", *Archive=$"Archive-A"
OUTPUT ruleExecOut
