storeLog {
# hipaa-store-log.r
# Stores report in /UNC-CH/home/HIPAA/Reports
# Saves copy on local disk with the name LogSoftwareChanges
  *Coll = "/UNC-CH/home/HIPAA/Reports";
  *File = "LogSoftwareChanges";
  *Path = "*Coll/*File";
  msiDataObjPut(*Path, *destRescName, "localPath=./*File++++forceFlag=", *Status);
}
INPUT *destRescName = “hipaaResc”
OUTPUT ruleExecOut
