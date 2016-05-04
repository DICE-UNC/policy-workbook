resourceReport {
# Print out information about each resource in the data grid
  *Q1 = select RESC_NAME, RESC_CLASS_NAME, RESC_ID, RESC_INFO, RESC_LOC, RESC_TYPE_NAME, RESC_VAULT_PATH, RESC_ZONE_NAME;
  foreach (*R1 in *Q1) {
    *Name = *R1.RESC_NAME;
    *Class = *R1.RESC_CLASS_NAME;
    *Id = *R1.RESC_ID;
    *Info = *R1.RESC_INFO;
    *Loc = *R1.RESC_LOC;
    *Type = *R1.RESC_TYPE_NAME;
    *Vault = *R1.RESC_VAULT_PATH;
    *Zone = *R1.RESC_ZONE_NAME;
    writeLine ("stdout", "Resource Name = *Name");
    writeLine ("stdout", "        Class = *Class");
    writeLine ("stdout", "           Id = *Id");
    writeLine ("stdout", "         Info = *Info");
    writeLine ("stdout", "          Loc = *Loc");
    writeLine ("stdout", "         Type = *Type");
    writeLine ("stdout", "        Vault = *Vault");
    writeLine ("stdout", "         Zone = *Zone");
  }
}
INPUT null
OUTPUT ruleExecOut
