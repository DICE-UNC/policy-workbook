listUserAccess {
# odum-list-ACL.r
    *c = "/$rodsZoneClient/home/$userNameClient";
    summary(*c);
}
summary (*c) {
# rule to list all persons who have access to a home collection
#Get USER_ID for the input user name
  *Query = select USER_ID where USER_NAME = '$userNameClient';
  *Userid = "";
  foreach(*Row in *Query) {
    *Userid = *Row.USER_ID;
  }
  if(*Userid == "") {
    writeLine("stdout", "Input user name *User is unknown");
    fail;
  }
  else {writeLine("stdout", "UserID is *Userid");}
# loop over files in home collection
  *Coll = "*c%";
  *rs = select DATA_ID, DATA_SIZE where COLL_NAME like '*Coll';
  *res.total = str(0);
  *total.total = str(0);
  foreach(*r in *rs) {
    *fn = *r.DATA_ID;
    *ds = *r.DATA_SIZE;
# Find ACL for the file
    *Query4 = select DATA_ACCESS_TYPE, DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = '*fn';
# Loop over access controls for each file
    foreach(*Row4 in *Query4) {
      *Userdid = *Row4.DATA_ACCESS_USER_ID;
      *Datatype = *Row4.DATA_ACCESS_TYPE;
      if(*Userid != *Userdid) {
        *Query5 = select TOKEN_NAME where TOKEN_NAMESPACE = 'access_type' and TOKEN_ID = '*Datatype';
        foreach (*Row5 in *Query5) {*Access = *Row5.TOKEN_NAME;}
        *Query6 = select USER_NAME where USER_ID = '*Userdid';
        foreach (*Row6 in *Query6) {*Usern = *Row6.USER_NAME;}
#  *DATA_ID has access control *Access for user *Usern
#  Count number of files accessible by this user, and size of files accessible by user
        if (contains(*res, *Usern)) {
          *res.*Usern = str(int(*res.*Usern) + 1)
          *total.*Usern = str(double(*total.*Usern) + double(*ds))
        } else {
          *res.*Usern = str(1);
          *total.*Usern = *ds;
        }
      }
    }
    *res.total = str(int(*res.total) + 1);
    *total.total = str(double(*total.total) + double(*ds));
  }
  writeLine("stdout", "usern\t\tcount\t\tavg size\t\ttotal size");
  foreach(*Usern in *res) {
    *Us = "*Usern\t\t";
    if(strlen(*Usern) >= 8) {*Us = "*Usern\t";}
    if(*Usern != "total") {
      writeLine("stdout", "*Us"++*res.*Usern++"\t\t"++str(double(*total.*Usern)/int(*res.*Usern))++"\t\t"++*total.*Usern);
    }
  }
  writeLine("stdout", "total\t\t"++*res.total++"\t\t"++str(double(*total.total)/int(*res.total))++"\t\t"++*total.total);
}
input null
output ruleExecOut
