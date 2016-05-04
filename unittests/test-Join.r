testJoin {
  *List1 = list("AF", "AI", "AIPCR", "APR", "ASL", "CINC", "CIR", "DD", "DIR", "HCR", "IA", "IL", "INT", "LPR", "MI", "PAA", "PL", "PMR", "PR");
  *List2 = list("R", "RB", "SE", "SIA", "SIPCR", "TSE", "UR");
  *Listr = join_list(*List1,*List2);
  writeLine("stdout", "*Listr");
}
join_list(*l1, *l2) {
  if (size(*l1) == 0) then { *l2; }
  else {
  cons(hd(*l1),join_list(tl(*l1), *l2));
  }
}
INPUT null
OUTPUT ruleExecOut
