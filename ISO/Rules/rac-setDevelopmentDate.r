setDevelopmentDate = main11
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_STORAGE = "LTLResc"
main11 {
# rac-setDevelopmentDate.r
# Policy11
# assign an attribute to a repository staff member for the completion date for a development course
# if the assigned value is null, set a date for 1 year
# if the assigned value is set, check whether the date has passed.
# if a period is specified as a number of days, change the date
  *Per = 3600. * 24 * int(GLOBAL_AUDIT_PERIOD);
  if (*Period != 0) {*Per = *Period * 24. * 3600;}
  msiGetSystemTime (*Time, "unix");
  *Tim = double(*Time);
  *Date = str(*Tim + *Per);
  *Timef = timestrf(datetime(double(*Time)), "%Y %m %d");
  *Datef = timestrf(datetime(double(*Date)), "%Y %m %d");
  writeLine ("stdout", "Set Repository-Devel-Date value to *Datef for user *Name on *Timef");
  *Q1 = select count(META_USER_ATTR_ID) where USER_NAME = *Name and META_USER_ATTR_NAME = 'Repository-Devel-Date';
  foreach (*R1 in *Q1) {
    *Num = *R1.META_USER_ATTR_ID;
    if (*Num == "0") {
      msiAddKeyVal (*Keyval, "Repository-Devel-Date", *Date);
      msiAssociateKeyValuePairsToObj (*Keyval, *Name, "-u");
      writeLine("stdout", "Reset completion date for a development course to *Date for user *Name");
    } else {
# check if date has passed
      *Q2 = select META_USER_ATTR_VALUE where USER_NAME = *Name and META_USER_ATTR_NAME = 'Repository-Devel-Date';
      foreach (*R2 in *Q2) {
        *Vals = *R2.META_USER_ATTR_VALUE;
        *Val = double(*Vals);
        if (*Val < *Tim) { 
          writeLine("stdout", "Prior development date has passed for user *Name");
          *Cur = timestrf(datetime(*Tim), "%Y %m %d");
          *Passed = timestrf(datetime(*Val), "%Y %m %d");
          writeLine("stdout", "Due date was *Passed, current date is *Cur for user *Name");
        }
        if (*Period != 0) {
          msiAddKeyVal (*Keyval0, "Repository-Devel-Date", *Vals);
          msiRemoveKeyValuePairsFromObj(*Keyval0, *Name, "-u");
          msiAddKeyVal (*Keyval1, "Repository-Devel-Date", *Date);
          msiAssociateKeyValuePairsToObj (*Keyval1, *Name, "-u");
          *New = timestrf(datetime(*Tim + *Per), "%Y %m %d");
          writeLine("stdout", "Reset completion date for a development course to *New for user *Name");
        }
      }
    }
  }
  racWriteManifest ("Archive-SEA", GLOBAL_REPOSITORY, "stdout");
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
INPUT *Name=$"rwmoore", *Period=$0
OUTPUT ruleExecOut
