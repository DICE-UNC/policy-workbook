createAccounts {
# hipaa-create-accounts.r
# Creates a time-stamped pipe-delimited file for the accounts in a data grid
  checkRescInput (*Res, $rodsZoneClient);
  *Coll = "/$rodsZoneClient/home/$userNameClient");
  createLogFile (*Coll, "Accounts", *Accounts, *Res, *LPath, *Lfile, *L_FD);
  *Q1 = select USER_NAME, USER_TYPE;
  *Zone = $rodsZoneClient;
  foreach (*R1 in *Q1) {
    *User = *R1.USER_NAME;
    *Type = *R1.USER_TYPE;
    writeLine("*Lfile", "*User|001|*Type|*Zone|");
  }
  msiDataObjClose(*L_FD,*Status);
}
INPUT *Res = "uncResc", *Accounts = "Account"
OUTPUT ruleExecOut
