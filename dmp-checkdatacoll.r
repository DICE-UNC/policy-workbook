checkColl {
# checks whether a path is a collection
  *Query0 = select count(COLL_ID) where COLL_NAME = '*LPath';
  foreach(*Row0 in *Query0) {*Result = *Row0.COLL_ID;}
  if(*Result == "1" ) {
    writeLine ("stdout", "*LPath is a collection");
  }
  else {
    msiSplitPath (*LPath, *Coll, *File);
    *Q2 = select count(DATA_ID) where COLL_NAME = '*Coll' and DATA_NAME = '*File';
    foreach(*R2 in *Q2) {*Num = *R2.DATA_ID;}
    if (*Num > "0" ) {
      writeLine ("stdout", "*LPath is a file, Collection = *Coll, File = *File");
    }
  }
}
INPUT *LPath =$"/Zone/home/id/file"
OUTPUT ruleExecOut
