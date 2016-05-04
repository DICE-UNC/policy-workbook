listUsage {
# test-listUsage.r
# Calculate usage by storage resource
  *Total = 0.;
  *Name = $userNameClient;
  writeLine ("stdout", "Resource        User            Data-stored (Gbytes)");
  *Q1 = select RESC_NAME;
  foreach (*R1 in *Q1) {
    *Resc = *R1.RESC_NAME;
    *Q2 = select sum(DATA_SIZE) where DATA_RESC_NAME = '*Resc' and DATA_OWNER_NAME = '*Name';
    foreach(*R2 in *Q2) {
      *Usage = double(*R2.DATA_SIZE)/1024./1024./1024.;
      writeParam(*Resc, *Name, str(*Usage));
      *Total = *Total + *Usage;
    }
  }
  writeParam("Total", *Name, str(*Total));
  msiGetSystemTime (*Time, "human");
  writeLine ("stdout", "Information was set at *Time");
}
writeParam(*R0, *R1, *R2) {
# convert input strings into 16 character fields
  *C0 = *R0;
  if (strlen(*C0) < 8) {*C0 = "*C0\t";}
  if (strlen(*C0) < 16) {*C0 = "*C0\t";}
  *C1 = *R1;
  if (strlen(*C1) < 8) {*C1 = "*C1\t";}
  if (strlen(*C1) < 16) {*C1 = "*C1\t";}
  *C2 = *R2;
  if (strlen(*C2) < 8) {*C2 = "*C2\t";}
  if (strlen(*C2) < 16) {*C2 = "*C2\t";}
  writeLine("stdout", "*C0*C1*C2");
}
input null 
output ruleExecOut
