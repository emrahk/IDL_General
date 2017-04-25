pro read_ace, acefiles, data, delete_quality=delete_quality, valid=valid, debug=debug
;
;   Name: read_ace
;
;   Purpose: read one or more ACE ascii files -> SSW structure (utplot et al)
;
;   Input Parameters:
;      acefiles - ACE ascii data (per sec / SSWDB)
;                 (for example, ace_files.pro output)
;   
;   Output Parameters:
;      data - SSW/utplot compatible data structures
;      valid - if set, remove missing/bad data (SEC flag -9999.9)
;
;
;   History:
;      5-Sep-2001 - S.L.Freeland
;      6-Sep-2001 - S.L.Freeland - out.TIME seconds->milliseconds per SSW
;                                  add VALID keyword and function
;     26-Sep-2001 - S.L.Freeland - enable EPAM, SIS, and MAG files
;      2-Oct-2001 - S.L.Freeland - sort & remove duplicates (via sort_index.pro)       
;     27-Nov-2001 - S.L.Freeland - fix MAG template
;     15-Oct-2008 - W.T.Thompson - check for corrupted or missing files
;
;
;   Restrictions:
;      Only one type of ace instrument files per call
;      (swepam, epam, sis or mag) 
;      (SWEPAM only restriction lifted 26-Sep)
;
;-

data=-1
debug=keyword_set(debug)
delete_quality=keyword_set(delete_quality)

if not data_chk(acefiles,/string) then begin 
   box_message,'Need to supply one or more file names'
   return
endif

typechk=strextract(acefiles,'ace_','_')
utype=uniq(typechk)

if n_elements(utype) gt 1 then begin 
   box_message,'Only one ACE instrument type per call..'
   return
endif

case typechk(0) of 

   'swepam': strtemp=$
       {mjd:0L,time:0L,s:0b,p_density:0.0,b_speed:0.0,ion_temp:0.0d}

   'epam': strtemp=$
       {mjd:0L,time:0L,s:0b,e38_53:0.0d, e175_315:0.0d, $
          s1:0b, p47_65:0.0d, p112_187:0.0d, p310_580:0.0d, $
                 p761_1220:0.0d, p060_1910:0.0d, anis_ratio:0.0}

   'sis': strtemp=$
       {mjd:0L,time:0L,s:0b,p_gt10mev:0.0d, s1:0b, p_gt30mev:0.0d}

   'mag': strtemp=$
       {mjd:0L,time:0L,s:0b,bx:0.0,by:0.0,bz:0.0,bt:0.0,lat:0.0,long:0.0}

   else: begin
      box_message,'Unrecognized ACE data files'
      return
   endcase
endcase
                            
data=rd_tfiles(acefiles)               ; read all ascii files->array

jd=max(strpos(data,'Julian'))          ; 1st column of interest
if jd lt 0 then begin
    box_message, 'Corrupted or missing ACE data files'
    data = -1
    return
endif
data=strnocomment(data,comm='#')       ; decommment
data=strtrim(strmids(data,jd),2)       ; trim
ldata=strlen(data)
hl=histogram(ldata,min=0)
ok=where(hl eq max(hl))
ss=where(ldata eq ok(0))            ; eliminate bad format data

data=data(ss)

; conver ascii->structure using instrument structure template
out=table2struct(data, strtemplate=strtemp)

out.time=out.time*1000.                    ; seconds -> ssw millisecond

; optionally filter out invalid/missing data ; out.S , out.S1, ... out.SN
if keyword_set(valid) then begin           
   validm=intarr(n_elements(out))+1             
   tnames=tag_names(strtemp)
   qtags=where(strmid(tnames,0,1) eq 'S' and strlen(tnames) le 2,qcnt)   
   for i=0,qcnt-1 do validm=validm and out.(qtags(i)) eq 0
   vss=where(validm,vcnt)
   if vcnt gt 0 then out=out(vss) else out=-1
   if delete_quality and qcnt gt 0 then $
       out=str_subset(temporary(out),tnames(qtags),/exclude)
endif

if debug then stop


if data_chk(out,/struct) then begin
   data=temporary(out) 
   data=sort_index(temporary(data),/uniq)
endif else box_message,'Problem decoding ascii->structure'


return
end
