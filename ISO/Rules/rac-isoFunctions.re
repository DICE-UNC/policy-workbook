addAVUMetadata (*Path, *Attname, *Attvalue, *Aunit, *Status) {
# this overrides existing metadata
  *Status = "1";
# using micro-service from iPlant Collaborative
  msiSetAVU("-d", *Path, *Attname, *Attvalue, *Aunit);
  *Status = "0";
}

addAVUMetadataToColl(*Coll, *Attname, *Attvalue, *Attunit, *Status) {
# add metadata to a collection
# this overrides existing metadata
  *Status = "1";
# using micro-service from iPlant Collaborative
  msiSetAVU("-C", *Coll, *Attname, *Attvalue, *Attunit);
  *Status = "0";
}

addToList(*Name, *Usage, *Listnam, *Listuse, *Min, *Num) {
# insert new usage in list keeping top 10
  *S = 0;
  for (*I=0;*I<*Num;*I=*I+1) {
    *Val = elem(*Listuse,*I);
    *Use = double(*Val);
    if (*Use < *Usage) {
      for (*J=*Num-1;*J>*I;*J=*J-1) {
        *Jm1 = *J-1;
        *Use1 = elem(*Listuse,*Jm1);
        *Nam1 = elem(*Listnam,*Jm1);
        *Listuse = setelem(*Listuse,*J,*Use1);
        *Listnam = setelem(*Listnam,*J,*Nam1);
      }
      *Listuse = setelem(*Listuse,*I,str(*Usage));
      *Listnam = setelem(*Listnam,*I,*Name);
      *S = 1;
    }
    if (*S == 1) {break;}
  }  
  *Min = double(elem(*Listuse,*Num-1));
}

checkCollInput(*Coll) {
# check whether *Coll is a collection
# fail if not a collection
  *Q = select count(COLL_ID) where COLL_NAME = '*Coll';
  foreach (*R in *Q) {*Result = *R.COLL_ID;}
  if(*Result == "0" ) {
    writeLine("stdout","Input path *Coll is not a collection");
    fail;
  }
}
 
checkFileInput(*File) {
# check whether *File is a file
# fail if not a file
  *Q = select count(DATA_ID) where DATA_NAME = '*File';
  foreach (*R in *Q) {*Result = *R.DATA_ID;}
  if(*Result == "0" ) {
    writeLine("stdout","Input *File is not a file");
    fail;
  }
}

checkMetaExistsColl (*Attname, *Coll, *Lfile, *Value) {
# create metadata attribute on collection *Coll if it does not exist and initialize to 0
# log creation event to a logfile *Lfile
# return either 0 or prior value
  *Val = "0";
  *Query1 = SELECT COUNT(META_COLL_ATTR_NAME) where COLL_NAME = '*Coll' and META_COLL_ATTR_NAME = '*Attname';
  foreach (*Row1 in *Query1) {
    *Val = *Row1.META_COLL_ATTR_NAME;
  }  # end of loop to count number of TEST_DATA_ID values
  if(int(*Val) == 0) {
    addAVUMetadataToColl(*Coll, *Attname, "0", "", *Status);
    writeLine("*Lfile","added TEST_DATA_ID attribute to collection *Coll");
  }  # end of creation of initial value for *Attname
  *Query2 = select META_COLL_ATTR_VALUE where COLL_NAME = '*Coll' and META_COLL_ATTR_NAME = '*Attname';
  foreach(*Row2 in *Query2) {
    *Value = *Row2.META_COLL_ATTR_VALUE;
  }  # end of retrieval of *colldataID
}

checkPathInput(*Path) {
# check whether *Path is a valid path
# fail if not a valid path 
  msiSplitPath (*Path, *Coll, *File);
  *Q = select count(DATA_ID) where DATA_NAME = '*File' and COLL_NAME = '*Coll';
  foreach (*R in *Q) {*Result = *R.DATA_ID;}
  if(*Result == "0" ) {
    writeLine("stdout","Input *Path is not a valid path");
    fail;
  }
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
 
checkUserInput (*User, *Zone) {
# $rodsZoneClient is defined by your irods_environment file
  if ($rodsZoneClient != *Zone) {
    findZoneHostName (*Zone, *Host, *Port);
    remote (*Host, "<ZONE>*Zone</ZONE>") {
      *Q = select count(USER_ID) where USER_NAME = '*User' and USER_ZONE = '$rodsZoneClient';
      foreach(*R in *Q) { *Result = *R.USER_ID;}
      if (*Result == "0") {
        writeLine ("stdout","*User#$rodsZoneClient is not a user in zone *Zone");
        fail;
      }
      writeLine ("stdout", "*User is a user in zone *Zone");
    }
  }
  else {
    *Q1 = select count(USER_ID) where USER_NAME = '*User' and USER_ZONE = '$rodsZoneClient';
    foreach (*R1 in *Q1) { *Result = *R1.USER_ID;}
    if (*Result == "0") {
      writeLine ("stdout", "*User is not a user in zone $rodsZoneClient");
      fail;
    }
    writeLine ("stdout", "*User is a user in zone $rodsZoneClient");
  }
}

checkZoneInput (*Zone) {
  *Q1 = select count(ZONE_ID) where ZONE_NAME = '*Zone';
  foreach (*R1 in *Q1) {*n = *R1.ZONE_ID;}
  if (*n == "0") {
    writeLine ("stdout", "Remote zone *Zone is not federated");
    fail;
  }
}

contains(*list, *elem) {
    *ret = false;
    foreach(*e in *list) {
        if(*e == *elem) {
            *ret = true;
        }
    }
    *ret;
}

createCollections(*coll, *cs) {
    foreach(*c in *cs) {
        msiCollCreate("*coll/*c", "1", *status);
    }
}

createList(*Lista, *Num, *Val) {
# create a list with default values *Val
  *Lista = list(*Val);
  for (*I=1;*I<*Num;*I=*I+1) {
    *Lista = cons(*Val, *Lista);
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

createManifest (*Coll, *Manifest, *Res, *Lfile, *L_FD) {
# test-createManifest.r
# open and seek to end of manifest file
# *Coll is a collection holding the manifest file
# *Manifest is the name of the manifest file
  isColl (*Coll, "serverLog", *Stat);
  isData (*Coll, *Manifest, *Status);
  *Lfile = "*Coll/*Manifest";
  if (*Status == "0") {
# create manifest file
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
  } else {
    msiDataObjOpen("objPath=*Lfile", *L_FD);
  }
  msiDataObjLseek (*L_FD, "0", "SEEK_END", *Status);
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
 
deleteAVUMetadata (*Path, *Attname, *Attvalue, *AUnit, *Status) {
  *Str = "*Attname=*Attvalue";
  msiString2KeyValPair(*Str, *Keyval)
  msiRemoveKeyValuePairsFromObj (*Keyval, *Path, "-d");
}

ext(*p) {
    *b = trimr(*p, ".");
    *ext = if *b == *p then "no ext" else substr(*p, strlen(*b)+1, strlen(*p));
    *ext;
}

findZoneHostName (*Zone, *Host, *Port) {
  *Q1 = select ZONE_CONNECTION where ZONE_NAME = '*Zone';
  foreach (*R1 in *Q1) {
    *Conn = *R1.ZONE_CONNECTION;
    msiSplitPathByKey (*Conn, ":", *Host, *Port);
  }
}

getCollections(*filePaths) {
# Form a list of directories extracted from the list filePaths
# filePaths is the array or list of all the files under the localRoot
    *cs = list();
    foreach(*p in *filePaths) {
        # Trim everything to the right of "/" to get the
        # directory name.
        *p2 = trimr(*p, "/");

        # Get the directory *p2 is not in the list *cs, add it as the 1st element
        if(!contains(*cs, *p2) && *p != *p2) {
            *cs = cons(*p2, *cs);
            #writeLine("stdout", ">>>>>> cs = *cs \n");
        }
    }
    *cs;
}

getFiles(*localRoot, *localPaths) {
# Construct a list *cs which finds file name by stripping *localRoot from list of *localPaths
    *cs = list();
    *localRootLen = strlen(*localRoot) + 1;
    foreach(*p in *localPaths) {
        # use substr to chop off first *localRootLen from the absolute
        # path of the file - to get the next level of directory.
        *p1 = substr(*p, *localRootLen, strlen(*p));

        # Concatenate *p1 to the list *cs by adding it as its first element
        *cs = cons(*p1, *cs);

    }
    *cs;
}

getNumSizeColl (*Coll, *colldataID, *Size, *Num) {
# Only process files with DATA_ID > *colldataID
# Generate number and size
#======== *colldataID is the string identifier of the last file that has been checked =========
   *q1 = select count(DATA_NAME), sum(DATA_SIZE) where COLL_NAME like '*Coll%' and DATA_ID >= '*colldataID';
#========= this counts all files that have not yet been checked including replicas =============
  foreach(*r1 in *q1) {
    *num = *r1.DATA_NAME;
    *sizetotal = *r1.DATA_SIZE;
  }  # end of retrieval of number and size
  *Size = double(*sizetotal);
  *Num = int(*num);
}

getRescColl (*Coll, *Rlist, *Ulist, *Lfile, *Num) {
# generate a list of replicas *Rlist used by collection *Coll
# initialize a user list *Ulist to 0
# write resource names to log file *Lfile
#============ use resources at which any files in the collection were stored =========
  *Query3 = select order_asc(DATA_RESC_NAME) where COLL_NAME like '*Coll%';
  *Num = 0;
  *Rlist = list();
  *Ulist = list();
  foreach (*R3 in *Query3) {
    *Str1 = *R3.DATA_RESC_NAME;
    *Rlist = cons(*Str1,*Rlist);
    *Ulist = cons("0",*Ulist);
    writeLine("*Lfile","Collection *Coll uses storage resource *Str1");
    *Num = *Num + 1;
  }  # end of set up of list of resources
}
 
isColl (*LPath, *Lfile, *Status) {
  *Status = 0;
  *Query0 = select count(COLL_ID) where COLL_NAME = '*LPath';
  foreach(*Row0 in *Query0) {*Result = *Row0.COLL_ID;}
  if(*Result == "0" ) {
    msiCollCreate(*LPath, "1", *Status);
    if(*Status < 0) {
      writeLine("*Lfile","Could not create *LPath collection");
    }  # end of check on status
  }  # end of log collection creation
}

isData (*Coll, *File, *Status) {
# Check whether a file already exists
  *Q = select count(DATA_ID) where COLL_NAME = '*Coll' and DATA_NAME = '*File';
  foreach (*R in *Q) {
    *Status = *R.DATA_ID;
  }
  *Status;
}

join_list(*l1, *l2) {
  if (size(*l1) == 0) then { *l2; }
  else { cons(hd(*l1),join_list(tl(*l1), *l2)); }
}

modAVUMetadata (*Path, *Attname, *Attvalue, *Aunit, *Status) {
# delete the original attribute value and add the new value to a file
  msiSplitPath (*Path, *Coll, *File);
  *Q1 = select META_DATA_ATTR_VALUE, META_DATA_ATTR_UNITS where DATA_NAME = '*File' and COLL_NAME = '*Coll' and META_DATA_ATTR_NAME = '*Attname';
  foreach (*R1 in *Q1) { 
    *Avorig = *R1.META_DATA_ATTR_VALUE;
    *Auorig = *R1.META_DATA_ATTR_UNITS;
  }
  deleteAVUMetadata (*Path, *Attname, *Avorig, *Auorig, *Status);
  addAVUMetadata (*Path, *Attname, *Attvalue, *Aunit, *Status)
}

racCheckArchive (*Archive, *Stat) {
# check whether a valid archive is specified
  *Coll = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
  *Q1 = select count(META_COLL_ATTR_ID) where COLL_NAME = *Coll and META_COLL_ATTR_NAME = "Repository-Archives" and META_COLL_ATTR_VALUE = *Archive;
  *Stat = "1";
  foreach (*R1 in *Q1) { *Num = *R1.META_COLL_ATTR_ID; }
  if (*Num >= "1") {*Stat = "0"; }
}

racCheckMsg (*Msg, *Msgt) {
# transform message to remove all minus signs
  *L = strlen(*Msg);
  *J = 0;
  *Msgt = "";
  for (*I=0; *I<*L; *I=*I+1) {
    *M = substr(*Msg, *I, *I+1)
    if (*M != "-" && *M != "_" && *M != ":") {
      *Msgt = *Msgt ++ *M;
    } else {
      *Msgt = *Msgt ++ " ";
    }
  }
}

racCheckNumReplicas (*Res, *Num) {
# Policy function to determine how many replicas will be made by a resource
  *File = "racchecknumreplica234";
  *Coll = GLOBAL_ACCOUNT;
  *Path = "*Coll/*File";
  *Flags = "destRescName=*Res++++forceFlag=";
  *Num = "0";
  msiDataObjCreate (*Path, *Flags, *FD);
  msiDataObjWrite(*FD, "1", *Len);
  msiDataObjClose (*FD, *Stat);
  *Q1 = select count(DATA_REPL_NUM) where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) { *Num = *R1.DATA_REPL_NUM; }
  *Flagd = "objPath=*Path";
  msiDataObjUnlink (*Flagd, *Status);
}

racDupCheck (*File, *Coll, *Archive, *S8) {
# Policy function to check whether AIP already exists
# AIPs are stored in GLOBAL_ACCOUNT/*Archive/GLOBAL_AIPS
  msiGetSystemTime (*Tim, "human");
  *Ca = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_AIPS;
  *S8 = "0";
  *Q1 = select count (DATA_NAME) where DATA_NAME = *File and COLL_NAME = *Ca;
  foreach (*R1 in *Q1 ) {
    *Num = *R1.DATA_NAME;
    if (*Num == "0") {
      *S8 = "1";
    }
  }
  if (*S8 != "1" ) { *S8 = "2"; }
  addAVUMetadata ("*Coll/*File", "Audit-CheckDup", *S8, *Tim, *Stat);
}

racFindRepColl (*File, *Rep) {
# find the collection that houses a report
# input parameter is the name of the report that is checked
# list of reports that are not archive specific and are manifests
  *List1 = list("DIRA", "ERR", "NPRA", "PL", "RAA", "RCA", "SEA");
# list of reports that are archive specific and are manifests
  *List3 = list("AIPCRA", "ALRA", "BDA", "INTA", "IPA", "PAA", "SIA", "SIPCRA");
  *Listg1 = join_list(*List1, *List3);
# determine which collection holds the report
  *Rep = GLOBAL_REPORTS;
  splitPathByKey(*File, ".", *Head, *End);
  foreach (*R in *Listg1) {
    *Tf = "Archive-" ++ *R;
    if (*Tf == *Head) {
      *Rep = GLOBAL_MANIFESTS;
      break;
    }
  }
}

racFindRep (*Coll, *Rep) {
# policy function to identify the repository referenced by the path name
  *Colla = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY ++ "/" ++ GLOBAL_REPORTS;
  *Rep = "";
  if (*Coll == *Colla) { *Rep = GLOBAL_REPOSITORY; }
  else {
    *Colt = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
    *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *Colt and META_COLL_ATTR_NAME = "Repository-Archives"
    foreach (*R1 in *Q1) {
      *Nam = *R1.META_COLL_ATTR_VALUE;
      *C = GLOBAL_ACCOUNT ++ "/*Nam/" ++ GLOBAL_REPORTS;
      if (*Coll == *C) {
        *Rep = *Nam;
        break;
      }
    }
  }
}
 
racFormatCheck (*File, *Coll, *Archive, *S4) {
# Policy function to check the format of a SIP
# Required format type is Archive-Format saved as an attribute on GLOBAL_SIPS
  *S4 = "0";
  *F = "";
  msiGetSystemTime (*Tim, "human");
  *Q0 = select DATA_TYPE_NAME where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R0 in *Q0) {  *F = *R0.DATA_TYPE_NAME; }
  if (*F == "") {
    splitPathByKey (*File, ".", *Head, *F);
  }
  *C = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *C and META_COLL_ATTR_NAME = "Archive-Format";
  foreach (*R1 in *Q1) {
    *Form = *R1.META_COLL_ATTR_VALUE;
    if (*Form == *F) {
      *S4 = "1";
      break;
    }
  }
  if (*S4 != "1") { *S4 = "2"; }
  addAVUMetadata ("*Coll/*File", "Audit-CheckFormat", *S4, *Tim, *Stat);
}
racGetAVUMetadata (*Archive, *Coll, *Name, *Cont, *Val) {
# policy function to verify existence and retrieve attribute from a collection
# send e-mail if attribute is missing
# *Cont = "1" if notification is required for missing attribute
  *Val = "";
  *Q1 = select count(META_COLL_ATTR_VALUE) where COLL_NAME = *Coll and META_COLL_ATTR_NAME = *Name;
  foreach (*R1 in *Q1) { *Num = *R1.META_COLL_ATTR_VALUE; }
  if (*Num > "0") {
    *Q2 = select META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_NAME = *Name;
    foreach (*R2 in *Q2) { *Val = *R2.META_COLL_ATTR_VALUE; }
  } else {
    if (*Cont == "1") {
      writeLine ("stdout", "Did not find required metadata");
      racNotify (*Archive, "Missing *Name attribute on *Coll");
    }
  }
} 
 
racGlobalSet = maing
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_DIPS = "DIPS"
GLOBAL_EMAIL = "rwmoore@renci.org"
GLOBAL_IMAGES = "Images"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_METADATA = "Metadata"
GLOBAL_OWNER = "rwmoore"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_RULES = "Rules"
GLOBAL_SIPS = "SIPS"
GLOBAL_STORAGE = "LTLResc"
GLOBAL_VERSIONS = "Versions"
maing{}

racIntegrityCheck (*File, *Coll, *Archive, *S7) {
#  Policy function to check integrity of a SIP
  *Chk = "";
  *Q1 = select DATA_CHECKSUM where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) { *Chk = *R1.DATA_CHECKSUM; }
  msiDataObjChksum ("*Coll/*File", "forceChksum=", *Chksum);
  if (*Chk != *Chksum) { *S7 = "1"; }
  else {
    *S7 = "2";
  }
  addAVUMetadata ("*Coll/*File", "Audit-CheckIntegrity", *S7, *Tim, *Stat);
}

racMetadataCheck (*File, *Coll, *Archive, *S5) {
# Policy function to check SIP has required metadata
# Required metadata are stored as attributes on GLOBAL_ACCOUNT/*Archive/GLOBAL_SIPS
  msiGetSystemTime (*Tim, "human");
  *S5 = "0";
  *Q1 = select META_COLL_ATTR_NAME, META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_VALUE = "RequiredSIP";
  foreach (*R1 in *Q1 ) {
    *Name = *R1.META_COLL_ATTR_NAME;
# check presence of metadata attribute on the SIP
    *Q2 = select count(META_DATA_ATTR_NAME) where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = *Name;
    foreach (*R2 in *Q2) {
      *Num = *R2.META_DATA_ATTR_NAME;
      if (*Num == "0") {
        *S5 = "1";
        break;
      }
    }
  }
  if (*S5 != "1" ) { *S5 = "2"; }
    addAVUMetadata ("*Coll/*File", "Audit-CheckMetadata", *S5, *Tim, *Stat);
}

racNotify (*Archive, *Msg) {
# Policy function to send notification
# Email address is given by value of Archive-Email on GLOBAL_ACCOUNT/*Archive
  racCheckMsg(*Msg, *Msgt);
  msiGetSystemTime (*Tim, "human");
  *Body = "Please set attribute Archive-Email on *Archive";
  *Col = GLOBAL_ACCOUNT ++ "/*Archive";
  *Q1 = select count(META_COLL_ATTR_VALUE) where COLL_NAME = *Col and META_COLL_ATTR_NAME = "Archive-Email";
  foreach (*R1 in *Q1) { *Num = *R1.META_COLL_ATTR_VALUE; }
  if (*Num == "0") {
# notify the repository administrator that the Archive-Email address is missing
    *C = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
    *Q2 = select META_COLL_ATTR_VALUE where COLL_NAME = *C and META_COLL_ATTR_NAME = "Repository-Email";
    foreach (*R2 in *Q2) { *Add = *R2.META_COLL_ATTR_VALUE; }
    msiSendMail (*Add, "Response required, missing metadata", *Body);
    *Note = "Sent message about Missing metadata to *Add about *Body on *Tim";
    writeLine ("stdout", "  *Note");
  } else {
    *Q3 = select META_COLL_ATTR_VALUE where COLL_NAME = *Col and META_COLL_ATTR_NAME = "Archive-Email";
    *Note = "";
    foreach (*R3 in *Q3) {
      *Add = *R3.META_COLL_ATTR_VALUE;
      *Note = *Note ++ "Sent message to *Add about *Msg on *Tim\n";
      msiSendStdoutAsEmail (*Add, *Msgt);
    }
    writeLine ("stdout", "  *Note");
  }
# log all notifications in Archive-PAA
  racWriteManifest ("Archive-PAA", *Archive, *Note);
}

racProtectedDataCheck (*Files, *Coll, *Archive, *S3) {
# policy function to check for PII, PHI, PCI using Bitcurator
# expects a working directory, currently /tmp/bcworking specified below,
# to exist and be writable by the user running the script.
  *outFeatDir= GLOBAL_ACCOUNT ++ "/*Archive/tmp";
  *S3 = "0";
  isColl (*outFeatDir, "status", *Stat);
  *Report="BulkExtractor";
  *Col = GLOBAL_ACCOUNT ++ "/*Archive";
  *Q1 = select count(META_COLL_ATTR_VALUE) where COLL_NAME = *Col and META_COLL_ATTR_NAME = "Archive-Email";
  foreach (*R1 in *Q1) { *Num = *R1.META_COLL_ATTR_VALUE; }
  if (*Num == "0") {
# notify the repository administrator that the Archive-Email address is missing
    *C = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
    *Q2 = select META_COLL_ATTR_VALUE where COLL_NAME = *C and META_COLL_ATTR_NAME = "Repository-Email";
    foreach (*R2 in *Q2) { *Add = *R2.META_COLL_ATTR_VALUE; }
    msiSendMail (*Add, "Response required, missing metadata", *Body);
    writeLine ("stdout", "Missing metadata for Archive-Email on *Col");
    fail;
  } else {
    *Q3 = select META_COLL_ATTR_VALUE where COLL_NAME = *Col and META_COLL_ATTR_NAME = "Archive-Email";
    foreach (*R3 in *Q3) {
      *Archivist = *R3.META_COLL_ATTR_VALUE;
    }
  }
  *Cmd="bulk_extractor";
  *timeStamp = double (time());
# Make a query to get the path to the image and the resource name
# DATA_PATH: Physical path name for digital object in resource
# DATA_RESC_NAME: Logical name of storage resource
  *Query = select DATA_NAME,DATA_REPL_NUM, DATA_PATH,DATA_RESC_NAME,COLL_NAME where COLL_NAME = '*Coll' and DATA_NAME = *Files;
  foreach (*row in *Query) {
    *Repn = *row.DATA_REPL_NUM;
    if (*Repn == "0") {
      *Path = *row.DATA_PATH;
      *CollPath = *row.COLL_NAME;
      *Resource = *row.DATA_RESC_NAME;
      *File = *row.DATA_NAME
# Make another query for IP Address of the resource
# RESC_LOC: Resource IP Address
# DATA_RESC_NAME: Logical name of storage resource
      *Query2 = select RESC_LOC where DATA_RESC_NAME = '*Resource';
      foreach (*row in *Query2) {
        *Addr = *row.RESC_LOC;
      }
      *prefixStr = "*File";
      *tempStr = "/tmp/bcworking/*prefixStr" ++ "outFeatDir";
      *Arg1 = execCmdArg(*Path);    # Image
      *Arg2 = execCmdArg("-o");
      *Arg3 = execCmdArg(*tempStr); # Output Feature Directory
      if (errorcode(msiExecCmd(*Cmd,"*Arg1 *Arg2 *Arg3","null","null","null",*Result)) < 0) {
          if(errormsg(*Result,*msg)==0) {
              msiGetStderrInExecCmdOut(*Result,*Out);
          }
      } else {
# Command executed successfully
        msiGetStdoutInExecCmdOut(*Result,*Out);
# run shell script to list iRODS path to files suspected to contain PII or CCN
        msiExecCmd("list_suspected_sensitive.sh", *s1, "null", "null", "null", *SResult);
        msiGetStdoutInExecCmdOut(*SResult, *Out);
        *s = split(*Out, "\n");
        writeLine("stdout", "Debug: Suspected sensitive files: *s");
        foreach (*item in *s) {
          addAVUMetadata(*item, "CURATOR_REVIEW", "Sensitive", "*timeStamp", *Status);
          addAVUMetadata (*item, "Audit-CheckProtected", "1", "*timeStamp", *Status);
          *S3 == "1";
        }
# remove working subdirectories
        remote(*Addr, "null") {
          msiExecCmd("tmpCleanup.sh", "null", "null", "null", "null", *Result);
        }
      }
    }
  }
  if (*S3 != "1") { 
    *S3 = "2";
    addAVUMetadata ("*Coll/*Files", "Audit-CheckProtected", "2", "*timeStamp", *Status);
  }
}

racReservedVocabCheck (*File, *Coll, *Archive, *S6) {
# Policy function to verify descriptive metadata against reserved vocabulary
  msiGetSystemTime (*Tim, "human");
  *S6 = "0";
  *Q0 = select count(META_DATA_ATTR_VALUE) where COLL_NAME = '*Coll' and DATA_NAME = '*File' and META_DATA_ATTR_NAME = "Archive-Description";
  foreach (*R0 in *Q0) { *Num = *R0.META_DATA_ATTR_VALUE; }
  if (*Num == "0") {
    *S6 = "1";
  } else {
    foreach(*R4 in *Q4) {
      *Str = *R4.META_DATA_ATTR_VALUE;
      split (*Str, *L);
      foreach (*S in *L) {
        msiCurlUrlEncodeString(*S, *encodedUrl);
        *url = "http://localhost:8080/hive-voccabservice-rest-1.0-SNAPSHOT/rest/concept/uat/concept?uri=" ++  str(*encodedUrl);
        msiCurlGetStr(*url, *outStr);
        if (*outStr like "\*DataNotFoundException\*") { *S6 = "1"; }
      }
    }
  }
  if (*S6 != "1") { *S6 = "2"; }
  addAVUMetadata ("*Coll/*File", "Audit-CheckVocab", *S6, *Tim, *Status);
}

racSaveFile (*File, *Rep) {
# policy function to write standard out to *File in collection GLOBAL_REPORTS
  *Colh = GLOBAL_ACCOUNT ++ "/*Rep";
  *Coll = "*Colh/" ++ GLOBAL_REPORTS;
  *Path = "*Coll/*File";
  *Res = GLOBAL_STORAGE;
  *Per = GLOBAL_OWNER;
  isColl (*Coll, "stdout", *Status);
  *DesColl = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_VERSIONS;
  isColl (*DesColl, "stdout", *Status);
  *Flags = "destRescName=*Res++++forceFlag=";
# overwrite existing file
  msiDataObjCreate(*Path, *Flags, *L_FD);
  msiDataObjWrite(*L_FD, "stdout", *Wlen);
  msiDataObjClose(*L_FD, *Status);
  msiFreeBuffer ("stdout");
  msiDataObjRepl(*Path, "updateRepl=++++verifyChksum=", *Stat);
  msiSetACL("default", "own", *Per, *Path);
# add attribute for Audit-Date to the file
  msiGetSystemTime (*Tim, "unix");
# check that Archive-Report is defined on collection
  racVerifyAuditReport (*Colh, *Rep, *Tim);
# set the Audit-Date on a file
  racSetAuditDateFile (*File, *Rep, *Colh, *Coll, *Tim);
# Copy report into Reports/Versions and increment the version number
  racVersionFile (*File, *Rep, *Coll);
}

racSetAuditDateFile (*File, *Rep, *Colh, *Coll, *Tim) {
# policy function to set the Audit-Date attribute on a file
  *Path = "*Coll/*File";
  *Att = "Archive-Report";
  if (*Rep == GLOBAL_REPOSITORY) { *Att = "Repository-Report"; }
  *Q4 = select META_COLL_ATTR_VALUE where COLL_NAME = *Colh and META_COLL_ATTR_NAME = *Att;
  foreach (*R4 in *Q4) {*P = *R4.META_COLL_ATTR_VALUE;}
  *T = str (double (*Tim) + double(*P));
# check that no metadata exists on file for 'Audit-Date'
  *Q5 = select count (META_DATA_ATTR_ID) where COLL_NAME = *Coll and DATA_NAME = *File and META_DATA_ATTR_NAME
 = 'Audit-Date';
  foreach (*R5 in *Q5) { *N = *R5.META_DATA_ATTR_ID; }
  if (*N != "0" ) {
    *Q6 = select META_DATA_ATTR_VALUE, META_DATA_ATTR_UNITS where COLL_NAME = *Coll and DATA_NAME = *File and
META_DATA_ATTR_NAME = 'Audit-Date';
    foreach (*R6 in *Q6) {
      *V = *R6.META_DATA_ATTR_VALUE;
      *U = *R6.META_DATA_ATTR_UNITS;
      deleteAVUMetadata (*Path, "Audit-Date", *V, *U, *Status);
    }
# no delete of Audit-Date from versioned file is needed since copy does not copy metadata.
  }
  addAVUMetadata (*Path, "Audit-Date", *T, "", *Stat);
}

racSplitArchive (*Coll, *Archive) {
# find the name of an archive in a collection path
  *Head = GLOBAL_ACCOUNT ++ "/";
  *La = strlen (*Head);
  *Lc = strlen (*Coll);
  *Archive = "";
  for (*I = *La; *I < *Lc; *I=*I+1) {
    *C = substr (*Coll, *I, *I+1);
    if (*C == "/") {
      *Archive = substr (*Coll, *La, *I);
      break;
    }
  }
# verify the name is correct
  *Coll = *Head ++ GLOBAL_REPOSITORY;
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_NAME = "Repository-Archives";
  *Found = 0;
  foreach (*R1 in *Q1) {
    *Nam = *R1.META_COLL_ATTR_VALUE;
    if (*Nam == *Archive) {
      *Found = 1;
      break;
    }
  }
  if (*Found == 0) { *Archive = ""; }
}

racVerifyAuditReport (*Coll, *Rep, *Tim) {
# policy function to check that Archive-Report is defined on collection *Coll
  *Period = str (int(GLOBAL_AUDIT_PERIOD) * 86400);
  *Att = "Archive-Report";
  if (*Rep == GLOBAL_REPOSITORY) { *Att = "Repository-Report"; }
  *Q3 = select count(META_COLL_ATTR_ID) where COLL_NAME = *Coll and META_COLL_ATTR_NAME = *Att;
  foreach (*R3 in *Q3) {*Num1 = *R3.META_COLL_ATTR_ID;}
  if (*Num1 == "0" ) {
# add default update period to collection
    addAVUMetadataToColl (*Coll, *Att, *Period, "", *Stat);
  }
}

racVersionFile (*File, *Rep, *Coll) {
# policy function to version a file
  *Path = "*Coll/*File";
  *DesColl = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_VERSIONS;
  *err = errorcode(msiCollCreate(*DesColl, "1", *status));
# Copy report into Versions and increment the version number
  *Q2 = select DATA_NAME where COLL_NAME = '*DesColl' and DATA_NAME like '*File..%';
  *Num = 0;
  foreach (*R2 in *Q2) {
    *Ver = *R2.DATA_NAME;
    *Vend = int(substr(*Ver, strlen(*File)+2, strlen(*Ver)));
    if (*Vend > *Num) {*Num = *Vend;}
  }
  *Numinc = *Num + 1;
  *Vers = *File ++ ".." ++ "*Numinc";
  *Pathver = *DesColl ++ "/" ++ *Vers;
  msiDataObjCopy(*Path, *Pathver, "verifyChksum=", *Status);
  msiDataObjRepl(*Pathver, "updateRepl=++++verifyChksum=", *Stat);
  *Per = GLOBAL_OWNER;
  msiSetACL("default", "own", *Per, *Pathver);
}

racVirusCheck (*File, *Coll, *S2) {
# policy function to evaluate a file for viruses
# use clamscan to check for viruses
  *Path = "*Coll/*File";
  *Res = GLOBAL_STORAGE;
  *S2 = "0";
  *Q1 = select DATA_PATH where DATA_NAME = '*File' and COLL_NAME = '*Coll';
  foreach (*R1 in *Q1) {*Objpath = *R1.DATA_PATH;}
  *Val = "0";
  *Text = "Passed Virus";
  *Name = "Audit-CheckVirus";
  acScanFileAndFlagObject (*Objpath, *Path, *Res);
  *Q2 = select count(META_DATA_ATTR_NAME) where DATA_NAME = '*File' and COLL_NAME = '*Coll' and META_DATA_ATTR_NAME like 'VIRUS_SCAN_PASSED%';
  foreach (*R2 in *Q2) {
    *Num = *R2.META_DATA_ATTR_NAME;
    if ( *Num == "0") { 
      *Val = "1"; 
      *Text = "Failed Virus";
      *S2 = "1";
    }
  }
  if (*S2 != "1") {*S2 = "2";}
  addAVUMetadata (*Path, *Name, *Val, *Text, *Stat);
}
 
racWriteManifest( *OutFile, *Rep, *Source ) {
# create manifest file
  *Coll = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_MANIFESTS;
  *Res = GLOBAL_STORAGE;
  isColl (*Coll, "stdout", *Status);
  isData (*Coll, *OutFile, *Status);
  *Lfile = "*Coll/*OutFile";
  if (*Status == "0") {
# create manifest file
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
    msiDataObjClose (*L_FD, *Status);
  }
# update manifest file with information from *Source
  msiDataObjOpen("objPath=*Lfile++++openFlags=O_RDWR", *L_FD);
  msiDataObjLseek(*L_FD, "0", "SEEK_END", *Status);
  msiDataObjWrite(*L_FD, *Source, *Wlen);
  msiDataObjClose(*L_FD, *Status);
  msiDataObjRepl(*Lfile, "updateRepl=++++verifyChksum=", *Stat);
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
 
sendAccess (*AccessType, *UserName, *DataId, *DataType, *Time, *Description, *eventOutcome, *host, *queue) {
# acsendAccess.r
  *AccessId = jsonEncode(genAccessId(*AccessType, *UserName, *DataId, *Time, *Description));
  *UserNameJson = jsonEncode(*UserName);
  *DescriptionJson = jsonEncode(*Description);
  *DataIdJson = jsonEncode(*DataId);
  *eventOutcomeJson = jsonEncode(*eventOutcome);
  *msg='
    {
      "messages" : [ {
        "operation" : "create",
        "type" : "Event",
        "eventIdentifier" : {
          "eventIdentifierType": "URI",
          "eventIdentifierValue": "*AccessId"
        },
        "eventType": "*AccessType",
        "eventDateTime": "*Time",
        "linkingAgentIdentifier" : [
          {
            "linkingAgentIdentifierType" : "uri",
            "linkingAgentIdentifierValue" : "*UserNameJson"
          }
        ],
      "linkingObjectIdentifier" : [
        {
          "linkingObjectIdentifierType" : "uri",
          "linkingObjectIdentifierValue" : "*DataIdJson"
        }
      ],
      "eventDetail" : "*DescriptionJson",
      "eventOutcomeInformation" : "*eventOutcomeJson"
      } ]
    }';
    amqpSend(*host, *queue, *msg);
    *AccessId;
}

sendLinkingEvent (*DataId, *AccessId, *host, *queue) {
# aclinkEvent.r
  *DataIdJson = jsonEncode(*DataId);
  *msg='
  {
    "messages" : [ {
        "operation" : "union",
        "objectIdentifierType": "URI",
        "objectIdentifierValue": "*DataIdJson",
        "linkingEventIdentifierType": "URI",
        "linkingEventIdentifierValue": "*AccessId"
    } ]
  }';
  amqpSend(*host, *queue, *msg);
}

sendRelatedEvent (*relationshipType, *relationshipSubType, *DataIds, *AccessIds, *host, *queue) {
# acrelatedEvent.r
  *relationshipTypeJson = jsonEncode(*relationship);
  *relationshipSubTypeJson = jsonEncode(*relationshipSubType);
  *msg='
  {
    "messages" : [ {
        "operation" : "create",
        "type" : "Relationship",
        "relationshipType" : "*relationshipTypeJson",
        "relatedEventIdentifier" : [';
  foreach(*DataId in *DataIds) {
    *DataIdJson = jsonEncode(*DataId);
    *msg = *msg ++ '{
        "relatedObjectIdentifierType": "URI",
        "relatedObjectIdentifierValue": "*DataIdJson",
        "relatedObjectIdentifierSequence": "not applicable"
    },';
  }
  if (substr(*msg, strlen(*msg) - 1, strlen(*msg)) == ",") {
    *msg = trimr(*msg, ",");
  }
  *msg = *msg ++ '], "relatedEventIdentifier" : [';
  foreach(*AccessId in *AccessIds) {
    *msg = *msg ++ '{
            "relatedEventIdentifierType": "URI",
            "relatedEventIdentifierValue": "*AccessId",
            "relatedEventIdentifierSequence": "not applicable"
          },';
  }
  if (substr(*msg, strlen(*msg) - 1, strlen(*msg)) == ",") {
    *msg = trimr(*msg, ",");
  }
  *msg = *msg ++ ']
    } ]
  }';
  amqpSend(*host, *queue, *msg);
}

splitPathByKey(*Name, *Delim, *Head, *Tail) {
# construct a path split function
  *L = strlen(*Name);
  *Head = *Name;
  *Tail = "";
  for (*i=0; *i<*L; *i=*i+1) {
    *C = substr(*Name, *i, *i+1);
    if (*C == *Delim) {
      *Head = substr(*Name, 0, *i);
      *Tail = substr(*Name, *i+1, *L);
      break;
    }
  }
}

updateCollMeta (*Coll, *Attr, *OldValue, *NewValue, *Lfile) {
# For collection *Coll, update *Attr from *OldValue to *NewValue
# Log operations to *Lfile
  *Str1 = "*Attr=*OldValue";
  msiString2KeyValPair(*Str1, *kvp1);
  msiRemoveKeyValuePairsFromObj(*kvp1, *Coll, "-C");
  *OldValue = *NewValue;
  *Str2 = "*Attr=*NewValue";
  msiString2KeyValPair(*Str2, *kvp);
  msiAssociateKeyValuePairsToObj(*kvp, *Coll, "-C");
  writeLine("*Lfile", "Reset *Attr to *NewValue for collection *Coll");
}

uploadFiles (*localRoot, *localPaths, *coll) {
# Function uploadFiles takes in an array listing of files *localPaths, and copies the files
# to the given location *coll, in the grid. It creates a collection if it doesn't exist.
# uploadFiles: input string * input list string * input string -> integer
    *fs = getFiles(*localRoot, *localPaths);
    *cs = getCollections(*fs);
    writeLine("stdout","*coll, *localPaths, *fs, *cs");
    createCollections(*coll, *cs);
    for(*i=0;*i<size(*fs);*i=*i+1) {
        *obj = elem(*fs,*i);
        msiDataObjPut("*coll/*obj", "demoResc", "localPath=*lf++++forceFlag=", *status);
    }
}

verifyReplicaChksum (*Coll, *File, *Lfile, *Num, *Rlist, *Ulist0, *Ulist, *Numr, *NumBad) {
# for file *Coll/*File and list of possible replica resources *Rlist
# *Num is the number of resources
# *NumBadFiles is a running total of the number of corrupted files
# generate resource user list *Ulist of resources with good replicas
  *Query5 = select DATA_REPL_NUM,DATA_CHECKSUM,DATA_RESC_NAME where COLL_NAME = '*Coll' and DATA_NAME = '*File';
  *Numr = 0;
  *Ulist = *Ulist0;
  foreach(*Row5 in *Query5) {
    *Numr = *Numr + 1;
    *Repln = *Row5.DATA_REPL_NUM;
    *Chk = *Row5.DATA_CHECKSUM;
    *Rescn = *Row5.DATA_RESC_NAME;
    msiDataObjChksum("*Coll/*File", "replNum=*Repln++++forceChksum=", *Chkf);
    if(int(*Chk) == 0) {
      *Chk = *Chkf;
    }  # end of set of checksum if not available
#======= save list of resources ===============================================
    if(int(*Chk) == int(*Chkf)) {
      for(*J=0;*J<*Num;*J=*J+1) {
        if(elem(*Rlist,*J) == *Rescn) {
          *Ulist = setelem(*Ulist,*J,"1");
          break;
        }  # end of set of *Ulist for resource
      }  # end of loop over resources
    }  # end of processing good checksum
#======== check whether checksum is correct, delete file if bad checksum =========
    if (int(*Chk) != int(*Chkf)) {
# don't delete, just log
      writeLine("*Lfile","Bad checksum for replica *Repln of file *Coll/*File.");
      *NumBad = *NumBad + 1;
      *Ulist = setelem(*Ulist,*J,"0");
    }  # end of processing a bad checksum
  } # end of loop over replicas for a logical file
}
