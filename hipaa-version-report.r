storeSystemLog {
# hipaa-version-report.r
# Stores report in /UNC-CH/home/HIPAA/Reports
# Saves a versioned copy on local disk with the name DisclosureReport
  checkRescInput (*destRescName, $rodsZoneClient);
  *Coll = "/UNC-CH/home/HIPAA/Reports";
  *File = "DisclosureReport";
  *Path = "*Coll/*File";
# check whether the report already exists
  *Q1 = select count(DATA_ID) where DATA_NAME = '*File' and COLL_NAME = '*Coll';
  foreach (*R1 in *Q1) {*Count = *R1.DATA_ID;}
  if (*Count == '1') {
# File already exists, create version
    *Dest = '*Coll/Backup/*File';
    msiStoreVersionWithTS(*Path, *Dest, *Status);
  }
  msiDataObjPut(*Path, *destRescName, "localPath=./*File++++forceFlag=", *Status);
}
INPUT *destRescName = "hipaaResc"
OUTPUT ruleExecOut

