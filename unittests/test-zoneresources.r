testZoneResources {
# find all of the storage systems associated with a zone
  *Zone = $rodsZoneClient;
  *Q1 = select RESC_NAME where RESC_ZONE_NAME = *Zone;
  foreach (*R1 in *Q1) {
    *Res = *R1.RESC_NAME;
    writeLine ("stdout", "Zone *Zone had resource *Res");
  }
}
INPUT null
OUTPUT ruleExecOut

