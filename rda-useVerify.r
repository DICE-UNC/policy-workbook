ruleCheckUse {
# rda-useVerify.r
# Checks whether the  metadata attribute Use_Agreement has been set for each user
  *Quser = select USER_NAME;
  foreach (*Row in *Quser) {
    *User = *Row.USER_NAME;
    *Quse = select count(META_USER_ATTR_NAME) where USER_NAME = '*User' and META_USER_ATTR_NAME = 'Use_Agreement';
    foreach (*R1 in *Quse) {
      *Count = *R1.META_USER_ATTR_NAME;
      if (*Count != "0") {
        *Qcheck = select META_USER_ATTR_VALUE where USER_NAME = '*User' and META_USER_ATTR_NAME = 'Use_Agreement';
        foreach (*R2 in *Qcheck) {
          *Val = *R2.META_USER_ATTR_VALUE;
          if (*Val != "RECEIVED") {
            writeLine("stdout", "No use agreement for *User");
          }
        }
      }
      else {
        writeLine("stdout", "No use agreement for *User");
      }
    }
  }
}
INPUT null
OUTPUT ruleExecOut
