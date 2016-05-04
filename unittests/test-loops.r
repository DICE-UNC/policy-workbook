testLoop {
  *Sum = 0;
  for (*I=1; *I<11; *I=*I+1) {
    if(*I == 5) {writeLine("stdout", "Fifth iteration *I");}
    *Sum = *Sum + *I;
  }
  writeLine("stdout", "Sum from 1 to 10 is *Sum");
  *Sum = 0;
  *I = 0;
  while (*I < 11) {
    *Sum = *Sum + *I;
    *I = *I + 1;
  }
  writeLine ("stdout","Sum from 1 to 10 is *Sum");
}
INPUT null
OUTPUT ruleExecOut
