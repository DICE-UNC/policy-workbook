acTicketPolicy {
# For collections that have the ACCESS_APPROVAL flag set to 0, tickets are disabled
  msiSplitPath($objPath, *Coll, *File);
  *Q = select META_COLL_ATTR_VALUE where COLL_NAME = '*Coll' and META_COLL_ATTR_NAME = 'ACCESS_APPROVAL';
  *Access == "0";
  foreach (*R in *Q) {
    *Access = *R.META_COLL_ATTR_VALUE;
  }
  if (*Access == "0") { 
    writeLine ("serverlog", "Restrict ticket access for collection *Coll and file *File");
    fail;
  }
}
