acSetPublicUserPolicy {
# reset NumberAttempts and LockoutPeriod
  *User = $userNameClient;
  *Q1 = select META_USER_ATTR_VALUE where USER_NAME = '*User' and META_USER_ATTR_NAME = 'NumberAttempts';
  foreach (*R1 in *Q1) {
    *Val = *R1.META_USER_ATTR_VALUE;
    *Str = "NumberAttempts=*Val";
    msiString2KeyValPair(*Str,*Kvp);
    msiRemoveKeyValuePairsFromObj(*Kvp,*User, "-u");
    *Val1 = "0";
    *Str1 = "NumberAttempts=*Val1";
    msiString2KeyValPair(*Str1,*Kvp1);
    msiAssociateKeyValuePairsToObj(*Kvp1, *User, "-u");
  }
  if (int(*Val1) > 5) {
# set lockout period
    *Q2 = select META_USER_ATTR_VALUE where USER_NAME = '*User' and META_USER_ATTR_NAME = 'LockoutPeriod';
    foreach (*R2 in *Q2) {
      *Val = *R2.META_USER_ATTR_VALUE;
      *Str = "LockoutPeriod=*Val";
      msiString2KeyValPair(*Str,*Kvp);
      msiRemoveKeyValuePairsFromObj(*Kvp,*User, "-u");
      *Str1 = "LockoutPeriod=0";
      msiString2KeyValPair(*Str1,*Kvp1);
      msiAssociateKeyValuePairsToObj(*Kvp1, *User, "-u");
    }
  }
  if (*User != 'public' && *User != 'anonymous') {
    *Q2 = select META_USER_ATTR_VALUE where USER_NAME = '*User' and META_USER_ATTR_NAME = 'ResetPassword';
    foreach (*R2 in *Q2) {
      *Val = *R2.META_USER_ATTR_VALUE;
      if (*Val == "1" ) { writeLine("stdout", "Reset your password");}
    }
  }
# check prior passwords
  *Q3 == select META_USER_ATTR_VALUE, META_USER_ATTR_UNITS where USER_NAME = '*User' and META_USER_ATTR_NAME = 'PasswordHist';
  foreach (*R3 in *Q3) {
    *Pass = *R3.META_USER_ATTR_VALUE;
    *Date = *R3.META_USER_ATTR_UNITS;
    if(*Date == '0') {
      *Passcurrent = *Pass;
  }
# do the comparison
  foreach (*R3 in *Q3) {
    *Pass = *R3.META_USER_ATTR_VALUE;
    *Date = *R3.META_USER_ATTR_UNITS;
    if (*Date != '0') {
      if (*Pass == *Passcurrent) {
        writeLine("stdout", "Reset your password");
        fail;
      }
    }
  }
}
