acCheckPasswordStrength(*password) {
# Require at least 8 characters
  *Len = strlen(*password);
  if(*Len <8) {
    writeLine("stdout", "Password requires at least 8 characters");
    fail;
  }
# Require at least one number
  for (*I=1,*I<10,*I=*I+1) {
    msiSplitPathByKey(*password, "*I", *H, *E);
    if (*E != "") {
      succeed;
    }
  }
  writeLine("stdout","Password requires at least 1 number");
  fail;
}
