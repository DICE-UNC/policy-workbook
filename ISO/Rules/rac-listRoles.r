listRoles {
# rac-listRoles.r
# Policy10
# count the number of persons in each repository role and list their names
  *Roles = list("Archive-manager", "Archive-archivist", "Archive-admin", "Archive-IT");
  *Att = "Repository-Role";
  foreach (*R in *Roles) {
    *Q1 = select count(USER_ID) where META_USER_ATTR_NAME = *Att and META_USER_ATTR_VALUE = *R;
    foreach (*R1 in *Q1) {
      *Num = *R1.USER_ID;
      writeLine("stdout", "For role *R there are *Num staff members");
      *Q2 = select USER_NAME, USER_TYPE where META_USER_ATTR_NAME = *Att and META_USER_ATTR_VALUE = *R;
      foreach (*R2 in *Q2) {
        *Name = *R2.USER_NAME;
        *Access = *R2.USER_TYPE;
        writeLine("stdout","    *Name    *Access");
      }
    }
  }
}
INPUT null
OUTPUT ruleExecOut
