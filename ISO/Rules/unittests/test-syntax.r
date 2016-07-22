test {
# rac-verifyReportUpdates.r
# Policy3
# input parameter is the name of the report that is checked
# list of generated reports that are not archive specific and are manifests
  *List1 = list("EA", "ERCSA", "INTA", "NPRA", "RCA", "SEA");
# list of generated reports that are not archive specific and are versioned
  *List1v = list("AUPA", "BDA", "DIRA", "ILA", "PLA", "PPA", "SSA", "TSEA");
# list of generated reports that are archive specific and are manifests
  *List2 = list("AFA", "AIPCRA", "CINCA", "IPA", "PAA", "SIA", "SIPCRA", "TA");
# list of generated reports that are archive specific and are versioned
  *List2v = list("ALA", "ALRA", "ARA", "AURA", "CIRA", "DDA", "MA", "PMRA", "SAPA", "URA");
# list of management reports that are not archive specific
  *List3b = list("BPR", "BR", "CE", "CM", "CollP", "CP", "CR", "EAP", "FAR", "FR", "MS", "OP");
  *List3a = list( "PIP", "PR", "PSP", "SE", "SOP", "SP", "SRF", "STFP", "TAR", "TC", "TW");
# list of management reports that are archive specific
  *List4 = list("AIP", "AU", "CFR", "CID", "DAR", "DCP", "DCR", "DD", "DIP", "HVO", "INP", "IP", "META", "SAR", "SIP", "SL", "SSR", "STAR");
  *Listg1 = join_list(*List1, *List2);
  *Listg2 = join_list(*List1v, *List2v);
  *Listg = join_list(*Listg1, *Listg2);
  *List3 = join_list(*List3b, *List3a);
  *Listm = join_list(*List3, *List4);
  writeLine ("stdout", "Required generated reports \n *Listg");
  writeLine ("stdout", "Required management reports \n *Listm");
# determine which collection holds the report
}
join_list(*l1, *l2) {
  if (size(*l1) == 0) then { *l2; }
  else { cons(hd(*l1),join_list(tl(*l1), *l2)); }
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

INPUT *Archive="Archive-A", *File="Archive-AU.docx"
OUTPUT ruleExecOut
