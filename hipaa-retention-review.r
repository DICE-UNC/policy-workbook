retentionReview {
# hipaa-retention-review.r
# list all files that have exceeded their retention period
# this assumes DATA_EXPIRY is initialized with the unix time
  checkCollInput (*Coll);
  msiGetSystemTime(*Time, 'unix');
  msiGetSystemTime(*Timh,  'human');
  *Q1 = select DATA_NAME, COLL_NAME where COLL_NAME like '*Coll%' and DATA_EXPIRY <= '*Time';
  writeLine("stdout", "Review status of files with expiration date <= *Timh");
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Coll = *R1.COLL_NAME;
    writeLine("stdout", "Check *Coll/*File");
  }
}
INPUT *Coll = "/UNC-HIPAA/home/HIPAA/Archive"
OUTPUT ruleExecOut
