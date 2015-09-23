  testWorkflowCall2 {
  # odum-testWorkflowCall2.mss
    msiExecCmd("myWorkFlow", *File1, "null", "null", "null", *Result1);
    msiExecCmd("myWorkFlow", *File2, "null", "null", "null", *Result2);
    msiGetFormattedSystemTime(*myTime, "human", "%d-%d-%d %ldh:%ldm:%lds");
    acRunWorkFlow("/raja8/home/rods/msso/mssop1/mssop1.run",*R_BUF);
 #  Process *R_BUF contents
    writeLine("stdout", "Workflow Executed Successfully at *myTime");
  }
