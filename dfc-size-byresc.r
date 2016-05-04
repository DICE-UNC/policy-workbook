sizeByResc {
# dfc-size-byresc.r
# Calculate usage by storage resource

  *Total = 0.;
  *Name = $userNameClient;
  writeLine ("stdout", "Resource                Data-stored (Gbytes)");
  writeLine ("stdout", "--------------------------------------------");

  *Q1 = select RESC_NAME, RESC_PARENT;
  foreach (*R1 in *Q1) {
   *Resc = *R1.RESC_NAME;
   *Parent = *R1.RESC_PARENT;

    # only query the top-level resouces, since they are the only ones that return size data
    if (strlen(*Parent) <= 0) {
      *Q2 = select sum(DATA_SIZE) where DATA_RESC_NAME = '*Resc';

      foreach(*R2 in *Q2) {
        *Usage = double(*R2.DATA_SIZE)/1024./1024./1024.;
        writeParam(*Resc, str(*Usage));
        *Total = *Total + *Usage;
      }

    }
  }
  writeLine("stdout", "");
  writeParam("Total", str(*Total));
}

writeParam(*R0, *R1) {
# convert input strings into 16 character fields
  *C0 = *R0;
  if (strlen(*C0) < 8) {*C0 = "*C0\t";}
  if (strlen(*C0) < 16) {*C0 = "*C0\t";}
  *C0 = "*C0\t";
  *C1 = *R1;
  if (strlen(*C1) < 8) {*C1 = "*C1\t";}
  if (strlen(*C1) < 16) {*C1 = "*C1\t";}
  writeLine("stdout", "*C0*C1");
}
input null 
output ruleExecOut
