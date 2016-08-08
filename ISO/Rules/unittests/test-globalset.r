globalSet {
# test way to set global variable
  racSetGlobal ();
  *Res = GLOBAL_STORAGE;
  *Home = GLOBAL_ACCOUNT;
  writeLine ("stdout", "*Res, *Home");
}
racSetGlobal = maing
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_STORAGE = "LTLResc"
maing {}
INPUT null
OUTPUT ruleExecOut
