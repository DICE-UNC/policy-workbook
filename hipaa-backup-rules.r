backupRuleSet(*rb, *rbak) {
# hipaa-backup-rules.r
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
