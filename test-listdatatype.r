testListDataType {
# test-listdatatype.r
# list all of the data types in a collection
# find data type from DATA_TYPE_NAME
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Rcoll";
  *Typ.total = str(0);
  *Q1 = select DATA_TYPE_NAME,DATA_ID where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *Type = *R1.DATA_TYPE_NAME;
    *Typ.total = str(int(*Typ.total) + 1);
     if (contains(*Typ, *Type)) {
      *Typ.*Type = str(int(*Typ.*Type) + 1);
    } else {
      *Typ.*Type = str(1);
    }
  }
  foreach (*Type in *Typ) {
    *C1 = *Type;
    *C2 = *Typ.*Type;
    if (strlen(*C1) < 8) {*C1 = "*C1\t";}
    writeLine("stdout", "*C1   *C2");
  }
}
INPUT *Rcoll =$"Rules"
OUTPUT ruleExecOut
