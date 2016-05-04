setRetention {
# set an attribute on a file for when the retention period expires
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Relcoll";
  *Path = "*Coll/*File";
  msiGetSystemTime (*Tim, "unix");
  *Timr = str (double(*Tim) + *Days*24.*3600.);
  addAVUMetadata (*Path, "DATA_EXPIRATION", *Timr, "");
}
INPUT *Relcoll="Reports", *File="Report"
OUTPUT ruleExecOut
