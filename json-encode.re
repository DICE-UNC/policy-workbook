jsonEncode(*str) {
    *json = "";
    for(*i=0;*i<strlen(*str);*i=*i+1) {
        *s = substr(*str, *i, *i+1);
        if(*s == "\'") {
            *json = *json ++ "\\\'";
        } else if (*s == "\"") {
            *json = *json ++ "\\\"";
        } else if (*s == "\\") {
            *json = *json ++ "\\\\";
        } else if (*s == "\b") {
            *json = *json ++ "\\b";
        } else if (*s == "\f") {
            *json = *json ++ "\\f";
        } else if (*s == "\n") {
            *json = *json ++ "\\n";
        } else if (*s == "\r") {
            *json = *json ++ "\\r";
        } else if (*s == "\t") {
            *json = *json ++ "\\t";
        } else {
            *json = *json ++ *s;
        }
    }
    *json;
}
