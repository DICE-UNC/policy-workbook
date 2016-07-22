listOntologies {
# rac-listOntologies.r
# Policy15
# list the ontologies used by all collections
  *Q1 = select COLL_NAME, META_COLL_ATTR_VALUE where META_COLL_ATTR_NAME = "Archive-Ontology";
  foreach (*R1 in *Q1) {
    *Coll = *R1.COLL_NAME;
    *Ont = *R1.META_COLL_ATTR_VALUE;
    writeLine ("stdout", "Community *Coll uses ontology *Ont");
  }
}
INPUT null
OUTPUT ruleExecOut
