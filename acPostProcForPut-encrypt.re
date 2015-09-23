acPostProcForPut {
# Encrypt data submitted to /UNC-CH/home/HIPAA/Archive
  *Path = $objPath;
  msiSplitPath(*Path, *Coll, *File);
  if (*Coll == "/UNC-CH/home/HIPAA/Archive") {
# Need to create micro-service for encryption
     msiEncrypt (*Path);
# Set encrypt flag to 1
    *Str1 = "DATA_ENCRYPT=1";
    msiString2KeyValPair(*Str1, *Kvp1);
    msiAssociateKeyValuePairsToObj(*Kvp1, *Path, "-d");
  }
}
