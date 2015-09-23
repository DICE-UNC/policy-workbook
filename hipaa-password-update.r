passwordUpdate {
# hipaa-password-update.r
# All users have a password update flag set
  *Q1 = select USER_NAME;
  foreach (*R1 in *Q1) {
    *User = *R1.USER_NAME;
    if (*User != 'public' && *User != 'anonymous') {
      *Q2 = select META_USER_ATTR_VALUE where USER_NAME = '*User' and META_USER_ATTR_NAME = 'ResetPassword';
      foreach (*R2 *Q2) {
        *Val = *R2.META_USER_ATTR_VALUE;
        *Str = "ResetPassword=*Val";
        msiString2KeyValPair(*Str,*Kvp);
        msiRemoveKeyValuePairsFromObj(*Kvp,*User, "-u");
        *Val1 = "1";
        *Str1 = "ResetPassword=*Val1";
        msiString2KeyValPair(*Str1,*Kvp1);
        msiAssociateKeyValuePairsToObj(*Kvp1, *User, "-u");
      }
    }
  }
}
INPUT null
OUTPUT ruleExecOut
