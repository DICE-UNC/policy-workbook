assetClassifier {
# hipaa-asset-report.r
# Count the number of files with each type of classifier in a collection
  checkCollInput (*Coll);
  *Q1 = select count(DATA_ID) where COLL_NAME = *Coll and META_DATA_ATTR_NAME = "AssetProtectionClassifier" and META_DATA_ATTR_VALUE = "1";
  foreach(*R1 in *Q1) {*C1 = *R1.DATA_ID;}
  *Q2 = select count(DATA_ID) where COLL_NAME = *Coll and META_DATA_ATTR_NAME = "AssetProtectionClassifier" and META_DATA_ATTR_VALUE = "2";
  foreach(*R2 in *Q2) {*C2 = *R2.DATA_ID;}
  *Q3 = select count(DATA_ID) where COLL_NAME = *Coll and META_DATA_ATTR_NAME = "AssetProtectionClassifier" and META_DATA_ATTR_VALUE = "3";
  foreach(*R3 in *Q3) {*C3 = *R3.DATA_ID;}
  *Q4 = select count(DATA_ID) where COLL_NAME = *Coll and META_DATA_ATTR_NAME = "AssetProtectionClassifier" and META_DATA_ATTR_VALUE = "4";
  foreach(*R4 in *Q4) {*C4 = *R4.DATA_ID;}
  *Q5 = select count(DATA_ID) where COLL_NAME = *Coll and META_DATA_ATTR_NAME = "AssetProtectionClassifier" and META_DATA_ATTR_VALUE = "5";
  foreach(*R5 in *Q5) {*C5 = *R5.DATA_ID;}
  writeLine("stdout", "Number of PHI files is *C1");
  writeLine("stdout", "Number of PII files is *C2");
  writeLine("stdout", "Number of PCI files is *C3");
  writeLine("stdout", "Number of classified files is *C4");
  writeLine("stdout", "Number of proprietary files in *C5");
}
INPUT *Coll=$"/UNC-HIPAA/home/HIPAA"
OUTPUT ruleExecOut

