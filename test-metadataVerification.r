myProductionOperationsRule {
#test-metadataVerification.r
#Rule to demonstrate select production operations and associated policies
#Rule checks input parameters, creates a log file to track changes to files, verifies required metadata on files, and writes results to the log file
#Assumes that a collection metadata schema has been defined by setting a metadata attribute on the collection with a value of "null"
#Rule executes periodically

#Check input parameters
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Coll";
  checkCollInput(*Coll);
  writeLine("stdout", "Delay rule queued to periodically verify required metadata");
  delay("<PLUSET>1s</PLUSET><EF>7d</EF>") {

#Get current time, Timestamp is YYY-MM-DD.hh:mm:ss
    msiGetSystemTime(*TimeS,"unix");
	
#Create a log file stored as Check-Timestamp in directory *Coll/log
    createLogFile (*Coll, "log", "Check", *Res, *LPath, *Lfile, *L_FD); 

#List all missing metadata on the files in a collection
    *Q1 = select COLL_NAME where COLL_NAME like "*Coll%";

#Loop over collections
    foreach(*R1 in *Q1) {
      *C = *R1.COLL_NAME;
      *Q12 = select count(META_COLL_ATTR_NAME) where COLL_NAME = "*C" and META_COLL_ATTR_VALUE = "null";
      *Count = 0;
#Count number of null metadata attributes on the collection
      foreach (*R12 in *Q12) {
        *Count = int(*R12.META_COLL_ATTR_NAME);
      }
      *Q13 = select count(DATA_NAME) where COLL_NAME = "*C";
	
#Count the number of files in the collection
      *Numfiles = 0;
      foreach (*R13 in *Q13) {
        *Numfiles = int(*R13.DATA_NAME);
      }
      if(*Numfiles > 0) {
        if (*Count > 0) {
	  
#Loop over the null metadata attributes on the collection
          *Q2 = select order_asc(META_COLL_ATTR_NAME) where COLL_NAME = "*C" and META_COLL_ATTR_VALUE = "null";
          foreach (*R2 in *Q2) {
            *NameColl = *R2.META_COLL_ATTR_NAME;
		  
#Loop over the files in the collection
            *Q3 = select DATA_NAME where COLL_NAME = "*C";
            foreach (*R3 in *Q3) {
              *File = *R3.DATA_NAME;
              *Q14 = select count(META_DATA_ATTR_NAME) where COLL_NAME = "*C" and DATA_NAME = "*File" and META_DATA_ATTR_UNITS != "iRODSUserTagging:Tag";
			
#Count the number of metadata attributes on a file
              *Countf = 0;
              foreach (*R14 in *Q14) {
                *Countf = int(*R14.META_DATA_ATTR_NAME);
              }
              *Found = 0;
              if (*Countf > 0) {
			
#Loop over the tags on a file 
                *Q4 = select order_asc(META_DATA_ATTR_NAME) where COLL_NAME = "*C" and DATA_NAME = "*File" and META_DATA_ATTR_UNITS != "iRODSUserTagging:Tag";
                foreach(*R4 in *Q4) {
                  *Name = *R4.META_DATA_ATTR_NAME;
                  if (*NameColl == *Name) {
                    *Found = 1;
                    break;
                  } 
                }
              }
			
#For missing metadata attributes, print a line to the log file
              if (*Found == 0) {
                writeLine("*Lfile", "*C/*File is missing *NameColl");
              }
            }
          }
        }
      }
    }
  }
}

INPUT *Coll = "test1", *Res = "LTLResc"
OUTPUT ruleExecOut

