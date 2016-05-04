CollectionSize {
# dfc-dataobject-size.r
# For each publicly accessible collection
# list the number of files and size

# Collect all user home collections and go through each one to get data totals
  *Totsize = 0.0;
  *Q0 = select count(DATA_ID), sum(DATA_SIZE), COLL_NAME where COLL_NAME like '*Coll%';

  foreach (*R0 in *Q0) {
    *Colln = *R0.COLL_NAME;
    *Num = *R0.DATA_ID;
    *Size = *R0.DATA_SIZE;
    *Totsize = *Totsize + double (*Size);
    writeLine("stdout", "Collection *Colln has *Num files with size *Size bytes");
  }

  writeLine("stdout", "Total collection size is *Totsize bytes");
}
#INPUT *Coll = '/$rodsZoneClient/home/'
INPUT *Coll = '/'
OUTPUT ruleExecOut
