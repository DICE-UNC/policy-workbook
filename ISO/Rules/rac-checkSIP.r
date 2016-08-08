checkSIP {
  racGlobalSet ();
# check a SIP for compliance with preservation policies
# rac-checkSIP.r
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  *Path = "*Coll/*File";
  msiGetSystemTime (*Tim, "human");
  writeLine ("stdout", "Check SIP *Path for compliance on *Tim");
  *Cmply = "1";
# check for viruses
  racGetAVUMetadata (*Archive, *Path, "Archive-CheckVirus", "0", *Val2);
  if (*Val2 == "1") { 
    racVirusCheck (*File, *Coll, *S2);
    if (*S2 == "1") { *Cmply = "2"; }
  }
# check for protected data
  racGetAVUMetadata (*Archive, *Path, "Archive-CheckProtected", "0", *Val3);
  if (*Val3 == "1") { 
    racProtectedDataCheck (*File, *Coll, *Archive, *S3);
    if (*S3 == "1") { *Cmply = "3"; }
  }
# check data format
  racGetAVUMetadata (*Archive, *Path, "Archive-CheckFormat", "0", *Val4);
  if (*Val4 == "1") { 
    racFormatCheck (*File, *Coll, *Archive, *S4);
    if (*S4 == "1") { *Cmply = "4"; }
  }
# check metadata
  racGetAVUMetadata (*Archive, *Path, "Archive-CheckMetadata", "0", *Val5);
  if (*Val5 == "1") { 
    racMetadataCheck (*File, *Coll, *Archive, *S5);
    if (*S5 == "1") { *Cmply = "5"; }
  }
# check reserved vocabulary
  racGetAVUMetadata (*Archive, *Path, "Archive-CheckVocab", "0", *Val6);
  if (*Val6 == "1") { 
    racReservedVocabCheck (*File, *Coll, *Archive, *S6);
    if (*S6 == "1") { *Cmply = "6"; }
  }
# check integrity
  racGetAVUMetadata (*Archive, *Path, "Archive-CheckIntegrity", "0", *Val7);
  if (*Val7 == "1") {
    racIntegrityCheck (*File, *Coll, *Archive, *S7);
    if (*S7 == "1") { *Cmply = "7"; }
  }
# check duplication
  racGetAVUMetadata (*Archive, *Path, "Archive-CheckDup", "0", *Val8);
  if (*Val8 == "1") {
    racDupCheck (*File, *Coll, *Archive, *S8);
    if (*S8 == "1") { *Cmply = "8"; }
  }
  addAVUMetadata (*Path, "Audit-Comply", *Cmply, *Tim, *Stat);
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
  *Q1 = select count(META_COLL_ATTR_VALUE) where COLL_NAME = *Col and META_COLL_ATTR_NAME = "Archive-Email";
  foreach (*R1 in *Q1) { *Num = *R1.META_COLL_ATTR_VALUE; }
  if (*Num == "0") {
# notify the repository administrator that the Archive-Email address is missing
    *C = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
    *Q2 = select META_COLL_ATTR_VALUE where COLL_NAME = *C and META_COLL_ATTR_NAME = "Repository-Email";
    foreach (*R2 in *Q2) { *Add = *R2.META_COLL_ATTR_VALUE; }
    msiSendMail (*Add, "Response required, missing metadata", *Body);
    *Note = "Sent message about Missing metadata to *Add about *Body on *Tim";
    writeLine ("stdout", "*Note");
  } else {
    *Q3 = select META_COLL_ATTR_VALUE where COLL_NAME = *Col and META_COLL_ATTR_NAME = "Archive-Email";
    *Note = "";
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

racVirusCheck (*File, *Coll, *S2) {
# policy function to evaluate a file for viruses
# use clamscan to check for viruses
  *Path = "*Coll/*File";
  *Res = GLOBAL_STORAGE;
  *S2 = "0";
  *Q1 = select DATA_PATH where DATA_NAME = '*File' and COLL_NAME = '*Coll';
  foreach (*R1 in *Q1) {*Objpath = *R1.DATA_PATH;}
  *Val = "0";
  *Text = "Passed Virus";
  *Name = "Audit-CheckVirus";
  acScanFileAndFlagObject (*Objpath, *Path, *Res);
  *Q2 = select count(META_DATA_ATTR_NAME) where DATA_NAME = '*File' and COLL_NAME = '*Coll' and META_DATA_ATTR_NAME like 'VIRUS_SCAN_PASSED%';
  foreach (*R2 in *Q2) {
    *Num = *R2.META_DATA_ATTR_NAME;
    if ( *Num == "0") {
      *Val = "1";
      *Text = "Failed Virus";
      *S2 = "1";
    }
  }
  if (*S2 != "1") {*S2 = "2";}
  addAVUMetadata (*Path, *Name, *Val, *Text, *Stat);
}
racProtectedDataCheck (*Files, *Coll, *Archive, *S3) {
# policy function to check for PII, PHI, PCI using Bitcurator
# expects a working directory, currently /tmp/bcworking specified below,
# to exist and be writable by the user running the script.
  *outFeatDir= GLOBAL_ACCOUNT ++ "/*Archive/tmp";
  *S3 = "0";
  isColl (*outFeatDir, "status", *Stat);
  *Report="BulkExtractor";
  *Col = GLOBAL_ACCOUNT ++ "/*Archive";
  *Q1 = select count(META_COLL_ATTR_VALUE) where COLL_NAME = *Col and META_COLL_ATTR_NAME = "Archive-Email";
  foreach (*R1 in *Q1) { *Num = *R1.META_COLL_ATTR_VALUE; }
  if (*Num == "0") {
# notify the repository administrator that the Archive-Email address is missing
    *C = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
    *Q2 = select META_COLL_ATTR_VALUE where COLL_NAME = *C and META_COLL_ATTR_NAME = "Repository-Email";
    foreach (*R2 in *Q2) { *Add = *R2.META_COLL_ATTR_VALUE; }
    msiSendMail (*Add, "Response required, missing metadata", *Body);
    writeLine ("stdout", "Missing metadata for Archive-Email on *Col");
    fail;
  } else {
    *Q3 = select META_COLL_ATTR_VALUE where COLL_NAME = *Col and META_COLL_ATTR_NAME = "Archive-Email";
    foreach (*R3 in *Q3) {
      *Archivist = *R3.META_COLL_ATTR_VALUE;
    }
  }
  *Cmd="bulk_extractor";
  *timeStamp = double (time());
# Make a query to get the path to the image and the resource name
# DATA_PATH: Physical path name for digital object in resource
# DATA_RESC_NAME: Logical name of storage resource
  *Query = select DATA_NAME,DATA_REPL_NUM, DATA_PATH,DATA_RESC_NAME,COLL_NAME where COLL_NAME = '*Coll' and DATA_NAME = *Files;
  foreach (*row in *Query) {
    *Repn = *row.DATA_REPL_NUM;
    if (*Repn == "0") {
      *Path = *row.DATA_PATH;
      *CollPath = *row.COLL_NAME;
      *Resource = *row.DATA_RESC_NAME;
      *File = *row.DATA_NAME
# Make another query for IP Address of the resource
# RESC_LOC: Resource IP Address
# DATA_RESC_NAME: Logical name of storage resource
      *Query2 = select RESC_LOC where DATA_RESC_NAME = '*Resource';
      foreach (*row in *Query2) {
        *Addr = *row.RESC_LOC;
      }
      *prefixStr = "*File";
      *tempStr = "/tmp/bcworking/*prefixStr" ++ "outFeatDir";
      *Arg1 = execCmdArg(*Path);    # Image
      *Arg2 = execCmdArg("-o");
      *Arg3 = execCmdArg(*tempStr); # Output Feature Directory
      if (errorcode(msiExecCmd(*Cmd,"*Arg1 *Arg2 *Arg3","null","null","null",*Result)) < 0) {
          if(errormsg(*Result,*msg)==0) {
              msiGetStderrInExecCmdOut(*Result,*Out);
          }
      } else {
# Command executed successfully
        msiGetStdoutInExecCmdOut(*Result,*Out);
# run shell script to list iRODS path to files suspected to contain PII or CCN
        msiExecCmd("list_suspected_sensitive.sh", *s1, "null", "null", "null", *SResult);
        msiGetStdoutInExecCmdOut(*SResult, *Out);
        *s = split(*Out, "\n");
        writeLine("stdout", "Debug: Suspected sensitive files: *s");
        foreach (*item in *s) {
          addAVUMetadata(*item, "CURATOR_REVIEW", "Sensitive", "*timeStamp", *Status);
          addAVUMetadata (*item, "Audit-CheckProtected", "1", "*timeStamp", *Status);
          *S3 == "1";
        }
# remove working subdirectories
        remote(*Addr, "null") {
          msiExecCmd("tmpCleanup.sh", "null", "null", "null", "null", *Result);
        }
      }
    }
  }
  if (*S3 != "1") {
    *S3 = "2";
    addAVUMetadata ("*Coll/*Files", "Audit-CheckProtected", "2", "*timeStamp", *Status);
  }
}
racFormatCheck (*File, *Coll, *Archive, *S4) {
# Policy function to check the format of a SIP
# Required format type is Archive-Format saved as an attribute on GLOBAL_SIPS
  *S4 = "0";
  *F = "";
  msiGetSystemTime (*Tim, "human");
  *Q0 = select DATA_TYPE_NAME where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R0 in *Q0) {  *F = *R0.DATA_TYPE_NAME; }
  if (*F == "") {
    splitPathByKey (*File, ".", *Head, *F);
  }
  *C = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *C and META_COLL_ATTR_NAME = "Archive-Format";
  foreach (*R1 in *Q1) {
    *Form = *R1.META_COLL_ATTR_VALUE;
    if (*Form == *F) {
      *S4 = "1";
      break;
    }
  }
  if (*S4 != "1") { *S4 = "2"; }
  addAVUMetadata ("*Coll/*File", "Audit-CheckFormat", *S4, *Tim, *Stat);
}
racMetadataCheck (*File, *Coll, *Archive, *S5) {
# Policy function to check SIP has required metadata
# Required metadata are stored as attributes on GLOBAL_ACCOUNT/*Archive/GLOBAL_SIPS
  msiGetSystemTime (*Tim, "human");
  *S5 = "0";
  *Q1 = select META_COLL_ATTR_NAME, META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_VALUE = "RequiredSIP";
  foreach (*R1 in *Q1 ) {
    *Name = *R1.META_COLL_ATTR_NAME;
# check presence of metadata attribute on the SIP
    *Q2 = select count(META_DATA_ATTR_NAME) where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = *Name;
    foreach (*R2 in *Q2) {
      *Num = *R2.META_DATA_ATTR_NAME;
      if (*Num == "0") {
        *S5 = "1";
        break;
      }
    }
  }
  if (*S5 != "1" ) { *S5 = "2"; }
    addAVUMetadata ("*Coll/*File", "Audit-CheckMetadata", *S5, *Tim, *Stat);
}
racReservedVocabCheck (*File, *Coll, *Archive, *S6) {
# Policy function to verify descriptive metadata against reserved vocabulary
  msiGetSystemTime (*Tim, "human");
  *S6 = "0";
  *Q0 = select count(META_DATA_ATTR_VALUE) where COLL_NAME = '*Coll' and DATA_NAME = '*File' and META_DATA_ATTR_NAME = "Archive-Description";
  foreach (*R0 in *Q0) { *Num = *R0.META_DATA_ATTR_VALUE; }
  if (*Num == "0") {
    *S6 = "1";
  } else {
    foreach(*R4 in *Q4) {
      *Str = *R4.META_DATA_ATTR_VALUE;
      split (*Str, *L);
      foreach (*S in *L) {
        msiCurlUrlEncodeString(*S, *encodedUrl);
        *url = "http://localhost:8080/hive-voccabservice-rest-1.0-SNAPSHOT/rest/concept/uat/concept?uri=" ++  str(*encodedUrl);
        msiCurlGetStr(*url, *outStr);
        if (*outStr like "\*DataNotFoundException\*") { *S6 = "1"; }
      }
    }
  }
  if (*S6 != "1") { *S6 = "2"; }
  addAVUMetadata ("*Coll/*File", "Audit-CheckVocab", *S6, *Tim, *Status);
}
racIntegrityCheck (*File, *Coll, *Archive, *S7) {
#  Policy function to check integrity of a SIP
  *Chk = "";
  *Q1 = select DATA_CHECKSUM where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) { *Chk = *R1.DATA_CHECKSUM; }
  msiDataObjChksum ("*Coll/*File", "forceChksum=", *Chksum);
  if (*Chk != *Chksum) { *S7 = "1"; }
  else {
    *S7 = "2";
  }
}
racDupCheck (*File, *Coll, *Archive, *S8) {
# Policy function to check whether AIP already exists
# AIPs are stored in GLOBAL_ACCOUNT/*Archive/GLOBAL_AIPS
  msiGetSystemTime (*Tim, "human");
  *Ca = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_AIPS;
  *S8 = "0";
  *Q1 = select count (DATA_NAME) where DATA_NAME = *File and COLL_NAME = *Ca;
  foreach (*R1 in *Q1 ) {
    *Num = *R1.DATA_NAME;
    if (*Num == "0") {
      *S8 = "1";
    }
  }
  if (*S8 != "1" ) { *S8 = "2"; }
  addAVUMetadata ("*Coll/*File", "Audit-CheckDup", *S8, *Tim, *Stat);
}
INPUT *File=$"rec3", *Archive=$"Archive-A"
OUTPUT ruleExecOut

