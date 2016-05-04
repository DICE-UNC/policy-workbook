listExtensions {
# odum-list-extensions.r
# list the extensions used in your account
    *c = "/$rodsZoneClient/home/$userNameClient%";
    summary(*c);
}
summary (*c) {
    *Q = select DATA_NAME, DATA_SIZE where COLL_NAME like '*c';
    *Numformat.total = str(0);
    *Sizeformat.total = str(0);
    foreach(*R in *Q) {
        *File = *R.DATA_NAME;
        *Size = *R.DATA_SIZE;
        *Ext = ext(*File);
        *Numformat.total = str(int(*Numformat.total) + 1);
        *Sizeformat.total = str(double(*Sizeformat.total) + double(*Size));
        if (contains(*Numformat, *Ext)) {
            *Numformat.*Ext = str(int(*Numformat.*Ext) + 1);
            *Sizeformat.*Ext = str(double(*Sizeformat.*Ext) + double(*Size));
        } else {
            *Numformat.*Ext = str(1);
            *Sizeformat.*Ext = *Size;
            writeLine("stdout", "found *Ext");
        }
    }
    writeLine("stdout", "ext\t\tnumber\t\tavg size\ttotal size");
    foreach(*Ext in *Numformat) {
      if(*Ext != "total") {
           *c4 = *Sizeformat.*Ext;
            *c1 = *Ext ++ "\t";
            if (strlen(*Ext) < 8) {*c1 = *c1 ++ "\t";}
            *c2 = *Numformat.*Ext ++ "\t";
            if(strlen(*Numformat.*Ext) < 8) {*c2 = *c2 ++ "\t";}
            *tot= 0.;
            if (int(*Numformat.*Ext) > 0) {*tot = double(*Sizeformat.*Ext)/int(*Numformat.*Ext);}
            *c3 = str(*tot) ++ "\t";
            if (strlen(str(*tot)) < 8) {*c3 = *c3 ++ "\t";}
            *cp = *c1 ++ *c2 ++ *c3 ++ *c4;
            writeLine("stdout", "*cp");
        }
    }
    *c4 = *Sizeformat.total;
    *totr = 0.;
    if (int(*Numformat.total) > 0) {*totr = double(*Sizeformat.total)/int(*Numformat.total);}
    *c1 = "total\t\t";
    *c2 = *res.total ++ "\t";
    if (strlen(*res.total) < 8) {*c2 = *c2 ++ "\t";}
    *c3 = str(*totr) ++ "\t";
    if (strlen(str(*totr)) < 8) {*c3 = *c3 ++ "\t";}
    *cpt = *c1 ++ *c2 ++ *c3 ++ *c4;
    writeLine("stdout", "*cpt");
}
contains(*list, *elem) {
    *ret = false;
    foreach(*e in *list) {
        if(*e == *elem) {
            *ret = true;
        }
    }
    *ret;
}
ext(*p) {
    *b = trimr(*p, ".");
    *ext = if *b == *p then "no ext" else substr(*p, strlen(*b)+1, strlen(*p));
    *ext;
}
input null
output ruleExecOut
