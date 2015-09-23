getReport {
# hipaa-assesssment-report.r
# Gets report from /UNC-CH/home/HIPAA/Reports
# Saves copy on local disk with the name softwareAssessment
  *Coll = "/UNC-CH/home/HIPAA/Reports";
  *Path = "*Coll/*File";
  msiDataObjGet(*Path, "localPath=./*File++++forceFlag=", *Status);
}
INPUT *File = "softwareAssessment"
OUTPUT ruleExecOut
