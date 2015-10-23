setDataType {
# odum-set-data-type.r
#Input parameter is:
#  Collection name
#Output parameters are:
#  Data type set in DATA_TYPE_NAME
#  Status
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Collrel";
  checkCollInput (*Coll);
  *Query = select DATA_NAME, COLL_NAME, DATA_ID where COLL_NAME like '*Coll%';
  foreach (*Row in *Query) {
    *File = *Row.DATA_NAME;
    *Collname = *Row.COLL_NAME;
    *Pathname = "*Collname/*File";
    *Objid = *Row.DATA_ID;
    *Head = *Pathname;
    *Type = "generic";
    *out = errormsg(msiSplitPathByKey (*Pathname, ".", *Head, *Type), *msg);
    *out2 = errormsg(msiSetDataType(*Objid, *Pathname, *Type, *Status), *msg1);
    writeLine("stdout", "File *Pathname has data type *Type");
  }
}
INPUT *Collrel="test"
OUTPUT ruleExecOut

