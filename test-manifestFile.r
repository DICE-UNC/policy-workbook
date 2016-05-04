mywritedetailstomanifestfileRule {
# record the file size, date, and checksum of all the files in a collection to a report
# check to make sure the colection exists before moving on 
  checkCollInput(*Coll);
  msiGetSystemTime(*Time, "human");
# open report file
  *LPath = "/lifelibZone/home/culbert/SILSClasses/report" 
# microservice to open the manifest file
  msiDataObjOpen(*LPath, *Fdesc);
# microservice to find the end of the manifest file
  msiDataObjLseek(*Fdesc, "0", "SEEK_END", *Stat);
# loop over the files in the collection
  *Q1 = select DATA_NAME, DATA_SIZE where COLL_NAME = '*Coll';
  foreach (*R1 in *Q1 ) {
    *File = *R1.DATA_NAME;
    *Path = "*Coll/*File";
#microservice to generate checksum
    msiDataObjChksum(*Path, "forceChksum=", *Chksum);
    *Size = *R1.DATA_SIZE;
# writes information to manifest file
    writeLine("*LPath", "*Time, *File, Size *Size, Checksum *Chksum");
  }
  msiDataObjClose(*Fdesc, *Status);
}
INPUT *Coll=$"/lifelibZone/home/culbert/SILSClasses" 
OUTPUT ruleExecOut
