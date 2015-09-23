listRule {
# rda-setconv.r
#Check files in a staging area
#Set conversion flag "Conversion" to "ConvertMe" for specified file types
#Check file types for Microsoft word
#Input parameters
#  Relative path to staging area is *Collrel
  msiAddKeyVal(*Keyval, "Conversion", "ConvertMe");
#Generate full path name to staging area
  *Coll= "/$rodsZoneClient/home/$userNameClient/" ++ "*Collrel";
  checkCollInput(*Coll);
  *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
#Loop over files in the collection
  foreach(*R1 in *Q1) {
    *D = *R1.DATA_NAME;
    *Q2 = select DATA_TYPE_NAME where DATA_NAME = '*D' and COLL_NAME = '*Coll';
    *Data = *Coll ++ "/" ++ *D;
#Set conversion flag for specified data types
    foreach(*R2 in *Q2) {
      *T = *R2.DATA_TYPE_NAME;
      if(*T == "*Type") {
        writeLine("stdout","Convert file *Data");
        msiAssociateKeyValuePairsToObj(*Keyval,*Data,"-d");
      }
    }
  }
}
INPUT *Type="Word format", *Collrel = "sub2"
OUTPUT ruleExecOut
