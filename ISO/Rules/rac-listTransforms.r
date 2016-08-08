listTranforms {
  racGlobalSet ();
# Policy68
# rac-listTransforms.r
# list all transforms that can be applied for a specific AIP
  msiGetSystemTime(*Tim, "human");
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/"++ GLOBAL_ARCHIVES;
  writeLine ("stdout", "Format transformation that can be applied to *Coll/*File on *Tim");
  *Q1 = select DATA_TYPE_NAME where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) {
    *Type = *R1.DATA_TYPE_NAME;
    writeLine ("stdout", "  *File had data format type *Type");
  }
  *Cmd = "command to get list of transforms from Brown Dog in a  Docker Container";
  *Args = "arg1 arg2".
  msiExecCmd(*Cmd, *Args, "", "", "", *Result);
  msiGetStdoutInExecCmdOut (*Result, *Oid);
 racWriteManifest ("Archive-BDA", *Archive, "stdout");  
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
INPUT *Archive-$"Archive-A", *File=$"rec1"
OUTPUT ruleExecOut 
