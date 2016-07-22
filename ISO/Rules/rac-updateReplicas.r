updateReplicas = main28
GLOBAL_STORAGE = "LTLResc"
main28 {
# rac-updateReplicas.r
# Policy28
# Use a rebalance operation to ensure every file is replicated
  *Resource = GLOBAL_STORAGE;
  run_periodic_rebalance(*Resource);
  writeLine ("stdout", "Initiated rebalance operation on storage *Resource every 30 days");
}
run_periodic_rebalance(*Resource) {
   delay("<PLUSET>1m</PLUSET><EF>30d</EF>") {
           msiWriteRodsLog("Performing Rebalance for *Resource replication resource", *Status);
           if (errorcode(msiRunRebalance(*Resource)) < 0) {
              msiWriteRodsLog("ERROR: Rebalance for *Resource replication resource Failed", *Status);
           }
           else {
              msiWriteRodsLog("Rebalance for *Resource replication resource complete", *Status);
           }
   }
}
INPUT null
OUTPUT ruleExecOut
