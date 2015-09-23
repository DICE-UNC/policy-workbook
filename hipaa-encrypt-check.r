encryptCheck {
# hipaa-encrypt-check.r
# Check that all files with ACCESS_APPROVAL = 1 have been encrypted
# and encrypt files if needed
  *Q1 = select DATA_NAME, COLL_NAME where META_DATA_ATTR_NAME = 'ACCESS_APPROVAL' and META_DATA_ATTR_VALUE = 1';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Coll = *R1.COLL_NAME;
    *Q2 = select META_DATA_ATTR_VALUE, META_DATA_ATTR_NAME where COLL_NAME = '*Coll' and DATA_NAME = '*File";
    *Count = 0;
    foreach (*R2 in *Q2) {
      *Name = *R2.META_DATA_ATTR_NAME;
      *Val = *Rw.META_DATA_ATTR_VALUE;
      if (*Name == "DATA_ENCRYPT" ) {
        *Count = 1;
        if(*Val != "1") {
          writeLine("stdout", "File *File has not been encrypted");
          *Path = "*Coll/*File";
          msiEncrypt(*Path);
          writeLine("stdout", "File *File has been encrypted");
# remove old encrypt flag
          *Str0 = "DATA_ENCRYPT=*Val";
          msiSTring2KeyValPair(*Str0, *Kvp0);
          msiRemoveKeyValuePairsFromObj(*Kvp0, *Path, "-d");
# Set encrypt flag to 1
          *Str1 = "DATA_ENCRYPT=1";
          msiString2KeyValPair(*Str1, *Kvp1);
          msiAssociateKeyValuePairsToObj(*Kvp1, *Path, "-d");
        }
      }
      if (*Count == "0") {
# remove old value and encrypt
        writeLine("stdout", "File *File has not been encrypted");
        *Path = "*Coll/*File";
        msiEncrypt(*Path);
        writeLine("stdout", "File *File has been encrypted");
# Set encrypt flag to 1
        *Str1 = "DATA_ENCRYPT=1";
        msiString2KeyValPair(*Str1, *Kvp1);
        msiAssociateKeyValuePairsToObj(*Kvp1, *Path, "-d");
      }
    }
  }
}
INPUT null
OUTPUT ruleExecOut

