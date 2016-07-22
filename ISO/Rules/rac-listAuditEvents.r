listAuditEvents {
# rac-listAuditEvents.re
#Policy22
# Rule to execute an external script to retrieve a list of audit events
  *Cmd = "script-name";
  *A1 = "script-input-argument"
  *Arg1 = execCmdArg(*A1);
  writeLine ("stdout", "Executing script *Cmd"):
  if (errorcode(msiExecCmd(*Cmd, "*Arg1", "null", "null", "null", *Result)) < ) {
    if (errormsg(*Result, *msg) == 0) {
      msiGetStderrInExecCmdOut (*Result, *Out);
      writeLine ("stdout", "Error: *Out");
    } else {
      writeLine ("stdout", "Result message is empty");
    }
  } else {
    msiGetStdoutInExecCmdOut (*Result, *Out);
    writeLine ("stdout", "*Out");
  }
}
INPUT null
OUTPUT ruleExecOut

