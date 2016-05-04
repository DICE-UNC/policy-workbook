acPostProcForPut{
#this micro-service is creating the path for the rule to follow, defining the collection the rule will operate on
  msiSplitPath ($objPath, *Coll, *File);
  if (*Coll == "/lifeLibZone/home/kelsey3/Class-INLS624") {
#this micro-service is creating a checksum for each file in the collection and attaching it to the files
    msiDataObjChksum($objPath,	"forceChksum=",	*Chksum);
    *Q1	= select DATA_SIZE where DATA_NAME = '*File' and COLL_NAME = '*Coll';
    foreach (*R1 in *Q1) {*Size = *R1.DATA_SIZE;}
#this micro-service is attaching the system time (in human format) to each file in the collection
    msiGetSystemTime(*Tim, "human");
    *LPath = "/lifeLibZone/home/kelsey3/Class-INLS624/test"
#this micro-service is opening the object following the defined path
    msiDataObjOpen(*LPath, *Fdesc);
#this micro-service is performing a seek on the objects found to be sure they exist?
    msiDataObjLseek(*Fdesc, "0", "SEEK_END", *Stat);
#this microservice is printing out the time, file size, and checksum attached to each file under the selected collection
    writeLine("*LPath",	"*Tim *File, Size *Size, Checksum *Chksum");
  }
}
