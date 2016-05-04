myTestRule {
#Rule available at /lifelibZone/home/rwmoore/Rules/test-loadMetaDataFromXml.r
#Input parameters
# targetObj	- iRODS target file that metadata will be attached to
# xmlObj	- iRODS path to XML file that metadata is drawn from
#    xmlObj is assumed to be in AVU-format
  *targetObj = "/$rodsZoneClient/home/$userNameClient/" ++ *targetObj;
  *xmlObj = "/$rodsZoneClient/home/$userNameClient/" ++ *xmlObj;
  msiLoadMetadataFromXml(*targetObj, *xmlObj);
#write message to stdout
  writeLine("stdout","Extracted metadata from *xmlObj and attached to *targetObj");
}
INPUT *xmlObj=$"Rules/sample.xml", *targetObj=$"Rules/ruleID.r"
OUTPUT ruleExecOut
