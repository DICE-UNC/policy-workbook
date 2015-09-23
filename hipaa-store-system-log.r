storeSystemLog {
# hipaa-store-system-log.r
# Stores report in /UNC-CH/home/HIPAA/Reports
# Saves copy on local disk with the name LogSoftwareChanges
  *Coll = "/UNC-CH/home/HIPAA/Reports";
  *File = "LogSystemType";
  *Path = "*Coll/*File";
  msiDataObjPut(*Path, *destRescName, "localPath=./*File++++forceFlag=", *Status);
}
INPUT *destRescName = "hipaaResc"
OUTPUT ruleExecOut
