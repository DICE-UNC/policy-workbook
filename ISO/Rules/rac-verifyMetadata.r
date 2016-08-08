verifyMetadata {
  racGlobalSet ();
# Policy43
# rac-verifyMetadata.r
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
# List all missing metadata on the files in the collection
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
            }
          }
        }
      }
    }
  }
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
