acAuditRule {
# rac-auditRule.re
  *Path = $objPath;
  *Coll = GLOBAL_ACCOUNT ++ "/" GLOBAL_REPOSITORY;
  if (*Path like "*Coll/*") {
# audit actions for put, access control
  }
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_NAME = "Repository-Archives";
  foreach (*R1 in *Q1) {
    *Archive = *R1.META_COLL_ATTR_VALUE;
    *Colla = GLOBAL_ACCOUNT ++ "/*Archive";
    if (*Path like "*Colla/*") {
# audit actions for put, access control, accesses
      break;
    }
  }
}

