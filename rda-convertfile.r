mytestrule (*Option,*ItemName,*AName,*AValue,*AUnit) { 
# rda-convertfile.r
    on(*AName == "ConvertMe") {
         *ItemName = "/$rodsZoneClient/home/$userNameClient/" ++ *ItemName;
        irods_curl_get("http://polyglot.cci.drexel.edu/", *ItemName, *AValue, *out);
        if(*out == ""){
            deleteAVUMetadata(*ItemName, "ConvertMe", *AValue, *AUnit, *out3);
            addAVUMetadata(*ItemName, "Conversion Error", *AValue, "dest", *out2);
        }else{
            addAVUMetadata(*out, "Derived from", *ItemName, "iRODS path", *out2);
            deleteAVUMetadata(*ItemName, "ConvertMe", *AValue, *AUnit, *out3);  
        }
    }
}
INPUT *AName="ConvertMe", *ItemName="foo1.doc", *AValue="", *AUnit=""
OUTPUT ruleExecOut
