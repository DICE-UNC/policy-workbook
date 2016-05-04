testemail {
# check whether can send e-mail from LifeTime Library
  msiSendMail ("rwmoore@renci.org", "test", "checking whether can send e-mail");
  writeLine ("stdout", "Attempted to send myself e-mail");
}
INPUT null
OUTPUT ruleExecOut
