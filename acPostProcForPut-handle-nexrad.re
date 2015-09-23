acPostProcForPut {ON($userNameClient like "nexrad") {
        msiWriteRodsLog("Attempting to create Handle for $objPath", *Status);
        *Cmd = "create_handle";
        *Keyfile = "/var/lib/irods/hs/admpriv.bin";
        *Uri = "irods%3A%2F%2Firen2.renci.org%3A1237$objPath";
        *Url = "https://dfcweb.datafed.org/idrop-web2/home/link?irodsURI=*Uri";

        *Args = "$dataId *Url";
        msiExecCmd(*Cmd, *Args, "null", "null", "null", *Result);
        msiGetStdoutInExecCmdOut(*Result,*Out);
        msiWriteRodsLog("Created Handle *Out for $objPath", *Status);
}
