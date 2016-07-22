generateReportStatus = main7
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_OWNER = "rwmoore"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_STORAGE = "LTLResc"
GLOBAL_VERSIONS = "Versions"
main7 {
# rac-generateReportStatus.r
# Policy7
# Create report listing the status of all documents
# list of generated reports that are not archive specific and are manifests
  *List1 = list("EA", "ERCSA", "INTA", "NPRA", "RCA", "SEA");
# list of generated reports that are not archive specific and are versioned
  *List1v = list("AUPA", "BDA", "DIRA", "ILA", "PLA", "PMA", "PPA", "RAA", "SSA", "TSEA");
# list of generated reports that are archive specific and are manifests
  *List2 = list("AFA", "AIPCRA", "CINCA", "IPA", "PAA", "SIA", "SIPCRA", "TA");
# list of generated reports that are archive specific and are versioned
  *List2v = list("ALA", "ALRA", "ARA", "AURA", "CIRA", "DDA", "MA", "PMRA", "SAPA", "URA");
# list of management reports that are not archive specific
  *List3b = list("BPR", "BR", "CE", "CM", "CollP", "CP", "CR", "EAP", "FAR", "FR", "MS", "OP");
  *List3a = list( "PIP", "PR", "PSP", "SE", "SOP", "SP", "SRF", "STFP", "TAR", "TC", "TW");
# list of management reports that are archive specific
  *List4 = list("AIP", "AU", "CFR", "CID", "DAR", "DCP", "DCR", "DD", "DIP", "HVO", "INP", "IP", "META", "SAR", "SIP", "SL", "SSR", "STAR");
  *Res = GLOBAL_STORAGE;
  *Home = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
  *Coll = "*Home/" ++ GLOBAL_REPORTS;
  msiGetSystemTime (*Tim, "human");
  writeLine ("stdout", "Status report for all management reports, generated on date *Tim");
  *List3 = join_list (*List3a, *List3b);
  *Listrr = join_list (*List1v, *List3);
  printList("Management reports that are not archive specific", *Res, *Listrr, "stdout", *Coll);
  *Collm = "*Home/" ++ GLOBAL_MANIFESTS;
  printList("Manifests that are not archive specific", *Res, *List1, "stdout", *Collm);
# loop over the archive repositories and track reports
  *Listra = join_list (*List2v, *List4);
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *Home and META_COLL_ATTR_NAME = 'Repository-Archives';
  foreach (*R1 in *Q1) {
    *Archive = *R1.META_COLL_ATTR_VALUE;
    *Homea = GLOBAL_ACCOUNT ++ "/*Archive";
    *Coll = "*Homea/" ++ GLOBAL_REPORTS;
    printList("Management reports that are archive specific", *Res, *Listra, "stdout", *Coll);
    *Collm = "*Homea/" ++ GLOBAL_MANIFESTS;
    printList("Manifests that are archive specific", *Res, *List2, "stdout", *Collm);
  }
  *Col = GLOBAL_REPOSITORY;
  racSaveFile ("Archive-SSA", *Col);
}
printList (*Type, *Res, *Listr, *Lfile, *Coll) {
# Loop over report list
  writeLine(*Lfile, "\nAnalysis of *Type for collection *Coll");
  msiGetSystemTime (*Tim, "unix");
  checkReports (*Listr, *Coll, *Tim, *Nummisrep, *Lfile, "0");
  if (*Nummisrep != 0) {
    writeLine ("*Lfile", "*Nummisrep reports are missing");
    checkReports (*Listr, *Coll, *Tim, *Nummisrep, *Lfile, "1");
  }
# list the good reports
  writeLine ("*Lfile", "Reports that exist");
  checkReports (*Listr, *Coll, *Tim, *Nummisrep, *Lfile, "2");
}
checkReports (*Listr, *Coll, *Tim, *Nummisrep, *Lfile, *Flag) {
  *Nummisrep = 0;
  *T = double(*Tim);
  *Time = timestrf(datetime(*T), "%Y:%m:%d");
  foreach (*R in *Listr) {
#  writeLine ("stdout", "*R");
    *File = "Archive-" ++ *R;
    *C1 = *File;
    if (strlen(*File) <= 8) {*C1 = *File ++ "\t\t";}
    if (strlen(*File) < 16) {*C1 = *File ++ "\t";}
    *Q1 = select count(DATA_ID) where COLL_NAME = *Coll and DATA_NAME like "*File%";
    foreach (*R1 in *Q1) { *Num = *R1.DATA_ID;}
    if (*Num == "0") {
      *Nummisrep = *Nummisrep + 1;
      if (*Flag == "1") { writeLine("*Lfile", "*C1   is missing"); }
    }
    else {
      *Q2 = select count(META_DATA_ATTR_ID) where COLL_NAME = *Coll and DATA_NAME like "*File%" and META_DATA_ATTR_NAME = "Audit-Date";
      foreach (*R2 in *Q2) {
        *Na = *R2.META_DATA_ATTR_ID;
        if (*Na == "0") {
          if (*Flag == "2") { writeLine("*Lfile", "*C1   is missing an Audit-Date attribute"); }
        } else {
          *Q3 = select META_DATA_ATTR_VALUE, DATA_NAME where COLL_NAME = *Coll and DATA_NAME like "*File%" and META_DATA_ATTR_NAME = "Audit-Date";
          foreach (*R3 in *Q3) {
            *Fa = *R3.DATA_NAME;
            *C2 = *Fa;
            if (strlen(*Fa) <= 8) {*C2 = *Fa ++ "\t\t";}
            if (strlen(*Fa) < 16) {*C2 = *Fa ++ "\t";}
            *Filedate = *R3.META_DATA_ATTR_VALUE;
            *D = double(*Filedate);
            *Date = timestrf(datetime(*D), "%Y:%m:%d");
            if (*D < *T && *Flag == "1") {
              writeLine("*Lfile", "*C2   audit was due on *Date, document needs updating");
            }
            if (*D > *T && *Flag == "2") { writeLine("*Lfile","*C2   current date *Time    audit due on *Date"); }
          }
        }
      }
    }
  }
}
join_list(*l1, *l2) {
  if (size(*l1) == 0) then { *l2; }
  else { cons(hd(*l1),join_list(tl(*l1), *l2)); }
}
racSaveFile (*File, *Rep) {
# policy function to write standard out to *File in collection GLOBAL_REPORTS
  *Colh = GLOBAL_ACCOUNT ++ "/*Rep";
  *Coll = "*Colh/" ++ GLOBAL_REPORTS;
  *Path = "*Coll/*File";
  *Res = GLOBAL_STORAGE;
  *Per = GLOBAL_OWNER;
  isColl (*Coll, "stdout", *Status);
  *DesColl = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_VERSIONS;
  isColl (*DesColl, "stdout", *Status);
# check for presence of output file
  *Q1 = select count(DATA_ID) where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) { *N = *R1.DATA_ID; }
  if (*N == "0") {
    *Flags = "destRescName=*Res++++forceFlag=";
     msiDataObjCreate(*Path, *Flags, *L_FD);
  } else {
    *Flags = "objPath=*Path++++openFlags=O_RDWR";
    msiDataObjOpen (*Flags, *L_FD);
  }
  msiDataObjWrite(*L_FD, "stdout", *Wlen);
  msiDataObjClose(*L_FD, *Status);
  msiFreeBuffer ("stdout");
  msiDataObjRepl(*Path, "updateRepl=++++verifyChksum=", *Stat);
  msiSetACL("default", "own", *Per, *Path);
# add attribute for Audit-Date to the file
  msiGetSystemTime (*Tim, "unix");
# check that Archive-Report is defined on collection
  racVerifyAuditReport (*Colh, *Rep, *Tim);
# set the Audit-Date on a file
  racSetAuditDateFile (*File, *Rep, *Colh, *Coll, *Tim);
# Copy report into Reports/Versions and increment the version number
  racVersionFile (*File, *Rep, *Coll);
}

racSetAuditDateFile (*File, *Rep, *Colh, *Coll, *Tim) {
# policy function to set the Audit-Date attribute on a file
  *Path = "*Coll/*File";
  *Att = "Archive-Report";
  if (*Rep == GLOBAL_REPOSITORY) { *Att = "Repository-Report"; }
  *Q4 = select META_COLL_ATTR_VALUE where COLL_NAME = *Colh and META_COLL_ATTR_NAME = *Att;
  foreach (*R4 in *Q4) {*P = *R4.META_COLL_ATTR_VALUE;}
  *T = str (double (*Tim) + double(*P));
# check that no metadata exists on file for 'Audit-Date'
  *Q5 = select count (META_DATA_ATTR_ID) where COLL_NAME = *Coll and DATA_NAME = *File and META_DATA_ATTR_NAME
 = 'Audit-Date';
  foreach (*R5 in *Q5) { *N = *R5.META_DATA_ATTR_ID; }
  if (*N != "0" ) {
    *Q6 = select META_DATA_ATTR_VALUE, META_DATA_ATTR_UNITS where COLL_NAME = *Coll and DATA_NAME = *File and
META_DATA_ATTR_NAME = 'Audit-Date';
    foreach (*R6 in *Q6) {
      *V = *R6.META_DATA_ATTR_VALUE;
      *U = *R6.META_DATA_ATTR_UNITS;
      deleteAVUMetadata (*Path, "Audit-Date", *V, *U, *Status);
    }
# no delete of Audit-Date from versioned file is needed since copy does not copy metadata.
  }
  addAVUMetadata (*Path, "Audit-Date", *T, "", *Stat);
}

racVerifyAuditReport (*Coll, *Rep, *Tim) {
# policy function to check that Archive-Report is defined on collection *Coll
  *Period = str (int(GLOBAL_AUDIT_PERIOD) * 86400);
  *Att = "Archive-Report";
  if (*Rep == GLOBAL_REPOSITORY) { *Att = "Repository-Report"; }
  *Q3 = select count(META_COLL_ATTR_ID) where COLL_NAME = *Coll and META_COLL_ATTR_NAME = *Att;
  foreach (*R3 in *Q3) {*Num1 = *R3.META_COLL_ATTR_ID;}
  if (*Num1 == "0" ) {
# add default update period to collection
    addAVUMetadataToColl (*Coll, *Att, *Period, "", *Stat);
  }
}

racVersionFile (*File, *Rep, *Coll) {
# policy function to version a file
  *Path = "*Coll/*File";
  *DesColl = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_VERSIONS;
  *err = errorcode(msiCollCreate(*DesColl, "1", *status));
# Copy report into Versions and increment the version number
  *Q2 = select DATA_NAME where COLL_NAME = '*DesColl' and DATA_NAME like '*File..%';
  *Num = 0;
  foreach (*R2 in *Q2) {
    *Ver = *R2.DATA_NAME;
    *Vend = int(substr(*Ver, strlen(*File)+2, strlen(*Ver)));
    if (*Vend > *Num) {*Num = *Vend;}
  }
  *Numinc = *Num + 1;
  *Vers = *File ++ ".." ++ "*Numinc";
  *Pathver = *DesColl ++ "/" ++ *Vers;
  msiDataObjCopy(*Path, *Pathver, "verifyChksum=", *Status);
  msiDataObjRepl(*Pathver, "updateRepl=++++verifyChksum=", *Stat);
  *Per = GLOBAL_OWNER;
  msiSetACL("default", "own", *Per, *Pathver);
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
