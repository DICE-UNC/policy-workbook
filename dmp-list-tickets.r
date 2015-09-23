checkTicket {
# dmp-list-tickets.r
# list the tickets created for a collection
  checkCollInput (*Coll);
  *rs = select COLL_NAME where COLL_NAME like '*Coll%';
  foreach(*r in *rs) {
    *Col = *r.COLL_NAME;
# Find tickets for the file
    *Query4 = select TICKET_ID, TICKET_EXPIRY where TICKET_DATA_COLL_NAME = '*Col';
# List tickets for each collection
    foreach(*Row4 in *Query4) {
      *Tid = *Row4.TICKET_ID;
      *Texp = *Row4.TICKET_EXPIRY;
      writeLine("stdout","Ticket *Tid expires *Texp");
    }
  }
}
INPUT *Coll =$"/Mauna/home/atmos/research"
OUTPUT ruleExecOut 
