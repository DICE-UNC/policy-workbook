test_encrypt {
#       *DataPath,                           source path
#       *Enc_path,                           destination path
#       *EncryptKey,                         32 byte encryption key
#       *EncryptVector,                      32 byte initialization vector
#       *Flag                                0 for unencrypt, 1 for encrypt
  *Reschost ="LTLRenci";
  *Collhome = "/$rodsZoneClient/home/$userNameClient/";
  *Coll = *Collhome ++ *Collrel;
  checkCollInput (*Coll);
  writeLine ("stdout", "*Coll");
  *Path = "*Coll/*File";
  checkPathInput (*Path);
  writeLine ("stdout", "*Path");
  *Q0 = select META_COLL_ATTR_VALUE where COLL_NAME = '*Coll' and META_COLL_ATTR_NAME = 'ENCRYPT_VECTOR';
  foreach (*R0 in *Q0) {*EncryptVector = *R0.META_COLL_ATTR_VALUE; }
  *Q1 = select DATA_PATH, DATA_ID where DATA_NAME = *File and COLL_NAME = *Coll and DATA_RESC_NAME = *Reschost;
  foreach (*R1 in *Q1) {
    *DataPath = *R1.DATA_PATH;
    *DataID = *R1.DATA_ID;
    encryptFunction (*DataID, *Flag, *DataPath, *Path, *EncryptVector, *DataRescName, *Reschost);
  }
}
encryptFunction (*DataID, *Flag, *DataPath, *Path, *EncryptVector, *DataRescName,  *Reschost) {
  remote (*Reschost, "") {
    *Q2 = select META_DATA_ATTR_VALUE where DATA_ID = '*DataID' and META_DATA_ATTR_NAME = 'ENCRYPT_KEY';
    foreach (*R2 in *Q2) {*EncryptKey = *R2.META_DATA_ATTR_VALUE; }
    if(*Flag == 0) {
      *Enc_path = *DataPath ++ ".UNenc";
      *DestPath = *Path ++ ".UNenc";
    }
    else {
      *Enc_path = *DataPath ++ ".enc";
      *DestPath = *Path ++ ".enc";
    }
    msiencrypt_replica(*DataPath, *Enc_path, *EncryptKey, *EncryptVector, *Flag);
    msiPhyPathReg(*DestPath, *DataRescName, *Enc_path, "", *Status);
    if (*Status != 0) {writeLine("stdout", "Error registering *Path at *DestPath");}
    else {writeLine( "stdout", "Encrypted *Path and registered at *DestPath" );}
  }
}
INPUT *Collrel=$"test", *File=$"file1", *Flag=1
OUTPUT ruleExecOut
