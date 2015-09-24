jsonEncode(*str) {
    *json = "";
    for(*i=0;*i<strlen(*str);*i=*i+1) {
        *spec = substr(*str, *i, *i+1);
        if(*spec == "\'") {
            *json = *json ++ "\\\'";
        } else if (*spec == "\"") {
            *json = *json ++ "\\\"";
        } else if (*spec == "\\") {
            *json = *json ++ "\\\\";
        } else if (*spec == "\b") {
            *json = *json ++ "\\b";
        } else if (*spec == "\f") {
            *json = *json ++ "\\f";
        } else if (*spec == "\n") {
            *json = *json ++ "\\n";
        } else if (*spec == "\r") {
            *json = *json ++ "\\r";
        } else if (*spec == "\t") {
            *json = *json ++ "\\t";
        } else {
            *json = *json ++ *s;
        }
    }
    *json;
}
