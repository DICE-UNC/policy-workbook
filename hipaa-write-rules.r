writeRuleSet(*rb, *rule, *chksum) {
# hipaa-write-rules.r
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
