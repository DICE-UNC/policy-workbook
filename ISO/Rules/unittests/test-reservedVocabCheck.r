reservedVocabCheck = mainv
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_SIPS = "SIPS"
mainv {
# test policy for verifying reserved vocabulary
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  racReservedVocabCheck (*File, *Coll, *Archive, *S6)
  writeLine ("stdout", "Status of reserved vocabulary check is *S6");
}
racReservedVocabCheck (*File, *Coll, *Archive, *S6) {
# Policy function to verify descriptive metadata against reserved vocabulary
  msiGetSystemTime (*Tim, "human");
  *S6 = "0";
  *Q0 = select count(META_DATA_ATTR_VALUE) where COLL_NAME = '*Coll' and DATA_NAME = '*File' and META_DATA_ATTR_NAME = "Archive-Description";
  foreach (*R0 in *Q0) { *Num = *R0.META_DATA_ATTR_VALUE; }
  if (*Num == "0") { 
    *S6 = "1";
  } else {
    foreach(*R4 in *Q4) {
      *Str = *R4.META_DATA_ATTR_VALUE;
      split (*Str, *L);
      foreach (*S in *L) {
        msiCurlUrlEncodeString(*S, *encodedUrl);
        *url = "http://localhost:8080/hive-voccabservice-rest-1.0-SNAPSHOT/rest/concept/uat/concept?uri=" ++  str(*encodedUrl);
        msiCurlGetStr(*url, *outStr);
        if (*outStr like "\*DataNotFoundException\*") { *S6 = "1"; }
      }
    }
  }
  if (*S6 != "1") { *S6 = "2"; }
  addAVUMetadata ("*Coll/*File", "Audit-CheckVocab", *S6, *Tim, *Status);
}
INPUT *Archive="Archive-A", *File=$"rec3"
OUTPUT ruleExecOut
