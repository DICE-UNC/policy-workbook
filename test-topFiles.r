topFiles {
# test-topFiles.r
# Calculate top 10 users with the most files
  *Max = 0.;
  *Min = 0.;
  createList(*Listuse, *Num, "0.");
  createList(*Listnam, *Num, "");
  writeLine("stdout","Name\t\tNumber of Files");
  *Q1 = select USER_NAME;
  foreach (*R1 in *Q1) {
    *Name = *R1.USER_NAME;
    *Q2 = select count(DATA_ID) where DATA_OWNER_NAME = '*Name';
    foreach(*R2 in *Q2) {
      *Usage = double(*R2.DATA_ID);
# find top *Num users
      if(*Usage > *Min) {
        addToList(*Name, *Usage, *Listnam, *Listuse, *Min, *Num);
      }
    }
  }
  for (*I=0; *I<*Num; *I=*I+1) {
    *Us = elem(*Listnam,*I);
    *Usv = elem(*Listuse,*I);
    if (strlen(*Us) < 8) {*Us = "*Us\t";}
    if (strlen(*Us) < 16) {*Us = "*Us\t";}
    writeLine("stdout","*Us*Usv");
  }
}
INPUT *Num = 10
output ruleExecOut
