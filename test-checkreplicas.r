checkReplicas {
# test-check-replicas.r
#Loop over all files in the library
#============ create a collection for log files if it does not exist ===============
  checkRescInput (*Resc1, $rodsZoneClient);
  createLogFile ("/$rodsZoneClient/home/$userNameClient", "log", "Check", *Resc1, *LPath, *Lfile, *L_FD);
  writeLine("stdout", "Require *Numrep replicas");
  writeLine("stdout", "Available resources are *Resc1 and *Resc2");
  writeLine("stdout", "Will not replicate files on *Rescweb");
  *Rescn = *Rescweb;
  writeLine("stdout", "*Rescn");
  *Total = 0;
  *Jround = 0;
  *NumRepCreated = 0;
#============ set up the resources that can be used for replication ===============
  getRescLim (*Rlist, *Ulist0, *Resc1, *Resc2, *Ir);
  *Irm1 = *Ir - 1;
  if(*Ir < *Numrep) {
    writeLine("stdout","Required number of replicas, *Numrep, exceeds the number of storage vaults, *Ir");
    fail;
  }  # end of check on number of available resources
  *Q1 = select USER_NAME;
  foreach (*R1 in *Q1) {
    *Usern = *R1.USER_NAME;
    writeLine("stdout", "Checking user *Usern");
    *Coll = "/$rodsZoneClient/home/*Usern";
    *Query = select count(DATA_ID), DATA_NAME,COLL_NAME where COLL_NAME like '*Coll%';
    foreach(*Row in *Query){
      *Num = *Row.DATA_ID;
      *Col = *Row.COLL_NAME;
      *Data = *Row.DATA_NAME;
      *n = *Numrep - int(*Num);
      if (*n > 0) {
        *Total = *Total + 1;
        *Ulist = *Ulist0;
        *Rescn = *Rescweb;
        *Q3 = select DATA_RESC_NAME where DATA_NAME = '*Data' and COLL_NAME = '*Col';
        foreach (*R3 in *Q3) {
          *Rescn = *R3.DATA_RESC_NAME;
          for(*J=0;*J<*Ir;*J=*J+1) {
            if(elem(*Rlist,*J) == *Rescn) {
              *Ulist = setelem(*Ulist,*J,"1");
              *Resu = *Rescn;
              break;
            }  # end of set of *Ulist for resource
          }  # end of loop over resources
        }
        if (*Rescn != *Rescweb) {
          writeLine ("stdout", "*Col/*Data is missing *n replicas, with copy on *Resu");
          writeLine ("stdout", "    replicating the missing file");
          selectRescUpdate (*Rlist, *Ulist, *Ir, *Resource);
          createReplicas (*n, *Ir, "stdout", *Ulist, *Rlist, *Jround, *Resource, *Col, *Data, *NumRepCreated);
        }
      }
    }
  }
  writeLine("stdout", "Missing *Total replicas");
  writeLine("stdout", "Created *NumRepCreated replicas");
  msiDataObjWrite(*L_FD, "stdout", *WLEN);
  msiDataObjClose (*L_FD, *Status);
}
checkRescInput (*Res, *Zone) {
# local zone is defined by your irods_environment file
  if (*Zone != $rodsZoneClient) {
# execute query in the remote zone
    findZoneHostName(*Zone, *Host, *Port);
    remote (*Host,"<ZONE>*Zone</ZONE>") {
      *Q1 = select count(RESC_ID) where RESC_NAME = '*Res';
      foreach (*R1 in *Q1) {*n = *R1.RESC_ID;}
      if (*n == "0") {
        writeLine("stdout","Remote resource *Res is not defined in zone *Zone");
#       fail;
      }
      writeLine("stdout", "Resource *Res exists in remote zone *Zone");
    }
  }
  else {
# query local zone
    *Q1 = select count(RESC_ID) where RESC_NAME = '*Res';
    foreach (*R1 in *Q1) {*n = *R1.RESC_ID;}
    if (*n == "0") {
      writeLine ("stdout", "Local resource *Res is not defined");
      fail;
    }
    writeLine ("stdout", "Resource *Res exists in local zone $rodsZoneClient");
  }
}
createLogFile (*Coll, *Sub, *Name, *Res, *LPath, *Lfile, *L_FD) {
# Create a log sub-directory within *Coll if it is missing
# Create a timestamped log file with the input file name *Name
  msiGetSystemTime(*TimeH,"human");
#============ create a collection for log files if it does not exist ===============
  *LPath = "*Coll/*Sub";
  isColl (*LPath, "stdout", *Status);
  if (*Status < 0) { fail;}
#============ create file into which results will be written =========================
  *Lfile = "*LPath/*Name-*TimeH";
  *Dfile = "destRescName=*Res++++forceFlag=";
  msiDataObjCreate(*Lfile, *Dfile, *L_FD);
}
isColl (*LPath, *Lfile, *Status) {
  *Status = 0;
  *Query0 = select count(COLL_ID) where COLL_NAME = '*LPath';
  foreach(*Row0 in *Query0) {*Result = *Row0.COLL_ID;}
  if(*Result == "0" ) {
    writeLine("stdout","Creating colleciton *LPath");
    msiCollCreate(*LPath, "1", *Status);
    if(*Status < 0) {
      writeLine("*Lfile","Could not create *LPath collection");
    }  # end of check on status
  }  # end of log collection creation
}
selectRescUpdate (*Rlist, *Ulist, *Num, *Resource) {
# from list of resources *Rlist select a good copy *Ulist as source
  for(*J=0;*J<*Num;*J=*J+1) {
    if(elem(*Ulist,*J) == "1") {
      *Resource = elem(*Rlist,*J);
      break;
    }  # end of selection of resource with valid copy
  }  # end of loop over all resources
}
createReplicas (*N, *Numrepl, *Lfile, *Ulist, *Rlist, *Jround, *Resource, *Coll, *File, *NumRepCreated) {
# create *N replicas for file *Coll/*File
# good replicas are in *Ulist
# good replica is in *Resource
# write actions to *Lfile
  if(*N > 0) {
    writeLine("*Lfile","File *Coll/*File is missing *N replicas");
    for(*I = 0;*I<*N;*I=*I+1) {
#==pick resource to use for storing replica, round robin through storage systems without a replica ==
      *Check = false;
      *Loop = 0;
      for(*L = 0;*L<*Numrepl;*L=*L+1) {
        *Loop = *Loop + 1;
        if(*Loop >= 3) {
          break;
        }
        *J = *L + *Jround;
        if(*J >= *Numrepl) {
          *J = *J - *Numrepl;
        }  # end of reset of start location for load leveling
        *Stu = elem(*Ulist,*J);
        if(*Stu == "0") {
          *Resu = elem(*Rlist,*J);
          writeLine ("*Lfile", "Replicate from *Resource to *Resu");
          msiDataObjRepl("*Coll/*File","destRescName=*Resu++++rescName=*Resource",*Status1);
          *NumRepCreated = *NumRepCreated + 1;
          *Ulist = setelem(*Ulist,*J,"1");
          *Check = true;
          *Jround = *J + 1;
          if(*Jround >= *Numrepl) {
            *Jround = 0;
          }  # end of reset of start location for load leveling
          if(*Status1 < 0) {
            *NumRepCreated = *NumRepCreated - 1;
            writeLine("*Lfile","Unable to create a replica for *Coll/*File on resource *Resu");
            *Check = false;
          }  # end of decrement of error check for creating replica
        }  # end of creation of a new replica
        if(*Check == true) {
          break;
        }  # end of test that were able to create a replica
      }  # end of loop over storage resources
    }  # end of loop over number of replicas to create
  }  # end of check that additional replicas are needed
}

getRescLim (*Rlist, *Ulist, *Resc1, *Resc2, *Num) {
# initialize a user list *Ulist to 0
  *Num = 2;
  *Rlist = list(*Resc1, *Resc2);
  *Ulist = list("0","0");
}
INPUT *Numrep =$2, *Rescweb ="diamond-mso1", *Resc1 =$"lifelibResc1", *Resc2 =$"renci-unix1"
OUTPUT ruleExecOut
