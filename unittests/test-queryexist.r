testQueryExists {
# check whether an attribute already exists
  *Attname = "CURATOR_REVIEW";
  *Attvalue = "Bad_Checksum";
  *Attunit = "";
  *File = "test";
  *Coll = "/rodsZoneClient/home/$userNameClient";
  *Path = "*Coll/*File";
  *Q1 = count (META_DATA_ATTR_ID) where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = *Attname and META_DATA_ATTR_VAL = *Attvalue and META_DATA_ATTR_UNITS = *Attunit;
  foreach (*R1 in *Q1) {
    *num = *R1.META_DATA_ATTR_ID;
    if (*num == "0") {
# create the metadata attribute
      msiSetAVU("-d", *Path, *Attname, *Attvalue, *Aunit);
    }
  }
}
INPUT null
OUTPUT ruleExecOut
