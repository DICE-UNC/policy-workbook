antelopRule{
# dmp-sensor-harvest.r
#Store Packet in NetCDF CDL format=100
 *SColl = *Coll ++ "/" ++ *Sensor
 *SFile = *SColl ++ "/" ++ "waveform.cdl";
 msiCollCreate(*SColl,"1",*STAT_1);
 openForAppendOrCreate(*SFile, *Resc, *D_FD, *New);
#Get Packet, Reap, Decode and Store
 msiOrbOpen(*orbHost,*orbParam, *orbId);
 msiOrbSelect(*orbId, *Sensor,*sresOut);
 msiOrbReap(*orbId, *pktId, *srcName, *oTime, *pktOut, *nBytes, *resOut);
 msiOrbDecodePkt(*orbId, *modeIn + *New, *srcName, *oTime, *pktOut, *nBytes, *decodeBufInOut);
 msiDataObjWrite(*D_FD, *decodeBufInOut, *WR_LN);
 for(*I=0;*I< *PKTNum;*I=*I+1) {
   msiOrbReap(*orbId , *pktId2, *srcName2, *oTime2, *pktOut2, *nBytes2, *resOut2);
   msiOrbDecodePkt(*orbId, *modeIn, *srcName2, *oTime2, *pktOut2, *nBytes2, *decodeBufInOut2);
   msiDataObjLseek(*D_FD, *Offset,*Loc,*Status2);
   msiDataObjWrite(*D_FD, ",\n", *WR_LN_F4);
   msiDataObjWrite(*D_FD, *decodeBufInOut2, *WR_LN2);
   msiFreeBuffer(*decodeBufInOut2);
   msiFreeBuffer(*pktOut2);
 }
 msiOrbClose(*orbId);
 msiDataObjClose(*D_FD,*STAT_2);
}
openForAppendOrCreate(*SFile, *Resc, *D_FD, *New) {
  *SObj = "objPath=" ++ *SFile ++ "++++openFlags=O_RDWR";
  msiDataObjOpen(*SObj, *D_FD);
  msiDataObjLseek(*D_FD, *Offset,*Loc,*Status1); 
  msiDataObjWrite(*D_FD, ",\n", *WR_LN_F3);
  *New = 0;
}
openForAppendOrCreate(*SFile, *Resc, *D_FD, *New) {
  msiDataObjCreate(*SFile, *Resc, *D_FD);
  msiDataObjWrite(*D_FD, "netcdf seis_waveform {\ntypes:\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, " compound seismic_vector_t {\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "    double  timestamp;\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "    float upward ;\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "    float eastward ;\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "    float northward ;\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "  }; // seismic_vector_t\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "dimensions:\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "        time = UNLIMITED;\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "variables:\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "        seismic_vector_t seismic(time) ;\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "               seismic:standard_name = \"three vector seismic data\" ;\n",*WR_LN_F);
  msiDataObjWrite(*D_FD, "               seismic:long_name = \"Seismic\" ;\n",*WR_LN_F); 
  msiDataObjWrite(*D_FD, "// global attributes:\n",*WR_LN_F); 
  *New = 1;
}
input *Coll="/rajaanf/home/rods/newsenstest", *Resc="destRescName=anfdemoResc++++forceFlag=", *Sensor= "TA_J01E/MGENC/SM100", *orbHost="
anfexport.ucsd.edu:cascadia", *orbParam="", *modeIn=100, *Offset="-6", *Loc="SEEK_END", *PKTNum=100000
output *pktId, *srcName, *oTime, *nBytes, *pktOut, *decodeBufInOut, ruleExecOut
