listRules {
# dmp-pepRules.r
# Generate a report listing the rules that are automatically enforced
#============ create a collection for reports if it does not exist ===============
  checkCollInput (*Coll);
  checkRescInput (*Res, $rodsZoneClient);
  createLogFile (*Coll, "Reports", "Policies", *Res, *LPath, *Lfile, *Dfile, *L_FD);

  msiAdmShowIRB(*A);
  msiDataObjCreate("*Lfile","null",*FD);
  msiDataObjWrite(*FD,"stdout",*WLEN);
  msiDataObjClose(*FD,*Status);
}
INPUT *Coll = "/$rodsZoneClient/home/$userNameClient/Reports", *Res = "demoResc"
OUTPUT ruleExecOut
