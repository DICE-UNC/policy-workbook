testURLExtract {
# test-URLExtract.r
# assume html files have an extension ".html"
# assume the URLs are relative paths
# assume that there is an attribute SOURCE_PATH on each html file that defines the source URL
# use python script running at storage location to extract URLs from the file
# loop over files in the "stage" collection
# download files to the "retrieved" collection
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Relcoll";
  *DestC = "/$rodsZoneClient/home/$userNameClient/*Destcoll";
  *Cmd = "urlextract.py";
# find names of files ending in .html
  *Q1 = select DATA_NAME, DATA_PATH, DATA_ID, DATA_RESC_HIER where COLL_NAME = '*Coll' and DATA_NAME like '%.html';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *DataPath = *R1.DATA_PATH;
    *DataID = *R1.DATA_ID;
    *DataRescHier = *R1.DATA_RESC_HIER;
# find location of storage system
    msiSplitPathByKey (*DataRescHier, ";", *Rpath, *DataRescName);
    *Q2 = select RESC_LOC where RESC_NAME = *DataRescName;
    foreach (*R2 in *Q2) {*Reschost = *R2.RESC_LOC;}
# retrieve source path
    *Q3 = select META_DATA_ATTR_VALUE where DATA_ID = '*DataID' and META_DATA_ATTR_NAME = 'SOURCE_PATH';
    foreach (*R3 in *Q3) {*Source=*R3.META_DATA_ATTR_VALUE;}
# parse file at the storage location
    *Arg1 = execCmdArg(*DataPath);
    *Arg2 = execCmdArg(*Source);
    retrievefiles(*Reschost, *Arg1, *Arg2, *Cmd, *Out);
# create URL and retrieve file
    *Listurls = split(*Out, "\n");
    foreach (*Url in *Listurls) {
      *Nam = triml(*Url, "://")
      msiSplitPath("*DestC/*Nam", *Coll, *File);
      isColl(*Coll, "stdout", *status);
      *options.objPath = "*DestC/*Nam";
      msiCurlGetObj(*Url, *options, *Num);    
      writeLine ("stdout", "From *Url retrieved file *DestC/*Nam");
    }
  }
}
retrievefiles (*Reschost, *Arg1, *Arg2, *Cmd, *Out) {
  remote (*Reschost, "") {
    if (errorcode(msiExecCmd(*Cmd, "*Arg1 *Arg2", "null", "null", "null", *Result)) >= 0) {
      msiGetStdoutInExecCmdOut (*Result, *Out);
    }
    else {
      writeLine("stdout", "Error parsing html file");
      *Out = "";
    }
  }
}        

INPUT *Relcoll=$"stage", *Destcoll=$"retrieved"
OUTPUT ruleExecOut
