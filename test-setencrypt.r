test_encrypt {
# set the ENCRYPT_VECTOR value on a collection
  *Collhome = "/$rodsZoneClient/home/$userNameClient/";
  *Coll = *Collhome ++ *Collrel;
  checkCollInput (*Coll);
  *Q0 = select count(META_COLL_ATTR_VALUE) where COLL_NAME = '*Coll' and META_COLL_ATTR_NAME = 'ENCRYPT_VECTOR';
  foreach (*R0 in *Q0) {*NumV = *R0.META_COLL_ATTR_VALUE; }
  if (*NumV == "0") {
# set initialization vector on collection
    addAVUMetadataToColl (*Coll, "ENCRYPT_VECTOR", *Vector, "iRODSEncryption:Vector", *Status);
  } 
}
INPUT *Collrel=$"test", *Vector=$"initializationvectorforirodscoll"
OUTPUT ruleExecOut
