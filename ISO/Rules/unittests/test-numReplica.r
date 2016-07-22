testNumReplica = mainr
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_STORAGE = "LTLResc"
mainr {
# check how many replicas are created by a replication resource
  *Res = GLOBAL_STORAGE;
  racCheckNumReplicas (*Res, *Num);
  writeLine ("stdout", "Number of replicas for *Res is *Num");
}
racCheckNumReplicas (*Res, *Num) {
# Policy function to determine how many replicas will be made by a resource
  *File = "ractest234";
  *Coll = GLOBAL_ACCOUNT;
  *Path = "*Coll/*File";
  *Flags = "destRescName=*Res++++forceFlag=";
  *Num = "0";
  msiDataObjCreate (*Path, *Flags, *FD);
  msiDataObjWrite(*FD, "1", *Len);
  msiDataObjClose (*FD, *Stat);
  *Q1 = select count(DATA_REPL_NUM) where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) { *Num = *R1.DATA_REPL_NUM; }
  *Flagd = "objPath=*Path";
  msiDataObjUnlink (*Flagd, *Status);
}
INPUT null
OUTPUT ruleExecOut
