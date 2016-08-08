registerMicroservices {
  racGlobalSet ();
# rac-registerMicroservices.r
# Policy17
# Register a micro-service into the metadata catalog
# load the source file into a structure in memory
  msiAdmReadMSrvcsFromFileIntoStruct
# load the structure into the database
  msiAdmInsertMSrvcsFromStructIntoDB
}
racGlobalSet = maing
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_DIPS = "DIPS"
GLOBAL_EMAIL = "rwmoore@renci.org"
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
INPUT *File=$"core.fnm"
OUTPUT ruleExecOut

