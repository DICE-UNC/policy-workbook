listRules {
# dmp-pepRules.r
# Generate a report listing the rules that are automatically enforced
#============ create a collection for reports if it does not exist ===============
  checkCollInput (*Coll);
  checkRescInput (*Res, $rodsZoneClient);
  createLogFile (*Coll, "Reports", "Policies", *Res, *LPath, *Lfile, *L_FD);

  msiAdmShowIRB(*A);
  msiDataObjWrite(*FD,"stdout",*WLEN);
  msiDataObjClose(*FD,*Status);
}
INPUT *Coll = "/$rodsZoneClient/home/$userNameClient/Reports", *Res = "demoResc"
OUTPUT ruleExecOut
