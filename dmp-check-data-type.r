checkDataType {
# dmp-checkDataType.r
# Verify that all files within the sensor data collection have extension .csv
# except for the .xml files
  checkCollInput (*Col);
  *Q1 = select DATA_NAME, DATA_TYPE_NAME, COLL_NAME where COLL_NAME like '*Col%';
  foreach (*R1 in *Q1) {
    *Type = *R1.DATA_TYPE_NAME;
    if (*Type != "csv" && *Type != "xml") {
      *File = *R1.DATA_NAME;
      *Coll = *R1.COLL_NAME;
      writeLine("stdout", "Found an invalid data type *Type for *Coll/*File");
    }
  }
}
INPUT *Col = "/Mauna/home/atmos/sensor"
OUTPUT ruleExecOut
