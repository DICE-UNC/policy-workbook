listPolicies = main18
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_RULES = "Rules"
GLOBAL_VERSIONS = "Versions"
main18 {
# rac-listPolicies.r
# Policy18
# list the policies registered in the GLOBAL_ACCOUNT/GLOBAL_REPOSITORY/GLOBAL_RULES
  msiGetSystemTime (*Tim, "human");
  *Rep = GLOBAL_REPOSITORY ++ "/" ++ GLOBAL_RULES;
  *Coll = GLOBAL_ACCOUNT ++ "/*Rep";
  writeLine ("stdout", "On *Tim, list the policies in *Coll");
  *Colv = "*Coll/" ++ GLOBAL_VERSIONS;
  *Q1 = select DATA_NAME where COLL_NAME = *Coll;
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    writeLine ("stdout", "*File");
# list the versioned policies from GLOBAL_ACCOUNT/GLOBAL_REPOSITORY/GLOBAL_RULES/GLOBAL_VERSIONS
    *Q2 = select DATA_NAME, DATA_CREATE_TIME where COLL_NAME = '*Colv' and DATA_NAME like '*File..%';
    *Num = 0;
    *Date = *Tim;
    foreach (*R2 in *Q2) {
      *Ver = *R2.DATA_NAME;
      *T = *R2.DATA_CREATE_TIME;
      *Vend = int(substr(*Ver, strlen(*File)+2, strlen(*Ver)));
      if (*Vend > *Num) {
        *Num = *Vend;
        *Date = timestrf(datetime(double(*T)), "%Y:%m:%d");
      }
    }
    *Vers = *File ++ ".." ++ "*Num";
    if (*Num != 0) {writeLine ("stdout", "    Version *Vers on Date *Date");}
  }
}
INPUT null
OUTPUT ruleExecOut
