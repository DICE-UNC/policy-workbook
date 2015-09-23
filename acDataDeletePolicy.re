acDataDeletePolicy {
#  Rule condition is used to choose which collections to protect
  ON($objPath like "/UNC-CH/home/HIPAA/Reports/* ") {
    msiDeleteDisallowed;
  }
}
