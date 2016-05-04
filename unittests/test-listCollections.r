reportCollection{
#Create report for collections listng number of files and file size

 *Q0 = select USER_ID where USER_NAME = '$userNameClient'; 
 foreach (*R0 in *Q0) {*Pub = *R0.USER_ID;}
 
  *Q1 = select COLL_ACCESS_COLL_ID where COLL_ACCESS_USER_ID = '*Pub'; 
  foreach (*R1 in *Q1) { 
    *Collid  =  *R1.COLL_ACCESS_COLL_ID; 
    *Q2 = select count(DATA_ID), sum(DATA_SIZE), COLL_NAME where COLL_ID = '*Collid'; 
    foreach (*R2 in *Q2) { 
      *Num = *R2.DATA_ID; 
      *Size = *R2.DATA_SIZE; 
      *Coll = *R2.COLL_NAME; 
      writeLine("stdout", "$userNameClient collection *Coll has *Num files with size *Size bytes"); 
    } 
  } 
} 
INPUT *PathColl = "/$rodsZoneClient/home/$userNameClient"
OUTPUT  ruleExecOut
