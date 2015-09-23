getTechReport {
# hipaa-tech-report.r
# Gets report from /UNC-CH/home/HIPAA/Reports
# Saves copy on local disk with the name TechVersionReport
  *Coll = "/UNC-CH/home/HIPAA/Reports";
  *File = "TechVersionReport";
  *Path = "*Coll/*File";
  msiDataObjGet(*Path, "localPath=./*File++++forceFlag=", *Status);
}
INPUT null
OUTPUT ruleExecOut
