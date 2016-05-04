listGroup {
# test-listGroup.r
# List the persons in a group
  writeLine ("stdout", "Members of group *GroupName");
  *Q = select count(USER_ID) where USER_NAME = '*GroupName';
  foreach (*R in *Q) { *Num = *R.USER_ID; }
  if (int(*Num) > 0) {
    *Q0 = select USER_ID where USER_NAME = '*GroupName';
    foreach (*R0 in *Q0) {*UserID = *R0.USER_ID;}
    *Q1 = select count(USER_NAME) where USER_GROUP_ID = '*UserID';
    foreach (*R1 in *Q1) {
      *Nsg = *R1.USER_NAME;
      if(int(*Nsg) > 1) {
        *Q2 = select USER_NAME where USER_GROUP_ID = '*UserID';
        foreach (*R2 in *Q2) {
          *Usg = *R2.USER_NAME;
          if (*Usg != *GroupName) {
            writeLine("stdout", "        *Usg");
          }
        }
      }
    }
  }
  else { writeLine ("stdout", "No members found"); }
}
INPUT *GroupName =$'Class624'
OUTPUT ruleExecOut

