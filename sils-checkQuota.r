main {
# sils-checkQuota.r
# Calculate storage quota for all users
# Identify persons over their quota
# List top *Num users
  *rs = select USER_ID, USER_NAME, USER_ZONE;
  *Total = 0.;
  *Max = 0.;
  *Numusers = 0;
  *Min = 0.;
  createList(*Listuse, *Num, "0.");
  createList(*Listnam, *Num, "");
  writeLine("stdout","Name\t\tQuota\t\tUsage");
  foreach(*Row in *rs){
    *Uid = *Row.USER_ID;
    *Name = *Row.USER_NAME;
    *Zone = *Row.USER_ZONE;
    *Numusers = *Numusers + 1;
# get quota
    *Q = select QUOTA_OVER where QUOTA_USER_ID = *Uid;
    foreach(*R in *Q) {
      *Over = -double(*R.QUOTA_OVER)/1024./1024./1024.;
    }
# get usage
    *Q2 = select sum(QUOTA_USAGE) where QUOTA_USAGE_USER_ID = *Uid;
    foreach(*R2 in *Q2) {
      *Usage = double(*R2.QUOTA_USAGE)/1024./1024./1024.;
      *Total = *Total + *Usage;
# find top *Num users
      if(*Usage > *Min) {
        addToList(*Name, *Usage, *Listnam, *Listuse, *Min, *Num);
      }
    }
    *Quota = (*Over + *Usage);
    *Usname = "*Name\t";
    if (strlen(*Name) < 8) {*Usname = "*Usname\t"}
    writeLine("stdout","*Usname*Quota\t\t*Usage");
    if(*Over < 0.0) {
      writeLine("stdout", "Quota *Quota exceeded by *Name, Usage is *Usage");
    }
  }
  writeLine("stdout","Number of users is *Numusers");
  writeLine("stdout","Total usage is *Total Gbytes");
  writeLine("stdout","Top 10 users are");
  for (*I=0; *I<*Num; *I=*I+1) {
    *Us = elem(*Listnam,*I);
    *Usv = elem(*Listuse,*I);
    if (strlen(*Us) < 8) {*Us = "*Us\t";}
    writeLine("stdout","*Us\t*Usv");
  }
}
createList(*Lista, *Num, *Val) {
# create a list with default values *Val
  *Lista = list(*Val);
  for (*I=1;*I<*Num;*I=*I+1) {
    *Lista = cons(*Val, *Lista);
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
  *Min = double(elem(*Listuse,*Num -1));
}
input *Num = 20
output ruleExecOut
