acBundleOrReplicate(*collPath, *cacheRes, *backRes, *archive, *threshold) {
  msiCheckCollSize(*collPath, *cacheRes, *threshold, *aboveThreshold, *status);
  if(*aboveThreshold == "1") {
    msiWriteRodsLog("Creating bundle", *status);
    msiPhyBundleColl(*collPath,*archive, *status);
    msiWriteRodsLog("Finished bundling", *status);
  } 
  msiWriteRodsLog("Starting to backup files",*status);
  acGetIcatResults("list", "COLLNAME LIKE '*collPath'", *List);
  forEach (*R in *List) {
    *Data = *R.DATA_NAME;
    *Coll = *R.COLL_NAME;
    *dataRes = *R.DATA_RESC_NAME;
    if(*dataRes == *cacheRes) {
      msiWriteRodsLog("Replicating file *Coll/*Data", *status); 
      msiDataObjRepl(*Coll/*Data, "verifyChksum++++backupRescName = *backRes", *status);
      msiWriteRodsLog("Completedreplicating file *Coll/*Data", *status);
    }
  }
}
