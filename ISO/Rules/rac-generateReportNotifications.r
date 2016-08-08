setPeriodicReview {
  racGlobalSet ();
# rac-generateReportNotifications.r
# Policy6
# maintain  manifest file holding the date of each periodic notification in Archive-NPRA
# set up delayed execution rule to send e-mail notification
  *Per = GLOBAL_EMAIL;
  *File = "Archive-NPRA";
  *Rep = GLOBAL_REPOSITORY;
  calldelayedfunction (*Per, *File, *Rep, *Docs);
  writeLine ("stdout", "Periodic rule has been initiated to notify *Per to check whether the *Docs  need to be reviewed");
  writeLine ("stdout", "Review period is set yearly");
}
calldelayedfunction (*Per, *File, *Rep,  *Docs) {
  delay ("<PLUSET>1s</PLUSET><EF>1y</EF>") {
    msiSendMail (*Per, "Review repository management", "Check whether the *Docs need to be reviewed or updated"); 
    
# maintain log file of notifications
    msiGetSystemTime (*Tim, "human");
    writeLine ("stdout", "Notification sent at *Tim to *Per to check whether the *Docs need to be reviewed");
    racWriteManifest (*File, *Rep, "stdout");
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
INPUT *Docs=$"Archive-SP, Archive-CP, Archive-EA" 
OUTPUT ruleExecOut 
