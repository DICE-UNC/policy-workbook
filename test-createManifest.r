createManifest (*Coll, *Manifest, *Res, *Lfile, *L_FD) {
# test-createManifest.r
# open and seek to end of manifest file
# *Coll is a collection holding the manifest file
# *Manifest is the name of the manifest file 
  isColl (*Coll, "serverLog", *Stat);
  isData (*Coll, *Manifest, *Status);
  *Lfile = "*Coll/*Manifest";
  if (*Status == "0") {
# create manifest file
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
  } else {
    msiDataObjOpen("objPath=*Lfile", *L_FD);
  }
  msiDataObjLseek (*L_FD, "0", "SEEK_END", *Status);
}
