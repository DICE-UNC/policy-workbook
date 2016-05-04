bcExtractFeatureFilesRule {
# odum-bcExtractFeatureFilesRule.r
# Command to be executed located in directory irods/server/bin/cmd/bulk_extractor
# This rule reads the disk image and generates a number of feature files in
# the specified output directory. It invokes the Bulk Extractor tool.
# Input Parameter is:
#   Image File path
# Output Parameter is:
#   File Path for Feature Files
#
# Example:
# bulk_extractor
#  ~/Research/TestData/M57-Scenario/usbflashdrives/jo-work-usb-2009-12-11.aff
#  -o ~/Research/TestData/BEOutputs/jow-output
# Rule:
#  irule -F rulemsiBcExtractFeatureFiles "*image='/path/to/image.aff'" "outFeatDir='/path/to/outdir'"
# Modified rule to loop over files in a directory
  *Cmd="bulk_extractor";
  *timeStamp = double (time());

# Now Make a query to get the path to the image and the resource name
# DATA_PATH: Physical path name for digital object in resource
# DATA_RESC_NAME: Logical name of storage resource
  *Query = select DATA_NAME, DATA_PATH, DATA_RESC_NAME where COLL_NAME like '*Coll%';
  foreach (*row in *Query) {
    *Path = *row.DATA_PATH;
    *Resource = *row.DATA_RESC_NAME;
    *File = *row.DATA_NAME
    writeLine("stdout", "Path = *Path, Resource= *Resource");

# Make another query for IP Address of the resource
# RESC_LOC: Resource IP Address
# DATA_RESC_NAME: Logical name of storage resource
    *Query2 = select RESC_LOC where DATA_RESC_NAME = '*Resource';
    foreach (*row in *Query2) {
      *Addr = *row.RESC_LOC;
      writeLine("stdout", "ADDR = *Addr, Resource= *Resource");
    }
    *prefixStr = "*File" ++ "timeStamp$userNameClient";
    *tempStr = "/tmp/*prefixStr" ++ "outFeatDir";

    *Arg1 = execCmdArg(*Path);    # Image
    *Arg2 = execCmdArg("-o");
    *Arg3 = execCmdArg(*tempStr); # Output Feature Directory

    writeLine("stdout", "Running Bulk Extractor Tool...");
    writeLine("stdout", "Command: *Cmd *Arg1 *Arg2 *Arg3");

    if(errorcode(msiExecCmd(*Cmd,"*Arg1 *Arg2 *Arg3", *Addr, "null", "null",*Result)) < 0) {
      msiGetStderrInExecCmdOut(*Result,*Out);
      writeLine("stdout", "ERROR:*Out");
    } else {
      # Command executed successfully
      msiGetStdoutInExecCmdOut(*Result,*Out);
      writeLine("stdout", "Output is *Out ");
      # Clean up the temporary files
      cleanup(*Addr, *tempStr, *outFeatDir, *prefixStr, *status);
    }
  }
}

# Function: cleanup: Calls a script to remove the temporary files created
# in /tmp
cleanup: input string * input string * input string * input string * output integer -> integer
cleanup(*Addr, *tempStr, *outFeatDir, *prefixStr, *status) {

       writeLine("stdout", "Cleanup: Moving *tempStr to *outFeatDir");
       remote(*Addr, "null") {
            *local = "filePath=*tempStr++++forceFlag="; #str(*options);
            writeLine("stdout", "cleanup: local: *local");
            writeLine("stdout", "cleanup: outFeatDir: *outFeatDir");
            writeLine("stdout", "cleanup: tempStr: *tempStr");

            msiDataObjPut(*outFeatDir, "null", *local, *status);
            *Arg1 =  execCmdArg(*prefixStr);
            msiExecCmd("tmpCleanup", *Arg1, "null", "null", "null", *Result);
       }
}

INPUT *Coll="/OdumStagingZone/home/bitcurator/bitcuratortmp", *outFeatDir="/OdumStagingZone/home/bitcurator/bitcurator_output"
OUTPUT ruleExecOut
