testUserMetadata {
# verify which attributes are on user names
  *N = "Metadata";
  *Metau.*N = "User";
  *Q3 = select order(META_USER_ATTR_NAME) where META_USER_ATTR_NAME like 'Repository%';
  foreach (*R3 in *Q3) {
    *Nam = *R3.META_USER_ATTR_NAME;
    *Metau.*Nam = "User"; 
  }
  msiGetSystemTime (*Tim, "human");
  writeLine ("stdout", "Preservation metadata at *Tim");
  writeLine ("stdout", "-------------------");
  foreach (*Nam in *Metau) { 
    *Typ = *Metau.*Nam; 
    writeLine("stdout", "*Typ      *Nam");
    *Q1 = select USER_NAME, META_USER_ATTR_ID, META_USER_CREATE_TIME where META_USER_ATTR_NAME = *Nam;
    foreach (*R1 in *Q1) { 
      *N = *R1.USER_NAME;
      *Id = *R1.META_USER_ATTR_ID;
      *T = *R1.META_USER_CREATE_TIME;
      *Date = timestr (datetime(double(*T)));
      writeLine ("stdout", " *N, *Id, *Date");}
  }
}
INPUT null
OUTPUT ruleExecOut
