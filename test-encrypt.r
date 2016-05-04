test_encrypt {
#       *DataPath,                           source path
#       *Enc_path,                           destination path
#       *EncryptKey,                         32 byte encryption key
#       *EncryptVector,                      32 byte initialization vector
#       *Flag                                0 for unencrypt, 1 for encrypt
  *Collhome = "/$rodsZoneClient/home/$userNameClient/";
  *Coll = *Collhome ++ *Collrel;
  checkCollInput (*Coll);
  *Path = "*Coll/*File";
  checkPathInput (*Path);
# check that Encryption Vector has been set on collection
  *Q0 = select count(META_COLL_ATTR_ID) where COLL_NAME = '*Coll' and META_COLL_ATTR_NAME = 'ENCRYPT_VECTOR';
  foreach (*R0 in *Q0) {*Num = *R0.META_COLL_ATTR_ID;}
  if (*Num == "0") {
    *EncryptVector = *Vector;
    addAVUMetadataToColl (*Coll, "ENCRYPT_VECTOR", *Vector, "iRODSEncryption:Vector", *Status);
  } else {
    *Q = select META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_NAME = 'ENCRYPT_VECTOR';
    foreach (*R in *Q) {*EncryptVector = *R.META_COLL_ATTR_VALUE;}
  }
  *Q1 = select DATA_PATH, DATA_ID, DATA_RESC_HIER where COLL_NAME = '*Coll' and DATA_NAME = '*File';
  foreach (*R1 in *Q1) {
    *DataPath = *R1.DATA_PATH;
    *DataID = *R1.DATA_ID;
    *DataRescHier = *R1.DATA_RESC_HIER;
    msiSplitPathByKey (*DataRescHier, ";", *Rpath, *DataRescName);
    writeLine("stdout", "Encrypting file at *DataPath");
    *Q2 = select RESC_LOC where RESC_NAME = *DataRescName;
    foreach (*R2 in *Q2) {*Reschost = *R2.RESC_LOC;}
    encryptFunction (*DataID, *Flag, *DataPath, *Path, *EncryptVector, *DataRescName, *Reschost, *DestPath);
    break;
  }
  *len = strlen(triml(*DataRescHier, ";"))+1;
  *Lenr = strlen(*DataRescHier)-*len;
  *Resctop = substr(*DataRescHier,0,*Lenr);
  msiRunRebalance(*Resctop);
}
encryptFunction (*DataID, *Flag, *DataPath, *Path, *EncryptVector, *DataRescName,  *Reschost, *DestPath) {
  remote (*Reschost, "") {
    if(*Flag == 0) {
# decrypt
      *Enc_path = *DataPath ++ ".UNenc";
      *DestPath = *Path ++ ".UNenc";
# retrieve encryption key
      *Q1 = select META_DATA_ATTR_VALUE where DATA_ID = *DataID and META_DATA_ATTR_NAME = "ENCRYPT_KEY";
      foreach (*R1 in *Q1) {*Key = *R1.META_DATA_ATTR_VALUE;}
      writeLine ("stdout", "Original file *DataPath,\n Decrypted at *Enc_path,\n Key *Key,\n Vector *EncryptVector");
      msiencrypt_replica(*DataPath, *Enc_path, *Key, *EncryptVector, *Flag);
      msiPhyPathReg(*DestPath, *DataRescName, *Enc_path, "", *Status);
      if (*Status != 0) {writeLine("stdout", "Error registering *Path at *DestPath");}
      else {writeLine( "stdout", "Decrypted *Path and registered at *DestPath"); }
    } else {
# encrypt
      *Enc_path = *DataPath ++ ".enc";
      *DestPath = *Path ++ ".enc";
# get encryption key for file
      *Q1 = select count(META_DATA_ATTR_ID) where DATA_ID = *DataID and META_DATA_ATTR_NAME = "ENCRYPT_KEY";
      foreach (*R1 in *Q1) {*Num = *R1.META_DATA_ATTR_ID;}
      if (*Num == "0") {
        msiGetSystemTime (*Tim, "unix");
        *Keypath = "$userNameClient:$rodsZoneClient:*Tim:*Tim";
        msiSubstr (*Keypath, "0", "32", *Key);
      } else {
        *Q2 = select META_DATA_ATTR_VALUE where DATA_ID = *DataID and META_DATA_ATTR_NAME = "ENCRYPT_KEY";
        foreach (*R2 in *Q2) {*Key = *R2.META_DATA_ATTR_VALUE;}
      }
      writeLine ("stdout", "Original file *DataPath,\n Encrypted at *Enc_path,\n Key *Key,\n Vector *EncryptVector");
      msiencrypt_replica(*DataPath, *Enc_path, *Key, *EncryptVector, *Flag);
      msiPhyPathReg(*DestPath, *DataRescName, *Enc_path, "", *Status);
      if (*Status != 0) {writeLine("stdout", "Error registering *Path at *DestPath");
      } else {
        writeLine( "stdout", "Encrypted *Path and registered at *DestPath");
# set encryption key on the encrypted file
        msiSplitPath (*DestPath, *Coll, *File);
        addAVUMetadata (*DestPath, "ENCRYPT_KEY", *Key, "iRODSEncryption:Key", *Stat);
      }
    }
  }
}
INPUT *Collrel=$"test", *File=$"file1", *Flag=$1, *Vector=$"initializationvectorforirodscoll"
OUTPUT ruleExecOut
