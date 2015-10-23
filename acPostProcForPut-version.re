acPostProcForPut {
# acPostProcForPut-version.r
# create a copy of the file by modifying the file name with a version stamp
# note that a collection must be specified where the version will be stored
  *Path = $objPath;
  msiSplitPath(*Path, *Coll, *File);
# construct version name
  msiGetSystemTime(*Tim, "human");
# check whether there is a file extension on the name
  *Head = *Pathname;
  *Type = "generic";
  *out = errormsg(msiSplitPathByKey (*Pathname, ".", *Head, *Type), *msg);
  *out2 = errormsg(msiSetDataType(*Objid, *Pathname, *Type, *Status), *msg1);
  *Vers = *Fstart ++ "." ++ "*Tim" ++ *Fend;
  *Pathver = "/Mauna/home/atmos/version/” ++ *Coll ++ "/" ++ *Vers;
  msiDataObjCopy(*Path,*Pathver, "forceFlag=",*Status);
  msiSetACL("default", "own", $userNameClient, *Pathver);
}
