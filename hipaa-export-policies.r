exportPolicies {
# hipaa-export-policies.r
# Read the rules from the iCAT catalog
# This rule is run on the test system
# Create a file with the rules for import on the production system
  msiGetRulesFromDBIntoStruct (*RuleBase, "0", *Struct);
  msiAdmWriteRulesFromStructIntoFile (*FileName, *Struct);
  msiAdmShowIRB("null");
}
INPUT *RuleBase = "TestBase", *FileName = "NewRules"
OUTPUT ruleExecOut
