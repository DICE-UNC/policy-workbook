verifyAttribute {
  racGlobalSet ();
# rac-verifyAttribute.r
# Policy47 is a modification to Policy43, rac-verifyMetadata.r to send an error message
# Use the attribute *Type to determine whether working with GLOBAL_SIPS or GLOBAL_ARCHIVES
# Compare the metadata attributes on the GLOBAL_SIPS or GLOBAL_ARCHIVES collection
# and verify they are present on each SIP or AIP
  msiGetSystemTime (*Tim, "human");
  *Found = "0";
  if (*Type == "SIP") {
    *C = GLOBAL_SIPS;
    *Met = "RequiredSIP";
    *Rep = "Archive-SIPCRA";
    *Found = "1";
  }
  if (*Type == "AIP" ) {
    *C = GLOBAL_ARCHIVES;
    *Met = "RequiredAIP";
    *Rep = "Archive-AIPCRA";
    *Found = "1";
  }
  if (*Found != "1") {
    writeLine ("stdout", "Input value for \*Type should be either SIP or AIP");
    fail;
  }
  writeLine ("stdout", "Analyze *Type for required metadata on *Tim");
# List all missing metadata on the files in the collection
  *Ier = "0";
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/*C";
  *Q1 = select COLL_NAME where COLL_NAME like '*Coll%';
#Loop over collections
  foreach(*R1 in *Q1) {
    *C = *R1.COLL_NAME;
#Count number of *Type  metadata attributes on the collection
    *Q12 = select count(META_COLL_ATTR_NAME) where COLL_NAME = '*C' and META_COLL_ATTR_VALUE = *Met;
    foreach (*R12 in *Q12) {
      *Count = *R12.META_COLL_ATTR_NAME;
    }
#Count the number of files in the collection
    *Q13 = select count(DATA_NAME) where COLL_NAME = '*C';
    foreach (*R13 in *Q13) {
      *Numfiles = *R13.DATA_NAME;
    }
    if(int(*Numfiles) > 0) {
      if (int(*Count) > 0) {
#Loop over the metadata attributes on the collection
        *Q2 = select order_asc(META_COLL_ATTR_NAME) where COLL_NAME = '*C' and META_COLL_ATTR_VALUE = *Met;
        foreach (*R2 in *Q2) {
          *NameColl = *R2.META_COLL_ATTR_NAME;
#Loop over the files in the collection
          *Q3 = select DATA_NAME where COLL_NAME = '*C';
          foreach (*R3 in *Q3) {
            *File = *R3.DATA_NAME;
            *Q14 = select count(META_DATA_ATTR_NAME) where COLL_NAME = '*C' and DATA_NAME = '*File';
#Count the number of metadata attributes on a file
            foreach (*R14 in *Q14) {
              *Countf = *R14.META_DATA_ATTR_NAME;
            }
            *Found = 0;
            if (int(*Countf) > 0) {
#Loop over the tags on a file
              *Q4 = select order_asc(META_DATA_ATTR_NAME) where COLL_NAME = '*C' and DATA_NAME = '*File';
              foreach(*R4 in *Q4) {
                *Name = *R4.META_DATA_ATTR_NAME;
                if (*NameColl == *Name) {
                  *Found = 1;
                  break;
                }
              }
            }
#For missing metadata attributes, print a line to the screen
            if (*Found == 0) {
              writeLine("stdout","*C/*File is missing *NameColl on *Tim");
              *Ier = "1";
            }
          }
        }
      }
    }
  }
  if(*Ier == "1") { racNotify(*Archive, "See *Rep for missing attributes"); }
  racWriteManifest (*Rep, *Archive, "stdout");
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
INPUT *Archive=$"Archive-A", *Type=$"SIP"
OUTPUT ruleExecOut

