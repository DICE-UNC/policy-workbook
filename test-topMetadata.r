topMetadata {
# test-topMetadata.r
# Calculate top 10 users with the most Metadata
  *Max = 0.;
  *Min = 0.;
  createList(*Listuse, *Num, "0.");
  createList(*Listnam, *Num, "");
  writeLine("stdout","Name\t\tNumber of Metadata");
  *Q1 = select USER_NAME;
  foreach (*R1 in *Q1) {
    *Name = *R1.USER_NAME;
    *Q2 = select count(META_DATA_ATTR_ID) where DATA_OWNER_NAME = '*Name';
    foreach(*R2 in *Q2) {
      *Usage = double(*R2.META_DATA_ATTR_ID);
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
addToList(*Name, *Usage, *Listnam, *Listuse, *Min, *Num) {
# insert new usage in list keeping top 10
  *S = 0;
  for (*I=0;*I<*Num;*I=*I+1) {
    *Val = elem(*Listuse,*I);
    *Use = double(*Val);
    if (*Use < *Usage) {
      for (*J=*Num-1;*J>*I;*J=*J-1) {
        *Jm1 = *J-1;
        *Use1 = elem(*Listuse,*Jm1);
        *Nam1 = elem(*Listnam,*Jm1);
        *Listuse = setelem(*Listuse,*J,*Use1);
        *Listnam = setelem(*Listnam,*J,*Nam1);
      }
      *Listuse = setelem(*Listuse,*I,str(*Usage));
      *Listnam = setelem(*Listnam,*I,*Name);
      *S = 1;
    }
    if (*S == 1) {break;}
  }
  *Min = double(elem(*Listuse,*Num-1));
}
createList(*Lista, *Num, *Val) {
# create a list with default values *Val
  *Lista = list(*Val);
  for (*I=1;*I<*Num;*I=*I+1) {
    *Lista = cons(*Val, *Lista);
  }
}
INPUT *Num = 10
output ruleExecOut
