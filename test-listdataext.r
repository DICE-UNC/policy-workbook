testListDataExt {
# test-listdataext.r
# list all of the data extension in a collection
# find data type from the extension
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Rcoll";
  *Typ.total = str(0);
  *Q1 = select DATA_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *Name = *R1.DATA_NAME;
    *Type = ext(*Name);
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
