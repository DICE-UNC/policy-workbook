acPostProcForPut {
  ON($objPath like "/UNC-ARCHIVE/home/Archive/*") {
    delay("<PLUSET>1s</PLUSET>") {
      msiSysReplDataObj('replResc', 'null'); 
    }
  } 
}
