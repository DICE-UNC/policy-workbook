createXML {
# rule dmp-createXML.r
# for each file in a collection
# create an associated XML file
  *Xhead = ``<?xml version="1.0"?>``;
  *Xcat =``<catalog>``;
  *Xend =``</catalog>``;
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Relcoll";
  checkCollInput (*Coll);
  checkRescInput (*Res, $rodsZoneClient);
  *Q1 = select COLL_NAME, DATA_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Col = *R1.COLL_NAME;
    *Filn = *File ++ ".xml";
#============ create an XML file if it does not exist ===============
    *Lfile = "*Col/*Filn";
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
    writeLine("*Lfile","*Xhead");
    writeLine("*Lfile","*Xcat");
    writeLine("*Lfile","<File path=\"*Col/*File\">");
    *Q2 = select META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE where DATA_NAME = '*File' and COLL_NAME = '*Col';
    foreach (*R2 in *Q2) {
      *Aname = *R2.META_DATA_ATTR_NAME;
      *Aval = *R2.META_DATA_ATTR_VALUE;
      writeLine("*Lfile","<*Aname>*Aval</*Aname>");
    }
    writeLine("*Lfile","</File>");
    writeLine("*Lfile","*Xend");
    msiDataObjClose(*L_FD, *Status);
  }
}
INPUT *Relcoll =$"sub1", *Res =$"demoResc"
OUTPUT ruleExecOut
