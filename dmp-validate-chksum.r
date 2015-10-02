validateChecksums {
# dmp-validate-chksum.r
# Each file is checked to verify whether they have valid checksums
# Writes a log file stored as Check-Timestamp in directory *Coll/log
  checkRescInput (*uncResc, $rodsZoneClient);
  *NumBadFiles = 0;
  *NumFiles = 0;
#========= check whether a collection was defined ===============================
  checkCollInput(*Coll);
#============ create a collection for log files if it does not exist ===============
  createLogFile (*Coll, "log", "Check", *Res, *LPath, *Lfile, *L_FD);
#============== loop over all the files in the collection ===============
  *Q1 = select DATA_ID, DATA_NAME, COLL_NAME, DATA_CHECKSUM where COLL_NAME = '*Coll';
  foreach(*R1 in *Q1) {
    *NumFiles = *NumFiles + 1;
    *newdataID = *R1.DATA_ID;
    *Name = *R1.DATA_NAME;
    *Colln = *R1.COLL_NAME;
    *Chk = *R1.DATA_CHECKSUM;
    msiDataObjChksum("*Colln/*Name", "forceChksum=", *Chkf);
    if(int(*Chk) == 0) {
      *Chk = *Chkf;
    }  # end of set of checksum if not available
#======== check whether checksum is correct =========
    if (int(*Chk) != int(*Chkf)) {
      writeLine("*Lfile”, “Bad checksum for file *Colln/*Name with DATA_ID *newdataID.");
      *NumBadFiles = *NumBadFiles + 1;
    }  # end of processing a bad checksum
  }
  writeLine("*Lfile", "Found *NumBadFiles bad files out of *NumFiles files");
}  # end of micro-service code
INPUT *Coll=$"/$rodsZoneClient/home/$userNameClient”, *Res="uncResc"
OUTPUT ruleExecOut
