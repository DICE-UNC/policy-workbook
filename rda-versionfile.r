versionrule {
# rda-versionfile.r
# create a copy of the file by modifying the file name with a version stamp
# input
#  path name
# output
#  name of versioned file
  *Path = "/$rodsZoneClient/home/$userNameClient/*Fil";
  checkPathInput (*Path);
  msiSplitPath(*Path, *Coll, *File);
# construct version name
  msiStrlen(*File,*Lfile);
  msiGetSystemTime(*Tim, "human");
# check whether there is a file extension on the name  
  *Lsub = int(*Lfile);
  *Iloc = *Lsub -1;
  while (*Iloc >= 0) {
    msiSubstr(*File,"*Iloc","1",*Char);
    if (*Char == ".") {
      *Lsub = *Iloc;
      break;
    }
    else {
      *Iloc = *Iloc -1;
    }
  }
  msiSubstr(*File,"0","*Lsub",*Fstart);
  *Fend = "";
  if(*Iloc != 0) {
     *Iloc =int(*Lfile) - *Lsub; 
      msiSubstr(*File,"*Lsub","*Iloc",*Fend);
  }
  *Vers = *Fstart ++ "." ++ "*Tim" ++ *Fend;
  *Pathver = *Coll ++ "/" ++ *Vers;
  msiDataObjCopy(*Path,*Pathver, "forceFlag=",*Status);
  msiSetACL("default", "own", $userNameClient, *Pathver);
  writeLine("stdout","*Path written as version *Pathver");
}
INPUT *Fil=$"test-file"
OUTPUT ruleExecOut

