setArchives = main35
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_REPOSITORY = "Repository"
main35 {
# Policy35
# rac-setArchives.r
# Add an archives name as an attribute on GLOBAL_REPOSITORY
  *Colh = GLOBAL_ACCOUNT;
  *Coll = "*Colh/" ++ GLOBAL_REPOSITORY;
  writeLine ("stdout", "*Colh, *Coll");
# verify that name is not already present for the archive
  *Q1 = select count(META_COLL_ATTR_ID) where COLL_NAME = *Coll and META_COLL_ATTR_NAME = *Archive;
  foreach (*R1 in *Q1 ) {
    *Num = *R1.META_COLL_ATTR_ID;
    writeLine ("stdout", "*Num");
    if (*Num == "0" ) {
      msiAddKeyVal (*Kvp, "Repository-Archives", "*Archive");
      msiAssociateKeyValuePairsToObj (*Kvp, *Coll, "-C");
      writeLine ("stdout", "Added name for new archives, *Archive, to the collection *Coll");
    } else {
      writeLine ("stdout", "The archive *Archive is already registered");
    }
  }
# Create an archives collection if missing
  *C = "*Coll/*Archive";
  isColl (*C, "stdout", *Status);
  if (*Status >= 0) { writeLine("stdout", "Created archives collection, *C"); }
}
INPUT *Archive=$"Archive-B"
OUTPUT ruleExecOut
