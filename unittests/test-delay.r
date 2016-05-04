testDelay {
# check whether delayed commands work
  *Coll = "/$rodsZoneClient/home/$userNameClient/*SourceColl";
  *CollBack = "/$rodsZoneClient/home/$userNameClient/Backup";
  *CollMan = "/$rodsZoneClient/home/$userNameClient/Reports";
# *Coll is a collection holding the manifest file
# *Manifest is the name of the manifest file
  isColl (*CollMan, "stdout", *Status);
  isColl (*CollBack, "stdout", *Status1);
  *Lfile = "*CollMan/*Manifest";
  isData (*CollMan, *Manifest, *Status);
  if (*Status == "0") {
# create manifest file
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *C_FD);
    msiDataObjClose (*C_FD, *Status);
    writeLine("stdout", "Created *Manifest file");
  }
  manifest (*Lfile, *Coll, *CollBack, *Res);
}
manifest(*Lfile, *Coll, *CollBack,  *Res) {
  delay ("<PLUSET>1s</PLUSET><EF>10s</EF>") {
    msiDataObjOpen("objPath=*Lfile++++openFlags=O_RDWR", *L_FD);
    msiDataObjLseek (*L_FD, "0", "SEEK_END", *Status);
    msiGetSystemTime (*Tim, "human");
    writeLine ("*Lfile", "Backup executed at *Tim");
  }
}
INPUT *SourceColl =$"uploads", *Res =$"LTLResc", *Manifest = "Manifest"
OUTPUT ruleExecOut
