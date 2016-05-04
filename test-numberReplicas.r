numberReplicas {
# check the number of replicas
# test-numberReplicas
  writeLine("stdout","*Nrepl replications required");
  *Coll = "/$rodsZoneClient/home/$userNameClient";
  *Q1 = select DATA_NAME, COLL_NAME where COLL_NAME = '*Coll';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Col = *R1.COLL_NAME;
    *Q2 = select count(DATA_PATH) where DATA_NAME = '*File' and COLL_NAME like '*Col%';
    foreach (*R2 in *Q2) {
      *Num = *R2.DATA_PATH;
      if (int(*Num) < *Nrepl) {
        *Ndel = *Nrepl - int(*Num);
        writeLine("stdout", "Missing *Ndel replicas for *Col/*File");
      }
    }
  }
}
INPUT *Nrepl=2
OUTPUT ruleExecOut 
