acChkUserLogon {
# Increment a counter for each logon attempt
  *User = $userNameClient;
  *Q1 = select META_USER_ATTR_VALUE where USER_NAME = '*User' and META_USER_ATTR_NAME = 'NumberAttempts';
  foreach (*R1 in *Q1) {
    *Val = *R1.META_USER_ATTR_VALUE;
    *Str = "NumberAttempts=*Val";
    msiString2KeyValPair(*Str,*Kvp);
    msiRemoveKeyValuePairsFromObj(*Kvp,*User, "-u");
    *Val1 = str(int(*Val) + 1);
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
      msiGetSystemTime(*Tim, "unix");
      *Str1 = "LockoutPeriod=*Tim";       
      msiString2KeyValPair(*Str1,*Kvp1);
      msiAssociateKeyValuePairsToObj(*Kvp1, *User, "-u");
    }
  }
}
