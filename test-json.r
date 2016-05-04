jsonFileMeta {
# dmp-json.r
# Create a json file of all descriptive metadata for a file
# Write files into a separate metadata collection
#============ create a collection for reports if it does not exist ===============
  checkCollInput (*Coll);
  checkRescInput (*Res, $rodsZoneClient);
  *LPath = "*Coll/Metadata";
  isColl(*LPath, "stdout", *Status);
  if (*Status >= 0) {
    *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
    foreach (*R1 in *Q1) {
      *File = *R1.DATA_NAME;
#============ create file into which results will be written =========================
      *Lfile = "*LPath" ++ "/" ++ "*File" ++ ".json";
      *Dfile = "destRescName=*Res++++forceFlag=";
      msiDataObjCreate(*Lfile, *Dfile, *L_FD);    
      writeLine("*Lfile","\{");
      writeLine("*Lfile"," \"DATA_NAME\"\: \"*File\"\,");
      writeLine("*Lfile"," \"Metadata\"\: \[");
      *Q3 = select count(META_DATA_ATTR_NAME) where DATA_NAME = '*File' and COLL_NAME = '*Coll';
      foreach (*R3 in *Q3) {*Num = int(*R3.META_DATA_ATTR_NAME);}
      *Count = 0;
      *Q2 = select META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE, META_DATA_ATTR_UNITS where DATA_NAME = '*File' and COLL_NAME = '*Coll';
      foreach (*R2 in *Q2) {
        *Name = *R2.META_DATA_ATTR_NAME;
        *Value = *R2.META_DATA_ATTR_VALUE;
        *Units = *R2.META_DATA_ATTR_UNITS;
        *Count = *Count + 1;
        writeLine("*Lfile","  \{");
        writeLine("*Lfile","   \"META_DATA_ATTR_NAME\"\: \"*Name\"\,");
        writeLine("*Lfile","   \"META_DATA_ATTR_VALUE\"\: \"*Value\"\,");
        writeLine("*Lfile","   \"META_DATA_ATTR_UNITS\"\: \"*Units\"");
        if (*Count == *Num) {writeLine("*Lfile","  \}")}
        else {writeLine("*Lfile","  \}\,");}
      }
      writeLine("*Lfile"," \]");
      writeLine("*Lfile","\}");
      msiDataObjClose(*L_FD, *Status);
    }
  }
}
checkCollInput(*Coll) {
# check whether *Coll is a collection
# fail if not a collection
  *Q = select count(COLL_ID) where COLL_NAME = '*Coll';
  foreach (*R in *Q) {*Result = *R.COLL_ID;}
  if(*Result == "0" ) {
    writeLine("stdout","Input path *Coll is not a collection");
    fail;
  }
}
checkRescInput (*Res, *Zone) {
# local zone is defined by your irods_environment file
  if (*Zone != $rodsZoneClient) {
# execute query in the remote zone
    findZoneHostName(*Zone, *Host, *Port);
    remote (*Host,"<ZONE>*Zone</ZONE>") {
      *Q1 = select count(RESC_ID) where RESC_NAME = '*Res';
      foreach (*R1 in *Q1) {*n = *R1.RESC_ID;}
      if (*n == "0") {
        writeLine("stdout","Remote resource *Res is not defined in zone *Zone");
#       fail;
      }
      writeLine("stdout", "Resource *Res exists in remote zone *Zone");
    }
  }
  else {
# query local zone
    *Q1 = select count(RESC_ID) where RESC_NAME = '*Res';
    foreach (*R1 in *Q1) {*n = *R1.RESC_ID;}
    if (*n == "0") {
      writeLine ("stdout", "Local resource *Res is not defined");
      fail;
    }
    writeLine ("stdout", "Resource *Res exists in local zone $rodsZoneClient");
  }
}
findZoneHostName (*Zone, *Host, *Port) {
  *Q1 = select ZONE_CONNECTION where ZONE_NAME = '*Zone';
  foreach (*R1 in *Q1) {
    *Conn = *R1.ZONE_CONNECTION;
    msiSplitPathByKey (*Conn, ":", *Host, *Port);
  }
}
isColl (*LPath, *Lfile, *Status) {
  *Status = 0;
  *Query0 = select count(COLL_ID) where COLL_NAME = '*LPath';
  foreach(*Row0 in *Query0) {*Result = *Row0.COLL_ID;}
  if(*Result == "0" ) {
    msiCollCreate(*LPath, "1", *Status);
    if(*Status < 0) {
      writeLine("*Lfile","Could not create *LPath collection");
    }  # end of check on status
  }  # end of log collection creation
}

INPUT *Coll = "/$rodsZoneClient/home/$userNameClient/test", *Res = 'lifelibResc1'
OUTPUT ruleExecOut
