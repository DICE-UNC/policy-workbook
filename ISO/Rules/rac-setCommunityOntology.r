setCommunityOntology = main14
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_STORAGE = "LTLResc"
main14 {
# rac-setCommunityOntology
# Policy14
  msiGetSystemTime (*Time, "human");
  *Path = GLOBAL_ACCOUNT ++ "/*Archive";
  addAVUMetadataToColl (*Path, "Archive-Ontology", *OntologyName, "", *Stat);
  writeLine ("stdout", "Added attribute Archive-Ontology with value *OntologyName to account *Path on *Time");
  racWriteManifest ("Archive-PAA", *Archive, "stdout");
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
INPUT *Archive=$"Archive-A", *OntologyName=$"uat"
OUTPUT ruleExecOut
