acBulkGetPreProcPolicy{ 
  msiSplitPath( $objPath, *Coll, *File);
  if (*Coll == "/UNC-CH/home/HIPAA") {
    msiSetBulkGetPostProcPolicy("off");
  }
}
