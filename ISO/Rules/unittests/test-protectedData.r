testProtectedData = maint
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_RESPOSITRY = "Repository"
GLOBAL_SIPS = "SIPS"
maint {
# check for protected data by calling Bitcurator
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  racProtectedDataCheck (*File, *Coll, *Archive, *S3);
  writeLine ("stdout", "Status is *S3");
}
racProtectedDataCheck (*Files, *Coll, *Archive, *S3) {
# policy function to check for PII, PHI, PCI using Bitcurator
# expects a working directory, currently /tmp/bcworking specified below,
# to exist and be writable by the user running the script.
  *outFeatDir= GLOBAL_ACCOUNT ++ "/*Archive/tmp";
  *S3 = "0";
  isColl (*outFeatDir, "status", *Stat);
  *Report="BulkExtractor";
  *Col = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_ARCHIVES;
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
          addAVUMetadata (*item, "Audit-CheckVirus", "1", "*timeStamp", *Status);
          *S3 = "1";
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
    addAVUMetadata (*Files, "Audit-CheckVirus", "2", "*timeStamp", *Status);
  }
}
INPUT *Archive=$"Archive-A", *File=$"rec3"
OUTPUT ruleExecOut
