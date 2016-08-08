setArchives {
  racGlobalSet ();
# Policy35
# rac-setArchives.r
# Add an archives name as an attribute on GLOBAL_REPOSITORY
  if (*Archive == GLOBAL_REPOSITORY) {
    writeLine ("stdout", "Input value for Archive cannot be *Archive");
    fail;
  }
  msiGetSystemTime (*Tim, "human");
  *Colh = GLOBAL_ACCOUNT;
  *Coll = "*Colh/" ++ GLOBAL_REPOSITORY;
  writeLine ("stdout", "Check Repository-Archives attribute for value *Archive on *Coll on *Tim");
# verify that name is not already present for the archive
  *Q1 = select count(META_COLL_ATTR_VALUE) where COLL_NAME = *Coll and META_COLL_ATTR_NAME = "Repository-Archives" and META_COLL_ATTR_VALUE = *Archive;
  foreach (*R1 in *Q1 ) {
    *Num = *R1.META_COLL_ATTR_VALUE;
    if (*Num == "0" ) {
      msiAddKeyVal (*Kvp, "Repository-Archives", *Archive);
      msiAssociateKeyValuePairsToObj (*Kvp, *Coll, "-C");
      writeLine ("stdout", "  Added name for new archives, *Archive, to the collection *Coll");
# Create an archives collection if missing
      *C = "*Colh/*Archive";
      isColl (*C, "stdout", *Status);
      if (*Status >= 0) { writeLine("stdout", "  Created archives collection, *C"); }
    } else {
      writeLine ("stdout", "  The archive *Archive is already registered");
    }
  }
  racWriteManifest ("Archive-RAA", GLOBAL_REPOSITORY, "stdout");
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

INPUT *Archive=$"Archive-B"
OUTPUT ruleExecOut
