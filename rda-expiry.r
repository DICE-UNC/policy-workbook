integrityExpiry {
# rda-expiry.r
#Input parameter is:
#  Name of collection that will be checked
#  Flag for "EXPIRED" or for "NOT EXPIRED"
#Output is:
#  List of all files in the collection that have either EXPIRED or NOT EXPIRED
#Verify that input path is a collection
  checkCollInput (*Coll);
  *Count = 0;
  *Counte = 0;
  msiGetIcatTime(*Time, "unix");

  #Loop over files in the collection
  *Q1 = select DATA_ID,DATA_NAME,DATA_EXPIRY where COLL_NAME = '*Coll';
  foreach(*R1 in *Q1) {
    *Attrname = *R1.DATA_EXPIRY;
    if(*Attrname > *Time  && *Flag == "NOT EXPIRED") {
      *File = *R1.DATA_NAME;
      writeLine("stdout", "File *File has not expired");
      *Count = *Count + 1;
    }
    if(*Attrname <= *Time && *Flag == "EXPIRED") {
      *File = *R1.DATA_NAME;
      writeLine("stdout", "File *File has expired");
      *Counte = *Counte + 1;
    }
  }
  if(*Flag == "EXPIRED") {writeLine("stdout", "Number of files in *Coll that have expired is *Counte");}
  if(*Flag == "NOT EXPIRED") {writeLine("stdout", "Number of files in *Coll that have not expired is *Count");}
}
INPUT *Coll = "/$rodsZoneClient/home/$userNameClient/sub1", *Flag = "EXPIRED"
OUTPUT ruleExecOut
