# the copy.re must be available on all servers
# the rule admin microservices must also be available on all servers
copyRule {
# odum-copyRule.r
  remoteDeployRuleSets( *ruleBaseName, *targets);
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
writeRuleSet(*rb, *rule, *chksum) {
  backupRuleSet(*rb, *rbak):::{
    if(errorcode(*rbak) == 0) {
      msiMvRuleSet(*rbak, *rb);
    }
  };
  msiWriteRuleSet(*rb, *rule):::{
    *ec = errorcode(msiRuleSetExists(*rb, *e));
    if(*ec == 0) {
      if( *e == 0) {
        msiRmRuleSet(*rb);
      }
    }
   };
   msiChksumRuleSet(*rb, *chksum2);
   if(*chksum != *chksum2) {
     failmsg(-1, "chksum failed");
   }
}

backupRuleSet(*rb, *rbak) {
  *i = 0;
        
  while(true) {
    *rbak = "*rb.bak*i"
    *ec = errorcode(msiRuleSetExists(*rbak, *e));
    if(*ec != 0) {
      break;
    } else if( *e != 0) {
      break;
    }
    *i = *i + 1;
  }
  msiMvRuleSet(*rb, *rbak);
}
INPUT *ruleBaseName=list("core"),*targets=list("localhost")
OUTPUT rule ExecOut
