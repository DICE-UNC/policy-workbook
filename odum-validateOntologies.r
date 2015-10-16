validateDataObjectOntologies {
# odum-validateOntologies.r
#Check that the terms used comply with a standard vocabulary
  *Coll= "/$rodsZoneClient/home/$userNameClient" ++ "%";
  *Q1 = select COLL_NAME where COLL_NAME like '*Coll';
  writeLine("stdout", "Vocabulary validation report");
#Loop over collections
  foreach(*R1 in *Q1) {
    *C = *R1.COLL_NAME;
    *Q3 = select DATA_NAME where COLL_NAME = '*C';
    foreach (*R3 in *Q3) {
      *File = *R3.DATA_NAME;
      *Q4 = select order_asc(META_DATA_ATTR_NAME) where COLL_NAME = '*C' and DATA_NAME = '*File' and META_DATA_ATTR_UNITS ='iRODSUserTagging:HIVE:VocabularyTerm';
      foreach(*R4 in *Q4) {
        *Name = *R4.META_DATA_ATTR_NAME;
        msiCurlUrlEncodeString(*Name, *encodedUrl);
        *url = "http://localhost:8080/hive-voccabservice-rest-1.0-SNAPSHOT/rest/concept/uat/concept?uri=" ++  str(*encodedUrl);
        msiCurlGetStr(*url, *outStr);
        if (*outStr like "\*DataNotFoundException\*") then {
          writeLine("stdout", "*C/*File has uri *Name that is not in a valid ontology");
        }
      }
    }
  }
}
INPUT null
OUTPUT ruleExecOut
