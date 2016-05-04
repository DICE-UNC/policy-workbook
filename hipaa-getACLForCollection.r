getACLForCollection {
# hipaa-getACLForCollection.r
# lists the access controls on a collection
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Sub";
  *Q1 = select COLL_ACCESS_TYPE, COLL_ACCESS_USER_ID where COLL_NAME like '*Coll%';
  foreach(*R1 in *Q1) {
    *Ucoltyp = *R1.COLL_ACCESS_TYPE;
    *Usern = *R1.COLL_ACCESS_USER_ID;
    *Q5 =  select TOKEN_NAME where TOKEN_NAMESPACE = 'access_type' and TOKEN_ID = '*Ucoltyp';
    foreach (*R5 in *Q5) { *Access = *R5.TOKEN_NAME;}
    *Q6 = select USER_NAME where USER_ID = '*Usern';
    foreach (*R6 in *Q6) {*Uname = *R6.USER_NAME;}
    writeLine ("stdout", "*Uname \t\t*Access");
  }
}
INPUT *Sub =$"rules" 
OUTPUT ruleExecOut
    
