importPolicies {
# hipaa-import-policies.r
# This rule imports rules from a file into the iCAT catalog
  msiAdmReadRulesFromFileIntoStruct(*FileName,*Struct);
  msiAdmInsertRulesFromStructIntoDB(*RuleBase,*Struct);
  msiAdmShowIRB ("null");
}
INPUT *FileName = "NewRules", *RuleBase = "UNCRules"
OUTPUT ruleExecOut
