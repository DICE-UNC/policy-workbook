acPostProcForModifyAVUMetadata(*Option,*ItemType,*ItemName,*AName,*AValue,*AUnit) { 
    on(*AName == "ConvertMe") {
        irods_curl_get("http://polyglot.cci.drexel.edu/", *ItemName, *AValue, *out);
        if(*out == ""){
            deleteAVUMetadata(*ItemName, "ConvertMe", *AValue, *AUnit, *out3);
            modAVUMetadata(*ItemName, "Conversion Error", *AValue, "dest", *out2);
        }else{
            modAVUMetadata(*out, "Derived from", *ItemName, "iRODS path", *out2);
            deleteAVUMetadata(*ItemName, "ConvertMe", *AValue, *AUnit, *out3);  
        }
    }
}
