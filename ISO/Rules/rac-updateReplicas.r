updateReplicas {
  racGlobalSet ();
# rac-updateReplicas.r
# Policy28
# Use a rebalance operation to ensure every file is replicated
  msiGetSystemTime (*Tim, "human");
  *Resource = GLOBAL_STORAGE;
  run_periodic_rebalance(*Resource);
  writeLine ("stdout", "Initiated rebalance operation on storage *Resource every 30 days on *Tim");
  racWriteManifest ("Archive-RAA", GLOBAL_REPOSITORY, "stdout");
}
run_periodic_rebalance(*Resource) {
   delay("<PLUSET>1m</PLUSET><EF>30d</EF>") {
           msiWriteRodsLog("Performing Rebalance for *Resource replication resource", *Status);
           if (errorcode(msiRunRebalance(*Resource)) < 0) {
              msiWriteRodsLog("ERROR: Rebalance for *Resource replication resource Failed", *Status);
           }
           else {
              msiWriteRodsLog("Rebalance for *Resource replication resource complete", *Status);
           }
   }
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
INPUT null
OUTPUT ruleExecOut
