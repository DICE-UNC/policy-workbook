listDevelopment = main12
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_STORAGE = "LTLResc"
main12 {
# rac-listDevelopment.r
# Policy12
# list the development courses taken by repository staff, organized by roles
  msiGetSystemTime (*Tim, "human");
  writeLine ("stdout", "Staff Experience report created on *Tim");
# count the number of persons in each repository role and list their names
  *Roles = list("Archive-manager", "Archive-archivist", "Archive-admin", "Archive-IT");
  *Att = "Repository-Role";
  foreach (*R in *Roles) {
    *Q1 = select count(USER_ID) where META_USER_ATTR_NAME = *Att and META_USER_ATTR_VALUE = *R;
    foreach (*R1 in *Q1) {
      *Num = *R1.USER_ID;
      writeLine("stdout", "  For role *R there are *Num staff members");
      *Q2 = select USER_NAME where META_USER_ATTR_NAME = *Att and META_USER_ATTR_VALUE = *R;
      foreach (*R2 in *Q2) {
        *Name = *R2.USER_NAME;
        *Q3 = select META_USER_ATTR_VALUE where USER_NAME = *Name and META_USER_ATTR_NAME = "Repository-Course";
        writeLine("stdout","      *Name");
        foreach (*R3 in *Q3) {
          *Val = *R3.META_USER_ATTR_VALUE;
          splitPathByKey (*Val, ":", *Course, *Time);
          *Date = timestrf(datetime(double(*Time)), "%Y %m %d");
          writeLine ("stdout", "          Course *Course,       Date *Date");
        }
      }
    }
  }
  racWriteManifest ("Archive-SEA", GLOBAL_REPOSITORY, "stdout");
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
INPUT null
OUTPUT ruleExecOut
