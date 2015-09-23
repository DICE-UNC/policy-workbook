copyRule {
# hipaa-deploy-rules.r
# the copy.re must be available on all servers
# the rule admin microservices must also be available on all servers
  remoteDeployRuleSets(
    *ruleBaseName,
    *targets
  );
}

remoteDeployRuleSets(*rbs, *addrs) {
  *out = "";
  foreach(*addr in *addrs) {
    foreach(*rb in *rbs) {
      *err = errorcode(remoteWriteRuleSet(*rb, *addr));
      *out = *out ++ "*rb -> *addr " ++ (if *err != 0 then "failure" else "success") ++ "\n";
    }
  }
  writeLine("stdout", *out);
}

remoteWriteRuleSet(*rb, *addr) {
  msiReadRuleSet(*rb, *rule);
  msiChksumRuleSet(*rb, *chksum);
  remote(*addr, "") {
    writeRuleSet(*rb, *rule, *chksum);
  }
}

INPUT *ruleBaseName=list("core"),*targets=list("localhost")
OUTPUT ruleExecOut
