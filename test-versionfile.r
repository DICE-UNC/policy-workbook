versionfile {
# test-versionfile.r
# create a copy of files in source collection by modifying the file name with a version stamp
# input
#  path name
  *Coll = "/$rodsZoneClient/home/$userNameClient/*SourceColl";
  *DesColl = "/$rodsZoneClient/home/$userNameClient/*DestColl";
  *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
# construct version name
  msiGetSystemTime(*Tim, "human");
  foreach(*R1 in *Q1) {
    *File = *R1.DATA_NAME;
# check whether there is a file extension on the name
    *Path = "*Coll/*File";
    *Head = *File;
    *End = "";
    *out = errormsg(msiSplitPathByKey (*File, ".", *Head, *End), *Msg);
    if (*End == "") { *Vers = *Head ++ "." ++ "*Tim"; }
    else {  *Vers = *Head ++ "." ++ "*Tim." ++ *End; }
    *Pathver = *DesColl ++ "/" ++ *Vers;
    msiDataObjCopy(*Path,*Pathver, "forceFlag=",*Status);
    writeLine("stdout","*Path written as version *Pathver");
  }
}
INPUT *SourceColl =$"uploads", *DestColl =$"archive"
OUTPUT ruleExecOut
