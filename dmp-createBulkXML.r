createXML {
# rule dmp-createBulkXML.r
# for each file in a collection
# create an associated XML file using the bulk load schema
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Relcoll";
  checkCollInput (*Coll);
  checkRescInput (*Res, $rodsZoneClient);
  *Xs = ``<?xml version="1.0"?>``;
  *Q1 = select COLL_NAME, DATA_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Col = *R1.COLL_NAME;
    *Path = "*Col/*File";
    *Filn = *File ++ ".xml";
#============ create an XML file if it does not exist ===============
    *Lfile = "*Col/*Filn";
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
    writeLine("*Lfile", "*Xs");
    writeLine("*Lfile", "<metadata>");
    *Q2 = select META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE, META_DATA_ATTR_UNITS where DATA_NAME = '*File' and COLL_NAME = '*Col';
    foreach (*R2 in *Q2) {
      writeLine("*Lfile", "<AVU>");
      writeLine("*Lfile","<Target>*Path</Target>");
      *Aname = *R2.META_DATA_ATTR_NAME;
      *Aval = *R2.META_DATA_ATTR_VALUE;
      *Aunit = *R2.META_DATA_ATTR_UNITS;
      writeLine("*Lfile", "<Attribute>*Aname</Attribute>");
      writeLine("*Lfile", "<Value>*Aval</Value>");
      writeLine("*Lfile", "<Unit>*Aunit</Unit>");
      writeLine("*Lfile", "</AVU>");
    }
    writeLine("*Lfile","</metadata>");
    msiDataObjClose(*L_FD, *Status);
    writeLine("stdout", "Created XML file for *Col/*File");
  }
  writeLine("stdout", "Finished processing files in *Col");
}
INPUT *Relcoll =$"sub1", *Res =$"LTLResc"
OUTPUT ruleExecOut
