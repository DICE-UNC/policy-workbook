createAIP {
  racGlobalSet ();
# Policy53 - create AIPs from SIPs with Audit-Comply attribute equal to "1"
# rac-createAIP.r
# set metadata, ACLs, storage location, and number replicas for AIP
  msiGetSystemTime (*Tim, "human");
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  *Len = strlen (*Coll);
  *Colla = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_ARCHIVES;
# always give access to person with IPR rights
  racGetAVUMetadata (*Archive, *Colla, "Archive-Access", "0", *Acctr);
  racGetAVUMetadata (*Archive, *Colla, "Archive-Distribution", "1", *Stor);
  racGetAVUMetadata (*Archive, *Colla, "Archive-CheckHandle", "0", *Han);
  if (*Stor == "") { *Stor = GLOBAL_STORAGE; }
  racCheckNumReplicas (*Stor, *Num);
  racGetAVUMetadata (*Archive, *Colla, "Archive-Replication", "0", *Nrepl);
  if (*Nrepl > *Num) {
    *Msg = "Cannot create the required number of replicas, *Nrepl, on resource *Stor";
    racNotify (*Archive, *Msg);
  }
  *Accto = GLOBAL_OWNER;
  writeLine ("stdout", "Creating AIPs from *Coll on *Tim");
  *Q1 = select DATA_NAME, COLL_NAME where COLL_NAME like "*Coll%" and META_DATA_ATTR_NAME = "Audit-Comply" and META_DATA_ATTR_VALUE = "1";
  foreach (*R1 in *Q1) {
    *C = *R1.COLL_NAME;
    *Lc = strlen(*C);
    *F = *R1.DATA_NAME;
    *Ps = "*C/*F";
    *Pd = "*Colla/*F";
    if (*Lc > *Len) { 
      *Tail = substr(*C, *Len + 1, *Lc);
      *Pd = "*Colla/*Tail/*F";
    } 
    msiDataObjCopy (*Ps, *Pd, "forceFlag=++++verifyChksum=++++destRescName=*Stor", *Status);
    if (*Status == 0 ) {
      msiSetACL ("default", "own", *Accto, *Pd);
      if (*Acctr == "") {
        msiSetACL ("default", "read", "anonymous", *Pd);
      } else {
        msiSetACL ("default", "read", *Acctr, *Pd);
      }
      writeLine ("stdout", "  Created *Pd from *Ps");
      msiStripAVUs (*Pd, "data", *Status);
      msiCopyAVUMetadata (*Ps, *Pd, *St1);
# create handle
      if (*Han == "1") { racCreateHandle (*C, *F); }
    } else {
      writeLine ("stdout", "  Failed on attempt to create *Pd from *Ps");
    }
  }
  racWriteManifest ("Archive-AIPCRA", *Archive, "stdout");
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
racCreateHandle (*Coll, *File) {
# create a handle for a file
  *Cmd = "create_handle.sh";
  *Uri = "irods%3A%2F%2Fees.renci.org%3A1247$objPath";
  *Url = execCmdArg("https://dfcweb.datafed.org/idrop-web2/home/link?irodsURI=*Uri");
  *Q1 = select DATA_ID where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) { *Dataid = *R1.DATA_ID; }
  *Args = "*Dataid *Url";
  msiExecCmd(*Cmd, *Args, "null", "null", "null", *Result);
  msiGetStdoutInExecCmdOut(*Result,*Oid);
  *Path = "*Coll/*File";
  addAVUMetadata (*Path, "Audit-Handle", *Oid, "", *Stat);
}
racCheckMsg (*Msg, *Msgt) {
# transform message to remove all minus signs
  *L = strlen(*Msg);
  *J = 0;
  *Msgt = "";
  for (*I=0; *I<*L; *I=*I+1) {
    *M = substr(*Msg, *I, *I+1)
    if (*M != "-" && *M != "_" && *M != ":") {
      *Msgt = *Msgt ++ *M;
    } else {
      *Msgt = *Msgt ++ " ";
    }
  }
}
racCheckNumReplicas (*Res, *Num) {
# Policy function to determine how many replicas will be made by a resource
  *File = "rac234";
  *Coll = GLOBAL_ACCOUNT;
  *Path = "*Coll/*File";
  *Flags = "destRescName=*Res++++forceFlag=";
  *Num = "0";
  msiDataObjCreate (*Path, *Flags, *FD);
  msiDataObjWrite(*FD, "1", *Len);
  msiDataObjClose (*FD, *Stat);
  *Q1 = select count(DATA_REPL_NUM) where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) { *Num = *R1.DATA_REPL_NUM; }
  *Flagd = "objPath=*Path";
  msiDataObjUnlink (*Flagd, *Status);
}
racGetAVUMetadata (*Archive, *Coll, *Name, *Cont, *Val) {
# policy function to verify existence and retrieve attribute from a collection
# send e-mail if attribute is missing
# *Cont = "1" if notification is required for missing attribute
  *Val = "";
  *Q1 = select count(META_COLL_ATTR_VALUE) where COLL_NAME = *Coll and META_COLL_ATTR_NAME = *Name;
  foreach (*R1 in *Q1) { *Num = *R1.META_COLL_ATTR_VALUE; }
  if (*Num > "0") {
    *Q2 = select META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_NAME = *Name;
    foreach (*R2 in *Q2) { *Val = *R2.META_COLL_ATTR_VALUE; }
  } else {
    if (*Cont == "1") {
      writeLine ("stdout", "Did not find required metadata");
      racNotify (*Archive, "Missing *Name attribute on *Coll");
    }
  }
}
racNotify (*Archive, *Msg) {
# Policy function to send notification
# Email address is given by value of Archive-Email on GLOBAL_ACCOUNT/*Archive
  racCheckMsg(*Msg, *Msgt);
  msiGetSystemTime (*Tim, "human");
  *Body = "Please set attribute Archive-Email on *Archive";
  *Col = GLOBAL_ACCOUNT ++ "/*Archive";
  isColl (*Col, "stdout", *St);
  *Q1 = select count(META_COLL_ATTR_VALUE) where COLL_NAME = *Col and META_COLL_ATTR_NAME = "Archive-Email";
  foreach (*R1 in *Q1) { *Num = *R1.META_COLL_ATTR_VALUE; }
  *Note = "  Notification message";
  if (*Num == "0") {
# notify the repository administrator that the Archive-Email address is missing
    *C = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
    isColl (*C, "stdout", *Sta);
    *Q2 = select count(META_COLL_ATTR_VALUE) where COLL_NAME = *C and META_COLL_ATTR_NAME = "Repository-Email";
    foreach (*R2 in *Q2) { *N = *R2.META_COLL_ATTR_VALUE; }
    if (*N != "0") {
      *Q2a = select META_COLL_ATTR_VALUE where COLL_NAME = *C and META_COLL_ATTR_NAME = "Repository-Email";
      foreach (*R2a in *Q2a) { 
        *Add = *R2a.META_COLL_ATTR_VALUE;
        msiSendMail (*Add, "Response required, missing metadata", *Body);
        *Note = "Sent message about Missing metadata to *Add about *Body on *Tim";
        writeLine ("stdout", "*Note");
      }
    } else { writeLine ("stdout", "Missing E-mail for administrator"); }
  } else {
    *Q3 = select META_COLL_ATTR_VALUE where COLL_NAME = *Col and META_COLL_ATTR_NAME = "Archive-Email";
    foreach (*R3 in *Q3) {
      *Add = *R3.META_COLL_ATTR_VALUE;
      *Note = *Note ++ "Sent message to *Add about *Msg on *Tim\n";
      msiSendStdoutAsEmail (*Add, *Msgt);
    }
    writeLine ("stdout", "*Note");
  }
# log all notifications in Archive-PAA
  racWriteManifest ("Archive-PAA", *Archive, *Note);
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
  *Flags = "destRescName=*Res++++forceFlag=";
# overwrite existing file
  msiDataObjCreate(*Path, *Flags, *L_FD);
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
INPUT *Archive=$"Archive-A"
OUTPUT ruleExecOut
