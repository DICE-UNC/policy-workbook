listContainers {
  racGlobalSet ();
# Policy67
# rac-listContainers.r
# list all containers located in GLOBAL_ACCOUNT/GLOBAL_REPOSITORY/GLOBAL_IMAGES
  msiGetSystemTime(*Tim, "human");
  *Coll = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY ++ "/" ++ GLOBAL_IMAGES
  writeLine ("stdout", "Service containers managed by the repository in *Coll on *Tim");
  *Q1 = select DATA_NAME, DATA_CREATE_TIME where COLL_NAME = *Coll;
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *D = *R1.DATA_CREATE_TIME;
    writeLine ("stdout", "  *File created on *D");
  }
 racWriteManifest ("Archive-DIRA", GLOBAL_REPOSITORY, "stdout");  
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
racGlobalSet = maing
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_DIPS = "DIPS"
GLOBAL_EMAIL = "rwmoore@renci.org"
GLOBAL_IMAGES = "Images"
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
INPUT null
OUTPUT ruleExecOut 
