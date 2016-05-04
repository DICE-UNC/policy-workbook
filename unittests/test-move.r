testMove {
# check whether metadata remains on file during move
  *Coll = "/lifelibZone/home/rwmoore/test/file2";
  *Dest = "/lifelibZone/home/rwmoore/sub1/file2";
  msiDataObjRename (*Coll, *Dest, "0", *Status);
}
INPUT null
OUTPUT ruleExecOut
