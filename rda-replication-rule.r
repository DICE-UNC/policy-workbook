periodicReplicaCreation {
# rda-replication-rule.r
# periodically check that required replicas are present, and create missing replicas
  checkCollInput (*Coll);
  checkRescInput (*Res, $rodsZoneClient);
  writeLine("stdout", "Delay rule queued to periodically verify the number of replicas");
  delay("<PLUSET>1s</PLUSET><EF>7d</EF>") {
# The replicas for each file are updated to the most recent version
# Each file is checked to verify whether all required replicas exist and have valid checksums
# As replicas are created, the algorithm round robins through available storage vaults
# Checks that the number of storage resources used within a collection is greater than or
#   equal to the number of desired replicas.
# This uses a just in time scheduler that slows down the processing rate
#   to complete the task within the specified number of seconds (*Delt)
# Checks a TEST_DATA_ID parameter associated with the collection
#   to determine enable restarts after system interrupts
# Writes a log file stored as Check-Timestamp in directory *Coll/log
#=============get current time, Timestamp is YYY-MM-DD.hh:mm:ss  ============
    msiGetSystemTime(*TimeS,"unix");
    *NumBadFiles = 0;
    *NumRepCreated = 0;
    *NumFiles = 0;
    *Runsize = double(0);
    *Sleeptime = 0;
    *colldataID = "0";
#this is used to round robin through available storage resources
    *Jround = 0;
    createLogFile (*Coll, "log", "Check", *Res, *LPath, *Lfile, *L_FD);
#== check whether the attribute TEST_DATA_ID has been set from a prior execution ====
    checkMetaExistsColl ("TEST_DATA_ID", *Coll, *Lfile, *colldataID);
    getNumSizeColl (*Coll, *colldataID, *Size, *Num);
#= expected execution time = 0.0161 (sec) * (number of files) + (total size) / (50 MBytes/sec) =
    *Timeest = int(*Num / 62) + int(*Size / 50000000);
    writeLine("*Lfile","Estimated time is *Timeest seconds, total time is *Delt seconds, number of files is *Num,  and total size is *Size bytes");
    writeLine("*Lfile","Number of required copies of a file is *NumReplicas");
    if(*Delt > 0 && *Size > 0) {
      *Fac = *Size / *Delt;
      writeLine("*Lfile", "Required analysis rate is *Fac bytes/second");
#============ identify the resources that were used for the collection ===============
      getRescColl (*Coll, *Rlist, *Ulist0, *Lfile, *Ir);
      *Irm1 = *Ir - 1;
      if(*Ir < *NumReplicas) {
        writeLine("*Lfile","Required number of replicas, *NumReplicas, exceeds the number of storage vaults, *Ir");
        fail;
      }  # end of check on number of available resources
#============== loop over all the files in the collection in batches of 256 ===============
      *iter = 0;
      *q2 = select order(DATA_ID), DATA_SIZE, DATA_NAME, COLL_NAME, DATA_CHECKSUM where COLL_NAME like '*Coll%' and DATA_ID > '*colldataID';
      foreach(*r2 in *q2) {
        *iter = *iter + 1;
        *Sizedata = *r2.DATA_SIZE;
        *newdataID = *r2.DATA_ID;
        *Name = *r2.DATA_NAME;
        *Colln = *r2.COLL_NAME;
        if(*Colln != *LPath) {
#======= before updating replicas, must verify that the replica has a valid checksum =========
          verifyReplicaChksum (*Colln, *Name, *Lfile, *Ir, *Rlist, *Ulist0, *Ulist, *Numr, *NumBadFiles); 
#========== pick resource to use as source =====================================
          selectRescUpdate (*Rlist, *Ulist, *Ir, *Resource);
          msiDataObjRepl("*Colln/*Name","updateRepl=++++rescName=*Resource",*Status2);
          if(*Status2 != 0) {
            writeLine("*Lfile","Unable to update replicas to most recent version for *Colln/*Name");
          } # end of error message if not able to update replicas to most recent version
#========= test whether the required number of replicas exists ==================
          if (*Numr != *NumReplicas) {
            *N = *NumReplicas - *Numr;
            createReplicas (*N, *Ir, *Lfile, *Ulist, *Rlist, *Jround, *Resource, *Colln, *Name, *NumRepCreated);  
          }  # end of check that the required number of replicas is not present
#======= slow rate at which are processing collection to meet deadline ====================
          *Runsize = *Runsize + double(*Sizedata);
          msiGetSystemTime(*timei, "unix");
          *timerun = int(*TimeS) + *Runsize / *Fac;
          *delt = *timerun - int(*timei);
          if (*delt > 4) {
            msiSleep(str(*delt), "0");
            writeLine("*Lfile","Sleeping for *delt");
          }  # end of check on length of sleep time
          *NumFiles = *NumFiles + 1;
          if (*iter % 256 == 0) {
            updateCollMeta (*Coll, "TEST_DATA_ID", *colldataID, *newdataID, *Lfile);       
          }  # end of test to update TEST_DATA_ID
        } # end of iteration check
      } # end of loop over files
      writeLine("*Lfile", "Number of logical file names tested is *NumFiles, total size checked is *Runsize bytes, and total time slept is *Sleeptime seconds");
      writeLine("*Lfile", "Number of bad files is *NumBadFiles, and number of replicated files created is *NumRepCreated");
#=======  reset TEST_DATA_ID status flag to zero ====================
      *Query6 = select META_COLL_ATTR_VALUE where COLL_NAME = '*Coll' and META_COLL_ATTR_NAME = 'TEST_DATA_ID';
      foreach(*Row6 in *Query6) {
        *colldataID = *Row6.META_COLL_ATTR_VALUE;
      }  # end of loop to get *colldataID
      updateCollMeta (*Coll, "TEST_DATA_ID", *colldataID, "0", *Lfile);
    }  # end of check on evaluation bandwidth
#====== Calculate actual elapsed time ============================
    msiGetSystemTime(*TimeE, "unix");
    *Del = int(*TimeE) - int(*TimeS);
    writeLine("*Lfile","Total elapsed time is *Del seconds");
  }  # end of delay command
}
INPUT *Coll=$"/testZone/home/rwmoore/test", *Delt=2, *NumReplicas = 2, *Res="demoResc"
OUTPUT ruleExecOut
