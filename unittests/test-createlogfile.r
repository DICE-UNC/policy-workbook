delayed	{
  *Src = "/lifelibZone/home/$userNameClient/Class-INLS624/Rules/";
  checkCollInput (*Src);
  *Sub = "test";
  *Name = "Manifest.txt";
  *Res = "LTLResc";
  testcreateLogFile (*Src, *Sub, *Name, *Res, *LPath, *Lfile, *L_FC);
}
testcreateLogFile(*Coll, *Sub, *Name, *Res, *LPath, *LFile, *L_FC) {
  delay("<PLUSET>1m</PLUSET>")  {
    msiGetSystemTime(*TimeH, "human");
    *LPath = "*Coll/*Sub";
    isColl (*LPath, "stdout", *Status);
    if (*Status < 0) { fail;}
      *Lfile = "*LPath/*Name-*TimeH";
      *Dfile = "destRescName=*Res++++forceFlag=";
      msiDataObjCreate(*Lfile, *Dfile, *L_FD);	
    }
  }
}
INPUT null
OUTPUT ruleExecOut
