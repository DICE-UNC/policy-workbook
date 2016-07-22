dataPut {
# check options on msiDataObjPut
#  *Opt = "localPath=*File++++forceFlag=";
  *Opt = "localPath=*File";
  *Path = "/$rodsZoneClient/home/rwmoore/*File";
  writeLine ("stdout", "Put *File into *Path using option *Opt");
  msiDataObjPut (*Path, "dfc-defaultResc", *Opt, *Stat);
}
INPUT *File=$"test"
OUTPUT ruleExecOut
