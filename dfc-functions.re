addAVUMetadata (*Path, *Attname, *Attvalue, *Aunit, *Status) {
  *Status = "1";
# using micro-service from iPlant Collaborative
  msiSetAVU("-d", *Path, *Attname, *Attvalue, *Aunit);
  *Status = "0";
}

addAVUMetadataToColl(*Coll, *Attname, *Attvalue, *Attunit, *Status) {
# add metadata to a collection
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
    remote (*Host,"null") {
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
    remote (*Host, "null") {
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

createLogFile (*Coll, *Sub, *Name, *Res, *LPath, *Lfile, *Dfile, *L_FD) {
# Create a log sub-directory within *Coll if it is missing
# Create a timestamped log file with the input file name *Name
  msiGetSystemTime(*TimeH,"human");
#============ create a collection for log files if it does not exist ===============
  *LPath = "*Coll/*Sub";
  isColl (*LPath, "stdout", *Status);
  if (*Status < "0") { fail;}
#============ create file into which results will be written =========================
  *Lfile = "*LPath/*Name-*TimeH";
  *Dfile = "destRescName=*Res++++forceFlag=";
  msiDataObjCreate(*Lfile, *Dfile, *L_FD);
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

findZoneHostName (*Zone, *Host, *Port) {
  *Q1 = select ZONE_CONNECTION where ZONE_NAME = '*Zone';
  foreach (*R1 in *Q1) {
    *Conn = *R1.ZONE_CONNECTION;
    msiSplitPathByKey (*Conn, ":", *Host, *Port);
  }
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

modAVUMetadata (*Path, *Attname, *Attvalue, *Aunit, *Status) {
# delete the original attribute value and add the new value to a file
  msiSplitPath (*Path, *Coll, *File);
  *Q1 = select META_DATA_ATTR_VALUE, META_DATA_ATTR_UNITS where DATA_NAME = '*File' and COLL_NAME = '*Coll' and META_DATA_ATTR_NAME = '*Attname';
  foreach (*R1 in *Q1) { 
    *Avorig = *R1.META_DATA_ATTR_VALUE;}
    *Auorig = *R1.META_DATA_ATTR_UNITS;}
  }
  deleteAVUMetadata (*Path, *Attname, *Avorig, *Auorig, *Status);
  addAVUMetadata (*Path, *Attname, *Attvalue, *Aunit, *Status)
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

