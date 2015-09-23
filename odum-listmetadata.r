listRule {
# odum-listmetadata.r
#Compare the metadata attributes on the collection with value "null" with the attributes on the files in the collection
#List all missing metadata on the files in the collection
  *Coll= "/$rodsZoneClient/home/$userNameClient" ++ "%";
  *Q1 = select COLL_NAME where COLL_NAME like '*Coll';
#Loop over collections
  foreach(*R1 in *Q1) {
    *C = *R1.COLL_NAME;
    *Q2 = select order_asc(META_COLL_ATTR_NAME) where COLL_NAME = '*C' and META_COLL_ATTR_VALUE = 'null';
    *Q12 = select count(META_COLL_ATTR_NAME) where COLL_NAME = '*C' and META_COLL_ATTR_VALUE = 'null';
#Count number of null metadata attributes on the collection
    foreach (*R12 in *Q12) {
      *Count = *R12.META_COLL_ATTR_NAME;
    }
    *Q3 = select DATA_NAME where COLL_NAME = '*C';
    *Q13 = select count(DATA_NAME) where COLL_NAME = '*C';
#Count the number of files in the collection
    foreach (*R13 in *Q13) {
      *Numfiles = *R13.DATA_NAME;
    }
    if(int(*Numfiles) > 0) {
      if (int(*Count) > 0) {
#Loop over the null metadata attributes on the collection
        foreach (*R2 in *Q2) {
          *NameColl = *R2.META_COLL_ATTR_NAME;
#Loop over the files in the collection
          foreach (*R3 in *Q3) {
            *File = *R3.DATA_NAME;
            *Q4 = select order_asc(META_DATA_ATTR_NAME) where COLL_NAME = '*C' and DATA_NAME = '*File' and META_DATA_ATTR_UNITS != 'iRODSUserTagging:Tag';
            *Q14 = select count(META_DATA_ATTR_NAME) where COLL_NAME = '*C' and DATA_NAME = '*File' and META_DATA_ATTR_UNITS != 'iRODSUserTagging:Tag';
#Count the number of metadata attributes on a file
            foreach (*R14 in *Q14) {
              *Countf = *R14.META_DATA_ATTR_NAME;
            }
            *Found = 0;
            if (int(*Countf) > 0) {
#Loop over the tags on a file 
              foreach(*R4 in *Q4) {
                *Name = *R4.META_DATA_ATTR_NAME;
                if (*NameColl == *Name) {
                  *Found = 1;
                  break;
                } 
              }
            }
#For missing metadata attributes, print a line to the screen
            if (*Found == 0) {
              writeLine("stdout","*C/*File is missing *NameColl");
            }
          }
        }
      }
    }
  }
}
INPUT null
OUTPUT ruleExecOut
