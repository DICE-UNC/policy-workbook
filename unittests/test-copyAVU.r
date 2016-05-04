testAVUCopy {
# copy metadata from one file to another
  *Paths = "/$rodsZoneClient/home/$userNameClient/test/file1.txt";
  *Pathd = "/$rodsZoneClient/home/$userNameClient/test/file1";
  msiCopyAVUMetadata(*Paths, *Pathd, *Status);
  msiSplitPath (*Pathd, *Coll, *File);
  *Q1 = select META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE, META_DATA_ATTR_UNITS where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) {
    *N = *R1.META_DATA_ATTR_NAME;
    *V = *R1.META_DATA_ATTR_VALUE;
    *U = *R1.META_DATA_ATTR_UNITS;
    writeLine ("stdout", "For *Coll/*File attname=*N, attval=*V, attunit=*U");
  }
}
INPUT null
OUTPUT ruleExecOut
