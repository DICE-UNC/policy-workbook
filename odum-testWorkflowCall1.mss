  testWorkflowCall1 {
  # odum-testWorkflowCall1.mss
	msiExecCmd("myWorkFlow", *File1, "null", "null", "null", *Result1);
	msiExecCmd("myWorkFlow", *File2, "null", "null", "null", *Result2);
	msiGetFormattedSystemTime(*myTime, "human", "%d-%d-%d %ldh:%ldm:%lds");
	msiDataObjOpen("objPath=/raja8/home/rods/msso/mssop1/mssop1.run++++openFlags=O_RDONLY",*S_FD);
	msiDataObjRead(*S_FD,*Len,*R_BUF);
 #  Process *R_BUF contents
	msiDataObjClose(*S_FD,*Status2);
	writeLine("stdout", "Workflow Executed Successfully at *myTime");
  }
