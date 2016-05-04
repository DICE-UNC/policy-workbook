testQuery {
# check whether a null result causes an error
  *Coll = "/$rodsZoneClient/home/$userNameClient";
  isData(*Coll, "guess", *Status);
  writeLine("stdout","*Status");
  *File = "foo";
  *Head = "";
  *End = "";
  *Stat = errormsg(msiSplitPathByKey(*File, ".", *Head, *End),*msg);
# msiSplitPathByKey(*File, ".", *Head, *End);
  writeLine ("stdout", "*Head, *End");
}
isData (*Coll, *File, *Status) {
# Check whether a file already exists
  *Q = select count(DATA_ID) where COLL_NAME = '*Coll' and DATA_NAME = '*File';
  foreach (*R in *Q) {
    *Status = *R.DATA_ID;
  }
  *Status;
}
INPUT null
OUTPUT ruleExecOut
