checkFormat {
  racGlobalSet ();
# Policy66
# rac-checkFormat.r
# Check that the format of each AIP corresponds to required format in Archive-Format
  msiGetSystemTime (*Tim, "human");
  *Colla = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_ARCHIVES;
  writeLine ("stdout", "Checked allowed formats on *Colla on *Tim");
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *Colla and META_COLL_ATTR_NAME = "Archive-Format";
  *Listf = list("");
  *Nf = 0;
  foreach (*R1 in *Q1) {
    *Val = *R1.META_COLL_ATTR_VALUE;
    *Listf = cons(*Val, *Listf);
    *Nf = *Nf + 1;
  }
  if (*Nf > 0) {
    *Q2 = select DATA_NAME, COLL_NAME, DATA_TYPE_NAME where COLL_NAME like "*Colla%";
    foreach (*R2 in *Q2 ) {
      *File = *R2.DATA_NAME;
      *Col = *R2.COLL_NAME;
      *T = *R2.DATA_TYPE_NAME;
      *Found = 0;
      for (*J = 0; *J<*Nf; *J=*J+1) {
        *Fo = elem(*Listf, *J);
        if (*Fo == *T) {
          *Found = 1;
          break;
        }
      }
      if (*Found != 1) {
        writeLine ("stdout", "  *Col/*File had incorrect format *T");
       }
    }
  } else {
    writeLine ("stdout", "  *Colla does not have required formats specified");
  }
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
INPUT *Archive=$"Archive-A"
OUTPUT ruleExecOut
