myTestRule {
#  rda-metaload.r
#Input parameters are:
#  Buffer
#  Tag structure
#Output parameter is:
#  Keyval pair buffer
  *Tag = "/$rodsZoneClient/home/$userNameClient/" ++ *Tag;
  *Pathfile = "/$rodsZoneClient/home/$userNameClient/" ++ *Pathfile;
  *Outfile = "/$rodsZoneClient/home/$userNameClient/" ++ *Outfile;
  checkPathInput (*Tag);
  checkPathInput (*Outfile);
  checkPathInput (*Outfile);

  #Read in 10,000 bytes of the file
  msiDataObjOpen(*Pathfile,*F_desc);
  msiDataObjRead(*F_desc,*Len,*File_buf);
  msiDataObjClose(*F_desc,*Status);

  #Read in the tag template file
  msiDataObjOpen(*Tag,*T_desc);
  msiDataObjRead(*T_desc, 10000, *Tag_buf);
  msiReadMDTemplateIntoTagStruct(*Tag_buf,*Tags);
  msiDataObjClose(*T_desc,*Status);

  #Extract metadata from file using the tag template file
  msiExtractTemplateMDFromBuf(*File_buf,*Tags,*Keyval);

  #Write out extracted metadata
  writeKeyValPairs("stdout",*Keyval," : ");
  msiGetObjType(*Outfile,*Otype);

  #Add metadata to the object
  msiAssociateKeyValuePairsToObj(*Keyval,*Outfile,*Otype);
}
INPUT *Tag="Rules/email.tag", *Pathfile="Rules/sample.email", *Outfile="Rules/sample.email", *Len=10000
OUTPUT ruleExecOut
