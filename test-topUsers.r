topUsers {
# test-topUsers.r
# Calculate number of users
  *Q1 = select count(USER_NAME);
  foreach (*R1 in *Q1) {
    *Num = *R1.USER_NAME;
  }
  writeLine ("stdout", "The number of users is *Num");
}
INPUT null
output ruleExecOut
