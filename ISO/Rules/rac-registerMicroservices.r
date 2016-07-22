registerMicroservices {
# rac-registerMicroservices.r
# Policy17
# Register a micro-service into the metadata catalog
# load the source file into a structure in memory
  msiAdmReadMSrvcsFromFileIntoStruct
# load the structure into the database
  msiAdmInsertMSrvcsFromStructIntoDB
}
INPUT *File=$"core.fnm"
OUTPUT ruleExecOut

