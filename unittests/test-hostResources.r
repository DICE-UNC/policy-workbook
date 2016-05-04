testZoneResources {
# find all of the storage systems associated with a host
  *Host = "diamond.ils.unc.edu";
  *Q1 = select RESC_NAME where RESC_LOC = *Host;
  foreach (*R1 in *Q1) {
    *Res = *R1.RESC_NAME;
    writeLine ("stdout", "Host *Host has resource *Res");
  }
}
INPUT null
OUTPUT ruleExecOut

