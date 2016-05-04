listFederations {
# dfc-list-feds
# list all federations with this zone
  writeLine("stdout","Federated zones report");
  writeLine("stdout","");
  writeLine("stdout","Name                        Connection");
  writeLine("stdout","--------------------------------------");
  *Count = 0;
  *Q1 = select ZONE_NAME, ZONE_CONNECTION where ZONE_TYPE = 'remote';

  foreach (*R1 in *Q1) {
    *Name = *R1.ZONE_NAME;
    *Conn = *R1.ZONE_CONNECTION;
    *Count = *Count + 1;
    if (strlen(*Name) < 8) {*Name = *Name ++ "\t";}
    if (strlen(*Name) < 16) {*Name = *Name ++ "\t";}
    if (strlen(*Name) < 24) {*Name = *Name ++ "\t";}
    writeLine("stdout","*Name    *Conn");
  }

  writeLine("stdout","");
  writeLine("stdout","Total federated zones: *Count");
}
INPUT null
OUTPUT ruleExecOut
