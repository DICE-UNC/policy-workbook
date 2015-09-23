jsonFileMeta {
# dmp-json.r
# Create a json file of all descriptive metadata for a file
# Write files into a separate metadata collection
#============ create a collection for reports if it does not exist ===============
  checkCollInput (*Coll);
  checkRescInput (*Res, $rodsZoneClient);
  *LPath = "*Coll/Metadata";
  isColl(*LPath, "stdout", *Status);
  if (*Status >= "0") {
    *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
    foreach (*R1 in *Q1) {
      *File = *R1.DATA_NAME;
#============ create file into which results will be written =========================
      *Lfile = "*LPath" ++ "/" ++ "*File" ++ "-metadata";
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
INPUT *Coll = "/$rodsZoneClient/home/$userNameClient/Reports", *Res = 'demoResc'
OUTPUT ruleExecOut
