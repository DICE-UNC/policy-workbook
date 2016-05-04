testSetDataType {
# check the microservice msiSetDataType
  *Coll = "/$rodsZoneClient/home/$userNameClient/test";
  *File = "file1.txt";
  *Path = "*Coll/*File";
  *Q1 = select DATA_ID where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) {
    *Id = *R1.DATA_ID;
  }
  msiSetDataType (*Id, *Path, "text", *Status);
  writeLine ("stdout", "Set type on file1.txt");
}
INPUT null
OUTPUT ruleExecOut 
