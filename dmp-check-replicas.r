checkReplicas{
# dmp-check-replicas.r
#Loop over all files in the specified collection
#============ create a collection for log files if it does not exist ===============
  checkCollInput (*Coll);
  checkRescInput (*Res, $rodsZoneClient);
  createLogFile (*Coll, "log", "Check", *Res, *LPath, *Lfile, *L_FD);

 *Query = select DATA_NAME,COLL_NAME where COLL_NAME like '*Coll%';
 foreach(*Row in *Query){
   *Col = *Row.COLL_NAME;
   *Data = *Row.DATA_NAME;
   *temp_count=0;
   *Query2 = select count(DATA_PATH) where COLL_NAME='*Col' and DATA_NAME='*Data';
 # For every coll/data find those which do not have the required number of replicas
   foreach(*Row2 in *Query2){
     *temp_count = *Row2.DATA_PATH;
   }
   if(int(*temp_count) < *Numrep){
     *n = *Numrep - int(*temp_count);
     writeLine("*Lfile","*Col/*Data is missing *n replicas");
   }
 }
}
INPUT *Coll=$"/$rodsZoneClient/home/$userNameClient", *Res=$"LTLResc", *Numrep=$2
OUTPUT ruleExecOut
