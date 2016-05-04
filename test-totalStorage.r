testtotalStorage {
# find the total amount of storage including replicas
  *Q1 = select sum(DATA_SIZE) where COLL_NAME like '/$rodsZoneClient/home%';
  foreach (*R1 in *Q1) {
    *Total = double(*R1.DATA_SIZE)/1024./1024./1024.;
  }
  writeLine ("stdout", "Total size used by $rodsZoneClient is *Total GBytes");
}
INPUT null
OUTPUT ruleExecOut 
