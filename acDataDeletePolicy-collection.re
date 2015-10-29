acDataDeletePolicy {ON($objPath like “/$rodsZoneClient/home/$userNameClient/sensor/*”) {
  msiDeleteDisallowed; 
  } 
}
