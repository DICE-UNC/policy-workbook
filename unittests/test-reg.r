testReg {
# check how to replicate a registered file
  *Collhome = "/$rodsZoneClient/home/$userNameClient/";
  *Coll = *Collhome ++ *Collrel;
  checkCollInput (*Coll);
  *Path = "*Coll/*File";
  checkPathInput (*Path);
  *Q1 = select DATA_PATH, DATA_ID, DATA_RESC_HIER where COLL_NAME = '*Coll' and DATA_NAME = '*File';
  *Nrep = 0;
  foreach (*R1 in *Q1) {
    if (*Nrep == 0) {
      *Nrep = 1;
      *DataPath = *R1.DATA_PATH;
      *DataID = *R1.DATA_ID;
      *DataRescHier = *R1.DATA_RESC_HIER;
      writeLine("stdout", "Registering file at *DataPath");
      msiSplitPathByKey (*DataRescHier, ";", *Rpath, *DataRescName);
      *Q2 = select RESC_LOC where RESC_NAME = *DataRescName;
      foreach (*R2 in *Q2) {*Reschost = *R2.RESC_LOC;}
      *DataName = *Path ++ ".test";
      writeLine ("stdout", "Source *Path, Storage path *DataPath, Destination *DataName");
      msiPhyPathReg(*DataName, *DataRescName, *DataPath, "", *Status);
      writeLine ("stdout", "replication to LTLRenci");
      msiDataObjRepl (*DataName, "destRescName=LTLRenci", *Status);
    }
  }
}
INPUT *Collrel="test", *File="file1"
OUTPUT ruleExecOut

