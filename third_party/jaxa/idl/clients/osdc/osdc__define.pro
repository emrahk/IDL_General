;+
; Project     : Hinode Science Data Centre Europe (Oslo SDC)
;                   
; Name        : OSDC__DEFINE
;               
; Purpose     : Client for Hinode Science Data Centre Europe (Oslo)
;               
; Explanation : Interactive searches done through http:://sdc.uio.no/search can
;               also be performed from IDL programs through this client.
;
; Use         : See osdc_test routine at end of file
;
; Inputs      : None required
; 
; Opt. Inputs : USERNAME and PASSWORD if still required by Hinode project
;
; Outputs     : o->search,OUTPUT - Is '' if no files found, otherwise an
;                                  array of structures with the requested
;                                  fields.
;               
; Opt. Outputs: OUTPUT is optional but dropping it is meaningless
;               
; Keywords    : SERVER='sdc.uio.no' or other archive server
;
; Calls       : OSDC_HTTP__DEFINE, DEFAULT, STRARRCOMPRESS
;
; Common      : None
;               
; Restrictions: No checking on search/output field names/values done, caveat
;               emptor, the garbage in/garbage out principle holds.
;               
; Side effects: Submits search query to the server
;               
; Categories  : Archive interface, object, web client
;               
; Prev. Hist. : None
;
; Written     : SVH Haugan, UiO, 23 January 2007
;               
; Modified    : Relevant log entries below:
;
; $Log: osdc__define.pro,v $
; Revision 1.33  2010/03/25 12:52:17  steinhh
; HTTP::list now interprets query string slightly different - we add a '/'
; at the beginning to avoid first part of search string to be taken as a
; server specification
;
; Revision 1.31  2009/09/23 09:56:57  steinhh
; Fixed issue with changed HTTP object, now using unadulterated http::readf
; and then parsing the results afterwards.
;
; Revision 1.28  2008/01/17 09:19:28  tfredvik
; # ::ensure_files: changed type of loop counter i from int to long
;
; Revision 1.27  2007/11/08 15:35:50  steinhh
; Moved "Use" to routine osdc_test at bottom, added
; "valid" status to warn about outdated status output.
;
; Revision 1.24  2007/10/08 12:11:34  steinhh
; Changed path calculation to the one used internally at the archive
; (e.g. there have been mismatches between file names & actual
; directories). Modified documentation (e.g. drop authorization details, add
; examples under Use section). Added ::search(), ::nmatch(), added implicit
; search when calling ::paths() with no arguments. Cleaned up memory leaks,
; added /add to ::show.
;
; Revision 1.23  2007/09/05 08:59:41  steinhh
; Cleaned up log &c
;
; Revision 1.19  2007/04/03 12:33:32  steinhh
; Added URL_DECODE(), STATUS, keyword-specific CLEAR
;
; Revision 1.18  2007/03/29 11:16:21  steinhh
; Included reality level in URL
;
; Revision 1.15  2007/03/09 14:44:06  steinhh
; *Not* fetching gzipped files if unzipped files exist. 
; Added osdc::ensure_dir
;
; Revision 1.14  2007/03/07 10:22:27  steinhh
; Dropped += operator for compatibility with e.g. IDL 5.6
;
; Revision 1.13  2007/03/06 20:02:59  steinhh
; More error handling, fixed bug in EIS paths
;
; Revision 1.12  2007/03/06 19:50:47  steinhh
; Added base64_encode function to be more stand-alone
;
; Revision 1.11  2007/03/06 19:37:47  steinhh
; Removed some debugging statements
;
; Revision 1.10  2007/03/06 19:35:20  steinhh
; Added osdc::paths, with download/decompress ability
;
; 5 Nov 2013: Stein Haugan (s.v.h.haugan@astro.uio.no)
; Fixed issue with IRIS files being identified as SOT files, resulting in
; wrong path.
;
; 29 Jul 2015: Incredibly enough, calculating the path of FGIV files has never
;              worked before! I.e. nobody has tried to download it (or at
;              least they haven't complained it not working. It does work now.
;
; Version     : 5 Nov 2013
;-
FUNCTION osdc::init,user,pass,server=server,fileserver=fileserv
  default,user,''
  default,pass,''
  
  IF NOT keyword_set(server) THEN server = getenv("OSDC_DB")
  IF NOT keyword_set(server) THEN server = 'sdc.uio.no'
  
  IF NOT keyword_set(fileserv) THEN fileserv = getenv("OSDC_FS")
  IF NOT keyword_set(fileserv) THEN fileserv = server

  self.db_conn = obj_new('osdc_http',server=server)
  self.fs_conn = self.db_conn
  
  IF fileserv NE server THEN  self.fs_conn = obj_new('osdc_http',server=server)

  self.show = ptr_new(/allocate)
  self.cond = ptr_new(/allocate)
  
  self->limit,1000
  self->page,1
  self->show,"FILE,INSTRUME,DATE_OBS,DATEPATH,SUBPATH,HOURPATH"
  self->order,'DATE_OBS',/ascending
  self->authorise,user,pass

  return,1
END

PRO osdc::cleanup
  ptr_free,self.show,self.cond
  IF self.fs_conn NE self.db_conn THEN obj_destroy,self.fs_conn
  obj_destroy,self.db_conn
END 

PRO osdc::limit,max_lines
  self.limit = max_lines
END

PRO osdc::page,n
  self.page = n
END

PRO osdc::show,list,add=add
  zparcheck,'OSDC::SHOW',list,1,typ(/str),0,'LIST'
  
  ; Stupid users - inserting spaces after commas, which makes PHP ignore all
  ; the subsequent stuff in the URL -> chopping off all the conditions!!!
  ; Spaces in the list of fields to show doesn't have any function at all, so
  ; we just remove them. Spaces in the conditions are handled (correctly) by
  ; translating to %20, though.
  ;
  list = strcompress(list,/remove_all)
  IF keyword_set(add) AND exist(*self.show) THEN BEGIN
     list = strjoin([*self.show,list],',')
  END
  list = strtok(list,',',/extract)
  add = ''
  musthave = ['FILE','DATEPATH','SUBPATH','HOURPATH']
  FOR i=0,n_elements(musthave)-1 DO $
     IF total(list EQ musthave[i]) EQ 0 THEN add = [add,musthave[i]]
  IF n_elements(add) GT 1 THEN BEGIN
     print,"Adding fields to allow path calculation: ",strjoin(add[1:*],',')
     list = [list,add[1:*]]
  END
  mask = bytarr(n_elements(list))
  mask[uniq(list,sort(list))] = 1b
  *self.show = list[where(mask)]
END

PRO osdc::order,field,ascending=ascending,descending=descending
  default,field,'DATE_OBS'
  descending = keyword_set(descending)
  default,ascending,1b-descending
  
  IF ascending AND descending THEN $
     stop,"Cannot sort both ascending and descending!"
  IF ascending THEN  self.dir = 'A'
  IF descending THEN self.dir = 'D'
  
  self.order = field
END

FUNCTION osdc::base64_encode_part,part
  digs =  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  npad =  3-n_elements(part)
  IF npad GT 0 THEN part =  [part,bytarr(npad)]
  
  ulon =  ulong([0b,part],0)
  byteorder,ulon,/ntohl ;; Network[big-endian]-to-host conversion
  
  res =  ""
  FOR i=1,24,6 DO BEGIN
     six =  ishft(ulon,-18)     ;
     ulon =  (ulon * 2UL^6) AND '00ffffff'X
     res = res + strmid(digs,six,1)
  END
  
  res =  strmid(res,0,4-npad)+strmid("==",0,npad)
  
  return,res
END

FUNCTION osdc::base64_encode,s
  barr =  byte(s)
  res =  ""
  FOR i=0,n_elements(barr)-4,3 DO BEGIN
     part =  barr[i:i+2]
     res =  res + self->base64_encode_part(part)
  END
  res = res + self->base64_encode_part(barr[i:*])
  return,res
END

PRO osdc::authorise,user,pass
  default,user,''
  default,pass,''
  self.auth = ''
  IF user NE '' THEN $
     self.auth = "Authorization: Basic " + self->base64_encode(user+":"+pass)
END 

FUNCTION osdc::cond
  IF NOT exist(*self.cond) THEN return,''
  return,*self.cond
END


FUNCTION osdc::url_decode,s     ; s is clobbered
  s = str_replace(s,'+',' ')
  res = ''
  WHILE (i=strpos(s,'%')) GE 0 DO BEGIN
     res = res+strmid(s,0,i)
     hex2dec,strmid(s,i+1,2),byt,/quiet
     res = res+string(byte(byt))
     s = strmid(s,i+3,1e5)
  END
  res = res+s
  return,res
END


; Helper function to identify already-encoded '%xx' sequences
;
FUNCTION osdc::url_encode_is_encoded_char,triplet
  
  IF strlen(triplet) LT 3 THEN return,0b
  
  hex_digits = '0123456789ABCDEFabcdef'
  c0 = strmid(triplet,0,1)
  c1 = strmid(triplet,1,1)
  c2 = strmid(triplet,2,1)
  
  IF c0 NE '%'                  THEN return,0b
  IF strpos(hex_digits,c1) LT 0 THEN return,0b
  IF strpos(hex_digits,c2) LT 0 THEN return,0b
  
  return,1b
END


; Genuine RFC2396 (sect. 2.3) url_encode, but does not encode '%' if followed
; by two hex digits (most likely a pre-encoded string!), unless the keyword
; encode_encoding_percent is set
;
FUNCTION osdc::url_encode,url,encode_encoding_percent=encode_encoding_percent
  
  zparcheck,"OSDC::URL_ENCODE",url,1,typ(/str),0,"URL"
  encode_encoding_percent = keyword_set(encode_encoding_percent)
  IF url EQ '' THEN return,''
  
  ; These characters do not need any encoding:
  ;
  safe = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" $
         +"abcdefghijklmnopqrstuvwxyz" $
         +'0123456789' $
         +"-_.!~*'()"
  
  ; Build output sequence of characters (encoded or not)
  ;
  length = strlen(url)
  out = strarr(length) ; Note - each entry may become more than one char!
  
  ; Consider each character separately
  ;
  FOR i=0,length-1 DO BEGIN
     ; Set-up:
     ;
     c = strmid(url,i,1)
     c_hex = '%'+string((byte(c))[0],format='(Z2.2)')
     
     ; Do the next three characters look like an encoded character? I.e. does
     ; it look like '%xx'?
     ;
     triplet = strmid(url,i,3)
     is_encoded_char = self->url_encode_is_encoded_char(triplet)
     
     ; Unless explicitly told to encode the '%' at the start of what looks
     ; like an already-encoded
     ;
     IF encode_encoding_percent THEN is_encoded_char = 0
     
     ; Now for the decision:
     ;
     ; If it's safe, then it's safe. 
     ; If it's '%', at the beginning of an encoded_char, then leave it
     ; If it's space, then it's '+'.
     ;
     ; If none of the above, use hex encoding - note that this includes '%' in
     ; '%xx' *if* /encode_encoding_percent is set!
     ;
     IF      strpos(safe,c) GE 0 THEN   out[i] = c     $
     ELSE IF is_encoded_char     THEN   out[i] = c     $
     ELSE IF c EQ ' '            THEN   out[i] = '+'   $
     ELSE                               out[i] = c_hex
  END
  
  return,strjoin(out,'')
END

PRO osdc::condition,condition
  IF n_params() LT 1 THEN message,"Use: object->condition,'KEYWORD: value'"
  zparcheck,'OSDC::CONDITION',condition,1,typ(/STR),0,"CONDITION"
  parts = strtok(condition,':',/extract)
  IF n_elements(parts) EQ 1 THEN $
     message,"CONDITION must be like 'FIELDNAME: <value>'"
  tag = parts[0]
  value = trim(strjoin(parts[1:*],':')) ;; Put value back together
  cons = self->cond()
  ix = where(strpos(cons,tag+"=") NE 0,c)
  IF c EQ 0 THEN cons = '' ELSE cons = cons[ix]
  val = self->url_encode(value)
  *self.cond = strarrcompress([cons,tag+"="+val])
  self.valid = 0
END

PRO osdc::clear,keyword
  IF n_params() EQ 0 THEN BEGIN 
     delvarx,*self.cond
     self.valid = 0
     return
  END
  zparcheck,'OSDC::CLEAR',keyword,1,typ(/STR),0,"KEYWORD"
  cons = self->cond()
  IF total(strpos(cons,keyword+"=") EQ 0) EQ 0 THEN BEGIN
     print,"No criterion '"+keyword+"' found"
     self->status
     return
  END
  self.valid = 0
  ix = where(strpos(cons,keyword+"=") NE 0,c)
  IF c EQ 0 THEN BEGIN
     delvarx,*self.cond
     self.valid = 0
     return
  END
  *self.cond = strarrcompress(cons[ix])
END

PRO osdc::reality,reality
  self.reality = reality
END

FUNCTION osdc::query_string
  L = 'L='+trim(self.limit)
  P = 'P='+trim(self.page)
  s = 's=,'+strjoin(*self.show,',')
  O = 'O='+self.order+';o='+self.dir
  cond = strarrcompress([L,P,s,O,self->cond()])
  return,strjoin(cond,';')
END

PRO osdc::status
  IF self.limit GT 0 THEN BEGIN 
     print,"Page "+trim(self.page)+", " +$
           trim(self.limit)+" lines/page"
  END
  print,"Show:  "+strjoin(*self.show,', ')
  print,"Order: "+self.order,format='(A,$)'
  IF self.dir EQ 'A' THEN print," Ascending" $
  ELSE                    print," Descending"
  print,"--"
  print,"Matching files during last search: "+trim(self->nmatch())
  IF NOT self.valid THEN print,"NOTE: Search criteria changed since last search"
  print,"--"
  cond = self->cond()
  IF cond[0] EQ '' THEN BEGIN
     print,"No selection criteria"
     return
  END
  FOR i=0,n_elements(cond)-1 DO BEGIN
     parts = strtok(cond[i],'=',/extract)
     print,parts[0]+': '+self->url_decode(parts[1])
  END
END

PRO osdc::search,out
  self.db_conn->close
  query = "search/plainserve.php?"+self->query_string()
  IF self.reality GT 0 THEN query = trim(self.reality)+query
  info = self.auth
  IF info EQ '' THEN delvarx,info ;; info = 0 ;; Only strings count :-)
  
  ; Doh! The http object *does* have this property, it's just not used!!
  ;
  server = self.db_conn->hget(/server)
  
  ; At the moment, http__define does not respect the server property like it
  ; used to do, so it has to be built into the query
  ;
  query = 'http://'+server+'/'+query
  print,query
  self.db_conn->list,query,out,info=info
  self.db_conn->parse,out
  self.valid = 1
END


FUNCTION osdc::search
  self->search,out
  return,out
END

FUNCTION osdc::nmatch
  return,self.db_conn->nmatch()
END 

PRO osdc::ensure_dir,dir_in
  IF file_test(dir_in,/directory) THEN return
  file_mkdir,dir_in
END

PRO osdc::ensure_files,paths,unzip=unzip
  ix = where((nozip=file_test(paths) NE 1),c)
  IF c EQ 0 THEN return
  
  unzpaths = strarr(n_elements(paths)) ; An existing unzipped file might do
  
  len = strlen(paths)-3
  FOR i=0L,n_elements(paths)-1 DO unzpaths[i] = strmid(paths[i],0,len[i])
  unzfine = file_test(unzpaths)
  ix = where(nozip AND NOT unzfine,c2)
  
  IF c2 LT c THEN BEGIN
     delta = trim(c-c2)
     IF NOT keyword_set(unzip) THEN BEGIN
        message,delta+" files found unzipped, but unzip flag is not set",/info
        message,"Set unzip flag to accept unzipped files ",/info
        message,"...OR gzip the files manually!"
     END
     message,"NOT fetching "+delta+" of "+trim(c)+" files",/info
     message,"...they were found unzipped",/info
     c = c2
  END
  info = self.auth
  top = getenv("HINODE_DATA")
  ntop = strlen(top)
  
  ; Doh! http object *does* have the server property, but refuses to use it!
  ;
  server = self.fs_conn->hget(/server)
  url_first_part =  "http://"+server+"/vol/fits/"
  
  FOR i=0L,c-1 DO BEGIN 
     path = paths[ix[i]]
     dir = strmid(path,0,strpos(path,'/',/reverse_search))
     
     file = strmid(path,strpos(path,'/',/reverse_search)+1,1000)
     self->ensure_dir,dir
     rpath = strmid(path,ntop+1,1000)
     print,"Fetching "+path,form='(a,$)'
     self.fs_conn->copy,url_first_part+rpath,path,info=info,err=err
     print," .. and done"
     IF err NE '' THEN message,err
  END
  message,'Files should now be in place',/info
END

PRO osdc::unzip,from,to
  COMMON osdc__unzip_buffer,buffer
  
  IF n_elements(buffer) EQ 0 THEN buffer =  bytarr(1024L*1024L,/noz)
  
  openr,flun,from,/get_lun,/raw,/compress
  openw,tlun,to,/get_lun
  REPEAT BEGIN
     readu,flun,buffer,transfer_count=count
     IF count EQ 0 THEN CONTINUE
     writeu,tlun,buffer[0:count-1]
  END UNTIL count NE n_elements(buffer)
  free_lun,flun
  free_lun,tlun
END

PRO osdc::ensure_unzipped,paths,rmzip=rmzip
  doable = file_test(paths)
  len = strlen(paths)-3
  FOR i=0,n_elements(paths)-1 DO paths[i] = strmid(paths[i],0,len[i])
  desired = file_test(paths) NE 1
  undoable = total(desired AND NOT doable)
  IF undoable NE 0 THEN begin
     message,trim(undoable)+" file[s] cannot be unzipped " + $
             "b/c they're not present (fetch them first):",/info
     print,paths[where(desired AND NOT doable)],form='(a)'
  END
  ix = where(desired AND doable,c)
  rmzip = keyword_set(rmzip)
  FOR i=0,c-1 DO BEGIN
     uncpath = paths[ix[i]]
     cpath = uncpath+'.gz'
     print,"Uncompressing "+cpath
     self->unzip,cpath,uncpath
     IF rmzip THEN file_delete,cpath
  END
END


FUNCTION osdc::paths,out,fetch=fetch,unzip=unzip,rmzip=rmzip
  fetch = keyword_set(fetch)
  unzip = keyword_set(unzip)
  rmzip = keyword_set(rmzip)
  
  
  IF unzip OR rmzip THEN BEGIN
     message,"/UNZIP and /RMZIP have been deprecated.",/informational
     message,"Compressed files can be used 'as is', *except*",/informational
     message,"for *some* IRIS files! If you get core dumps when",/informational
     message,"reading compressed IRIS files, try decompressing",/informational
  END

  IF n_params() EQ 0 THEN out = self->search()
  
  ins = strlowcase(strmid(out.file,0,3))
  ok = bytarr(n_elements(ins))
  nlines = n_elements(out)
  
  ; We need to find the path prefix (e.g. ../sot/level0 or ../iris/level2)
  ;
  eisix = where(ins EQ 'eis',eisc)   &   IF eisc GT 0 THEN ok[eisix] = 1
  xrtix = where(ins EQ 'xrt',xrtc)   &   IF xrtc GT 0 THEN ok[xrtix] = 1
  iriix = where(ins EQ 'iri',iric)   &   IF iric gt 0 then ok[iriix] = 1
  
  ; It's tempting to say "all the rest are SOT", but that's not very
  ; forward-looking, is it, now!
  ;
  sotq = bytarr(nlines)
  sots = ['sp4','fg2','fgs','fgm','fgd','fgi']
  FOR i=0,n_elements(sots)-1 DO sotq += ins EQ sots[i]
  
  ; Now we can do it:
  ;
  sotix = where(sotq,sotc)           &   IF sotc GT 0 THEN ok[sotix] = 1
  
  IF total(ok) NE nlines THEN BEGIN
     print
     message,"Some results have a file name that " $
             +"I cannot understand: ",/informational
     print
     badix = where(ok NE 1b)
     FOR i=0,n_elements(badix)-1 DO BEGIN
        message,'    '+out[badix[i]].file,/informational
     END 
     print
     message,'Bring this to the attention of osdcapps@astro.uio.no (include '$
             +'the search details). In the mean time, exclude these files '$
             +'from your search',/informational
     print
     message,'Stopping'
  END 
  
  paths = strarr(nlines)
  
  top = getenv("HINODE_DATA")
  IF top EQ '' THEN $
     message,"You should setenv HINODE_DATA to root of data tree",/info
  
  IF eisc GT 0 THEN BEGIN
     start = top+'/eis/mission/'
     paths[eisix] = start+out[eisix].DATEPATH+'/'+out[eisix].file+'.fits.gz'
  END
  IF xrtc GT 0 THEN BEGIN
     start = top+'/xrt/level0/'
     path = out[xrtix].DATEPATH+'/'+out[xrtix].HOURPATH
     paths[xrtix] = start+path+'/'+out[xrtix].file+'.fits.gz'
  END
  IF sotc GT 0 THEN BEGIN
     start = top+'/sot/level0/'
     path = out[sotix].DATEPATH+'/'+out[sotix].SUBPATH+'/'+out[sotix].HOURPATH
     paths[sotix] = start+path+'/'+out[sotix].file+'.fits.gz'
  END
  
  IF iric GT 0 THEN BEGIN
     start = top+'/iris/level2/'
     path = out[iriix].DATEPATH+'/'+out[iriix].SUBPATH+'/'+out[iriix].HOURPATH
     paths[iriix] = start+path+'/'+out[iriix].file+'.fits.gz'
  END 
  
  IF fetch THEN BEGIN
     IF top EQ '' THEN $
        message,"setenv HINODE_DATA to root of data tree before fetching!"
     self->ensure_files,paths,unzip=unzip
  END
  
  ix = where(strpos(paths,'iris') GE 0,count)
  IF count GT 0 AND NOT unzip THEN BEGIN
     message,"WARNING: Some uncompressed IRIS files may cause",/informational
     message,"core dumps in readfits! Set the /unzip flag if",/informational
     message,"you have issues with this",/informational
  END
  
  IF keyword_set(unzip) THEN self->ensure_unzipped,paths,rmzip=rmzip
  
  return,paths
END

pro osdc__define
  INT = 0
  OBJ = obj_new()
  PTR = ptr_new()
  STR = ''
  ULONG = 0UL
  LONG = 0L
  dummy = $
     {OSDC,$
      reality:INT,$
      valid:INT,$
      db_conn:OBJ,$
      fs_conn:OBJ,$
      cond:PTR,$
      limit:LONG,$
      page:LONG,$
      show:PTR,$
      order:STR,$
      dir:STR,$
      auth:STR}
END 



PRO osdc_test,o,fetch=fetch
  
  IF NOT obj_valid(o) || ~ obj_isa(o,'osdc') THEN o = obj_new('osdc')
  o->clear
  
  o->condition,'INSTRUME: EIS' 
  o->condition,'OBSTITLE_t: active'    ; Free-text search
  o->condition,'DATE_OBS: <2006/12/20' ; 
  o->condition,'E__TDIM1_1: > 20'      ; First element of TDIM1=(n1,n2,...)
  o->limit,10                          ; Limit to 10 lines for demo, use
                                       ; o->limit,0 for all
  
  o->order,'DATE_OBS',/ascending
  
  o->show,'FILE,OBSTITLE,NAXIS1,E__TDMIN1,E__TDIM1_1' ; We're interested in these
  
  o->status                            ; Show current status
  
  o->search,output                     ; Go find, then show paths, but see below
  print,o->paths(output,fetch=fetch)   ; for a 1-liner if "output" is not needed
  print
  help,output,/structure
  print
  o->status
  
  print
  
  o->condition,'E__TDIM1_1: <= 20'  ; Changes the E__TDIM1_1 condition
  print,o->paths()
  print,"There are now "+trim(o->nmatch())+" matching files
  
  print
  
  ; Juxtaposition of two conditions means AND, so this will select files
  ; between 2006/12/01 and 2006/12/20:
  
  o->condition,'DATE_OBS: >2006/12/01 <2006/12/20'
  o->search
  print,"And now there are only "+trim(o->nmatch())+" files matching"
  
  IF NOT arg_present(o) THEN obj_destroy,o
END
