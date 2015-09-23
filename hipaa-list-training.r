listTraining {
# hipaa-list-training.r
# List the name, position, and training for each account
  *Q1 = select USER_NAME, USER_TYPE, USER_INFO 
  foreach(*R1 in *Q1) {
    *Name = *R1.USER_NAME;
    *Type = *R1.USER_TYPE;
    *Info = *R1.USER_INFO;
    writeLine("stdout","*Name has role *Type");
    writeLine("stdout","    *Info");
  }
}
INPUT null
OUTPUT ruleExecOut
