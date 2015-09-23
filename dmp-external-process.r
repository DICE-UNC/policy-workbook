externalProcess {
# dmp-external-process.r
# Command to be executed is located in directory irods/server/bin/cmd
# This rule invokes an application that runs at the remote storage location
  checkPathInput (*outXmlFile);
  checkPathInput (*Pathf);
  *timeStamp = double (time());
# Query the metadata catalog to get the Data ID for the input path, *Pathf
  msiSplitPath(*Pathf, *Coll, *File);
# Now Make a query to get the absolute path to the file and the resource name
  *Q = select DATA_PATH, DATA_RESC_NAME where DATA_NAME = '*File' and COLL_NAME = '*Coll';
  foreach (*row in *Q) {
    *Path = *row.DATA_PATH;
    *Resource = *row.DATA_RESC_NAME;
  }
# Make another query for IP Address of the resource
  *Query2 = select RESC_LOC where DATA_RESC_NAME = '*Resource';
  foreach (*row in *Query2) {*Addr = *row.RESC_LOC;}
# set up arguements for the command execution
  *Arg1 = execCmdArg("-f");
  *Arg2 = execCmdArg("-X");
  if (errorcode(msiExecCmd(*Cmd,"*Arg1 *Arg2”, “null”, “*Pathf”, “null",*Result)) < 0) {
    if(errormsg(*Result,*msg)==0) {
      msiGetStderrInExecCmdOut(*Result,*Out);
      writeLine("stdout", "ERROR: *Out");
    } else {
      writeLine("stdout", "Result msg is empty");
    }
  } else {
# Command executed successfully
    msiGetStdoutInExecCmdOut(*Result,*Out);
    writeLine("stdout", "Output is *Out ");
# Clean up the temporary files
    cleanup(*Addr, *tempStr, *outXmlFile, *status);
  }
}
# Function: cleanup: Calls a script to remove the temporary files created
# in /tmp
cleanup: input string * input string * input string * output integer -> integer
cleanup(*Addr, *tempStr, *outXmlFile, *status) {
  remote(*Addr, "null") {
    *local = "localPath=*tempStr++++forceFlag="; #str(*options);
    writeLine("stdout", "cleanup: local: *local");
    writeLine("stdout", "cleanup: outXmlFile: *outXmlFile");
    writeLine("stdout", "cleanup: tempStr: *tempStr");
    msiDataObjPut(*outXmlFile, "null", *local, *status);
    *Arg1 =  execCmdArg("");
    msiExecCmd("tmpCleanup", *Arg1, "null", "null", "null", *Result);
  }
}
INPUT *Cmd = "app", *outXmlFile="/zone/home/proj/foo.xml, *Pathf="/zone/home/proj/inputfile"
OUTPUT ruleExecOut
