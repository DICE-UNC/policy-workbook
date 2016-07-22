inpMetadata = main42
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_METADATA = "Metadata"
GLOBAL_STORAGE = "LTLResc"
main42 {
# Policy42
# rac-inputMetadata.r
# load pipe-delimited metadata onto records
# assume the metadata record has the record name with an extension -meta
  msiGetSystemTime (*Tim, "human");
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_METADATA;
  if (*Col != "") { *Coll = "*Coll/*Col"; }
  *Q1 = select DATA_NAME, COLL_NAME where COLL_NAME like "*Coll%";
  foreach (*R1 in *Q1) {
    *C = *R1.COLL_NAME;
    *F = *R1.DATA_NAME;
    splitPathByKey (*F, "-", *Head, *Tail);
    if (*Tail == "meta") {
      *Path = "*C/*F";
      msiLoadMetadataFromDataObj(*Path, *Status);
      writeLine ("stdout", "Loaded metadata on SIPS listed in *Path on *Tim");
    }
  }
  racWriteManifest("Archive-PAA", *Archive, "stdout");
}
splitPathByKey(*Name, *Delim, *Head, *Tail) {
# construct a path split function
  *L = strlen(*Name);
  *Head = *Name;
  *Tail = "";
  for (*i=0; *i<*L; *i=*i+1) {
    *C = substr(*Name, *i, *i+1);
    if (*C == *Delim) {
      *Head = substr(*Name, 0, *i);
      *Tail = substr(*Name, *i+1, *L);
      break;
    }
  }
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
INPUT *Col=$"", *Archive=$"Archive-A"
OUTPUT ruleExecOut
