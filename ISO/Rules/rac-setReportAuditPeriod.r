setAuditPeriod {
  racGlobalSet ();
# rac-setReportAuditPeriod.r
# Policy8
# set default value for Archive-Report on an archive
# set default value for Repository-Report on GLOBAL_REPOSITORY
# create Reports collection if needed
  *Doc = "Archive-PAA";
  *Metan = "Archive-Report";
  if (*Rep == GLOBAL_REPOSITORY) {
    *Metan = "Repository-Report";
    *Doc = "Archive-RAA";
  }
  *Archive = GLOBAL_ACCOUNT ++ "/*Rep";
  *Q2 = select count(COLL_ID) where COLL_NAME = *Archive;
  foreach (*R2 in *Q2) { *Num = *R2.COLL_ID; }
  if (*Num == "0") {
    msiCollCreate(*Archive, "1", *Status);
      if(*Status < 0) {
        writeLine("stdout","Could not create *Archive collection");
      }  # end of check on status
  }
# check that  attribute is defined on collection *Archive
  *Period = str(double(*NumDays) * 3600. * 24.);
  *Q3 = select count(META_COLL_ATTR_ID) where COLL_NAME = *Archive and META_COLL_ATTR_NAME = *Metan;
  foreach (*R3 in *Q3) {*Num1 = *R3.META_COLL_ATTR_ID;}
  if (*Num1 !=  "0" ) {
    *Q4 = select META_COLL_ATTR_VALUE, META_COLL_ATTR_UNITS where COLL_NAME = *Archive and META_COLL_ATTR_NAME = *Metan;
    foreach (*R4 in *Q4) {
      *Val = *R4.META_COLL_ATTR_VALUE;
      *Units = *R4.META_COLL_ATTR_UNITS;
      deleteAVUMetadataFromColl (*Archive, *Metan, *Val, *Units, *Stat);
    }
  }
# add default update period to collection
  msiGetSystemTime (*Tim, "human");
  addAVUMetadataToColl (*Archive, *Metan, *Period, "", *Stat);
  writeLine ("stdout", "Set *Metan metadata value to *Period seconds for collection *Archive on *Tim");
  racWriteManifest (*Doc, *Rep, "stdout");
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
deleteAVUMetadataFromColl (*Coll, *N, *V, *U, *S) {
# work around, need micro-service to delete triples from collections
  msiAddKeyVal (*Kvp, *N, *V);
  msiRemoveKeyValuePairsFromObj (*Kvp, *Coll, "-C");
}
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
INPUT *NumDays=$"365", *Rep=$"Archive-A"
OUTPUT ruleExecOut
