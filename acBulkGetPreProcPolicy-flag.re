acBulkGetPreProcPolicy {
  msiSplitPath( $objPath, *Coll, *File);
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = '*Coll' and META_COLL_ATTR_NAME = 'BulkDownLoad';
  foreach (*R1 in *Q1) {*Val = *R1.META_COLL_ATTR_VALUE;}
  if (*Val == 'off') {msiSetBulkGetPostProcPolicy('off');}
}
