validateDataObjectOntologies {
# odum-validateOntologies.r
#Compare the metadata attributes on the collection with value "null" with the attributes on the files in the collection
#List all missing metadata on the files in the collection
  *Coll= "/$rodsZoneClient/home/$userNameClient" ++ "%";
  *Q1 = select COLL_NAME where COLL_NAME like '*Coll';
  writeLine("stdout", "Metadata validation report");        
#Loop over collections 
  foreach(*R1 in *Q1) {
    *C = *R1.COLL_NAME;
    *Q2 = select order_asc(META_COLL_ATTR_NAME) where COLL_NAME = '*C' and META_COLL_ATTR_UNITS = 'iRODSUserTagging:HIVE:VocabularyTerm';
    *Q3 = select DATA_NAME where COLL_NAME = '*C';
    foreach (*R3 in *Q3) {
      *File = *R3.DATA_NAME;
#writeLine("stdout","*File has *R3");
      *Q4 = select order_asc(META_DATA_ATTR_NAME) where COLL_NAME = '*C' and DATA_NAME = '*File' and META_DATA_ATTR_UNITS ='iRODSUserTagging:HIVE:VocabularyTerm';
      foreach(*R4 in *Q4) {
        *Name = *R4.META_DATA_ATTR_NAME;
#writeLine("stdout","*C/*File has *R4 ... validating");
        msiCurlUrlEncodeString(*Name, *encodedUrl);
	*url = "http://localhost:8080/hive-voccabservice-rest-1.0-SNAPSHOT/rest/concept/uat/concept?uri=" ++  str(*encodedUrl);
#writeLine("stdout", "url is *url");
	
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
