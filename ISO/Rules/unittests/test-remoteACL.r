remoteACL {
# set an access control on a file in a remote data grid
# local zone is defined by your irods_environment file
  *Path = "/*Zone/home/*Acc/*File";
  if (*Zone != $rodsZoneClient) {
# execute command in the remote zone
    findZoneHostName(*Zone, *Host, *Port);
    remote (*Host,"<ZONE>*Zone</ZONE>") {
      msiSetACL ("default", *Acl, *Acc, *Path);
    }
  }
  else {
# execute command in local zone
    msiSetACL ("default", *Acl, *Acc, *Path);
  }
}
findZoneHostName (*Zone, *Host, *Port) {
  *Q1 = select ZONE_CONNECTION where ZONE_NAME = '*Zone';
  foreach (*R1 in *Q1) {
    *Conn = *R1.ZONE_CONNECTION;
    msiSplitPathByKey (*Conn, ":", *Host, *Port);
  }
}
INPUT *Acl=$"read", *Acc=$"rods#tempZone", *Zone=$"perZone", *File=$"dummy"
OUTPUT ruleExecOut
