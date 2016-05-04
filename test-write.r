createXML {
# rule dmp-createBulkXML.r
# for each file in a collection
# create an associated XML file using the bulk load schema
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Relcoll";
#  checkCollInput (*Coll);
#  checkRescInput (*Res, $rodsZoneClient);
  *Xs = ``<?xml version="1.0"?>``;
  *Q1 = select COLL_NAME, DATA_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Col = *R1.COLL_NAME;
    *Path = "*Col/*File";
    *Filn = *File ++ ".txt";
#============ create an XML file if it does not exist ===============
    *Lfile = "*Col/*Filn";
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
    writeString("*Lfile", "*Xs\n");
    writeString("*Lfile", "<metadata>\n");
  }
    msiDataObjClose(*L_FD, *Status);
    writeLine("stdout","Created XML file for *Path");
}
INPUT *Relcoll =$"sub1", *Res =$"lifelibResc1"
OUTPUT ruleExecOut
