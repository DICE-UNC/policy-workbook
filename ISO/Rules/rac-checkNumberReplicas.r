numberReplicas {
  racGlobalSet ();
# rac-checkNumberReplicas.r
# Policy27
# check the number of replicas in the collection GLOBAL_REPOSITORY and *Archive
# test-numberReplicas
  msiGetSystemTime (*Tim, "human");
  writeLine ("stdout", "Check for number of replicas on date *Tim");
  writeLine("stdout","  *Nrepl replications required");
  *Coll = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
  *Q1 = select count(DATA_PATH), DATA_NAME, COLL_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *Num = *R1.DATA_PATH;
    if (int(*Num) < *Nrepl) {
      *File = *R1.DATA_NAME;
      *Col = *R1.COLL_NAME;
      *Ndel = *Nrepl - int(*Num);
      writeLine("stdout", "  Missing *Ndel replicas for *Col/*File.");
      *Q2 = select DATA_RESC_HIER where DATA_NAME = *File and COLL_NAME = *Col;
      foreach (*R2 in *Q2) {
        *DataResc = *R2.DATA_RESC_HIER;
        splitPathByKey(*DataResc, ";", *Rpath, *Datarescname);
        writeLine("stdout", "    File is  on resource *Datarescname");
      }
    }
  }
  *Q2 = select META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_NAME = "Repository-Archives";
  foreach (*R2 in *Q2) {
    *Archive = *R2.META_COLL_ATTR_VALUE;
    *Coll = GLOBAL_ACCOUNT ++ "/*Archive";
    *Q3 = select count(DATA_PATH), DATA_NAME, COLL_NAME where COLL_NAME like '*Coll%';
    foreach (*R3 in *Q3) {
      *Num = *R3.DATA_PATH;
      if (int(*Num) < *Nrepl) {
        *File = *R3.DATA_NAME;
        *Col = *R3.COLL_NAME;
        *Ndel = *Nrepl - int(*Num);
        writeLine("stdout", "  Missing *Ndel replicas for *Col/*File.");
        *Q4 = select DATA_RESC_HIER where DATA_NAME = *File and COLL_NAME = *Col;
        foreach (*R4 in *Q4) {
          *DataResc = *R4.DATA_RESC_HIER;
          splitPathByKey(*DataResc, ";", *Rpath, *Datarescname);
          writeLine("stdout", "    File is  on resource *Datarescname");
        }
      }
    }
  }
  racWriteManifest ("Archive-RCA", GLOBAL_REPOSITORY, "stdout");  
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
INPUT *Nrepl=$2
OUTPUT ruleExecOut 
