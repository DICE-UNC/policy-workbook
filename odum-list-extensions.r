listExtensions {
# odum-list-extensions.r
# list the extensions used in your account
    *c = "/$rodsZoneClient/home/$userNameClient%";
    summary(*c);
}
summary (*c) {
    *rs = select DATA_NAME, DATA_SIZE where COLL_NAME like *c;
    *res.total = str(0);
    *total.total = str(0);
    foreach(*r in *rs) {
        *fn = *r.DATA_NAME;
        *ds = *r.DATA_SIZE;
        *ext = ext(*fn);
        *res.total = str(int(*res.total) + 1);
        *total.total = str(double(*total.total) + double(*ds));
        if (contains(*res, *ext)) {
            *res.*ext = str(int(*res.*ext) + 1);
            *total.*ext = str(double(*res.*ext) + double(*ds));
        } else {
            *res.*ext = str(1);
            *total.*ext = *ds;
        }
    }
    writeLine("stdout", "ext\t\tnumber\t\tavg size\ttotal size");
    foreach(*ext in *res) {
        if(*ext != "total") {
            *c4 = *total.*ext;
            *c1 = *ext ++ "\t";
            if (strlen(*ext) < 8) {*c1 = *c1 ++ "\t";}
            *c2 = *res.*ext ++ "\t";
            if (strlen(*res.*ext) < 8) {*c2 = *c2 ++ "\t";}
            *tot = 0.;
            if (int(*res.*ext) > 0) {*tot = double(*total.*ext)/int(*res.*ext);}
            *c3 = str(*tot) ++ "\t";
            if (strlen(str(*tot)) < 8) {*c3 = *c3 ++ "\t";}
            *cp = *c1 ++ *c2 ++ *c3 ++ *c4;
            writeLine("stdout", "*cp");
        }
    }
    *c4 = *total.total;
    *totr = 0.;
    if (int(*res.total) > 0) {*totr = double(*total.total)/int(*res.total);}
    *c1 = "total\t\t";
    *c2 = *res.total ++ "\t";
    if (strlen(*res.total) < 8) {*c2 = *c2 ++ "\t";}
    *c3 = str(*totr) ++ "\t";
    if (strlen(str(*totr)) < 8) {*c3 = *c3 ++ "\t";}
    *cpt = *c1 ++ *c2 ++ *c3 ++ *c4;
    writeLine("stdout", "*cpt");
}
input null
output ruleExecOut


