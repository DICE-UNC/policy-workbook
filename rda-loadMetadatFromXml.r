myTestRule {
# rda-loadMetadataFromXml.r
#Input parameters
# targetObj- iRODS target file that metadata will be attached to, null if Target is specified
# xmlObj- iRODS path to XML file that metadata is drawn from
#    xmlObj is assumed to be in AVU-format
#
#    This format is created by transforming the original XML file
#       using an appropriate style sheet as shown in rulemsiXsltApply.r
#    This micro-service requires libxml2.

  *targetObj = "/$rodsZoneClient/home/$userNameClient/" ++ *targetObj;
  *xmlObj = "/$rodsZoneClient/home/$userNameClient/" ++ *xmlObj;
  if (*targetObj != "") {checkPathInput (*targetObj);}
  checkPathInput (*xmlObj);
  msiLoadMetadataFromXml(*targetObj, *xmlObj);
#write message to stdout
  writeLine("stdout","Extracted metadata from *xmlObj and attached to *targetObj");
}
INPUT *xmlObj=$"Rules/sample.xml", *targetObj=$"Rules/ruleID.r"
OUTPUT ruleExecOut
