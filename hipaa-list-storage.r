listStorage {
# hipaa-list-storage.r
# List all storage systems in the data grid
  *Q1 = select RESC_NAME;
  foreach (*R1 in *Q1) {
    *Resc = *R1.RESC_NAME;
    writeLine("stdout", "Zone $rodsZoneClient has storage resource *Resc");
  }
}
INPUT null
OUTPUT ruleExecOut
