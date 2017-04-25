
pro rd_goesp_ascii,  t0 , t1, goesp, $
         goes9=goes9, goes8=goes8, files=files, $
         goes10=goes10, goes11=goes11, goes12=goes12, $
         five_minute=five_minute, one_minute=one_minute, $
         remove_bad=remove_bad, $
         plabels=plabels, elabels=elabels,labels_only=labels_only , $
         short_labels=short_labels
      
;+
;   Name: rd_goesp_ascii
;
;   Purpose: read goes ascii particle files and return structure vector
;
;   Input Parameters:
;      t0, t1 - start and stop time desired  
;
;   Output Parameters
;      goesp - vector of goes particle structures between t0 and t1
;
;   Keyword Parameters:
;      goes8, goes9 - data set (satellite) to use - default=GOES9
;      remove_bad - switch, if set, remove bad/missing data records
;      files (output) - list of ascii file names read
;      plabels (output) - lables for Protons;  output.p    (6,nn)
;      elabels (output) - lables for Electrons;output.elec (3,nn) 
;      labels_only - (switch) - if set, just define PLABLES and ELABLES
;                               and exit without reading files 
;      short_labels - (switch) - if set, labels are short version
;
;   Calls:
;      table2struct, sel_timrange,  concat_dir, get_logenv, set_logenv,
;      anytim, timegrid, time2file, file_exist, box_message
;
;   History: 
;     19-nov-1997 - S.L.Freeland 
;     17-jul-2000 - S.L.Freeland - add PLABELS and ELABLES output keywords
;     18-Jul-2000 - S.L.Freeland - add /LABELS_ONLY ; make default GOES8 
;                                  following demise of GOES9
;     19-Oct-2001 - S.L.Freeland - include the current (imcomplete)
;                                  files if t1=today
;      8-Mar-2002 - S.L.Freeland - add /SHORT_LABELS keyword and function
;      6-Apr-2003 - S.L.Freeland - add /GOES10 & /GOES12 keyword+function
;     19-jun-2003 - S.L.Freeland - add /GOES11 (still parking but designated Proton primary)
;-
common rd_goesp_ascii_blk, strtemplate        ; file/structure template

shortl=keyword_set(short_labels)

plabels=['Particles at >1 Mev',$
         'Particles at >5 Mev',$  
         'Particles at >10 Mev',$
         'Particles at >30 Mev',$
         'Particles at >50 Mev',$
         'Particles at >100 Mev']

elabels=['Electrons at >0.6 Mev',$
         'Electrons at >2.0 Mev',$
         'Electrons at >4.0 Mev']

if shortl then begin 
   plabels=str_replace(plabels,'Particles at','p')
   elabels=str_replace(elabels,'Electrons at','e')
endif

if keyword_set(labels_only) then return       ; <<<< UNSTRUCTURED EXIT

; ------------ check input validity -------------------
if n_params() lt 3 then begin
    box_message,["Supply start and stop time and an output parameter...", $
		 "IDL> rd_goesp_ascii, t0, t1, outgoesp [,/goes9, /goes8]"]
    return
endif
; -------------------------------------------------------

case 1 of                         ; Which data base (satellite)?
  ssw_deltat(t1,ref='1-may-2010') gt 0: begin
     box_message,'SEC file name change (sat#->p/s)
     sat='Gp_'
   endcase

  keyword_set(goes8): sat='G8'
  keyword_set(goes9): sat='G9'
  keyword_set(goes10): sat='G10'
  keyword_set(goes11): sat='G11'
  keyword_set(goes12): sat='G12'
  else: begin 
     sat=(['G9','G8'])(ssw_deltat(t1,ref='25-jul-1998') gt 0)
     sat=([sat,'G10'])(ssw_deltat(t1,ref= '8-apr-2003') gt 0) ; GOES 8 OFF
     sat=([sat,'G11'])(ssw_deltat(t1,ref='19-jun-2003') gt 0) ; GOES 11 P primary
  endcase
endcase  
; -------------------------------------------------------

case 1 of                          ; Time resolution (5 only currently)
   keyword_set(one_minute): $
      box_message,'Only 5 minute data available' ; tres='1m'
   keyword_set(five_minute): tres='5m'
   else: tres='5m'                            
endcase
tres='5m'      ; (** remove when 1 minute availble **)
; -------------------------------------------------------


; ------- define the file path ------------------
goespenv=get_logenv('SSW_GOESP')
if goespenv eq '' then begin
   goespenv=concat_dir(concat_dir('$SSWDB','goes'),'particle')
   set_logenv,'SSW_GOESP',goespenv
endif
; ------------------------------------------------

; --------- determine file names (assume SEL convention) --------
dategrid=timegrid(t0,reltime(t1,days=1),/days)   ; make daily grid
fnames=time2file(dategrid,/date_only)   ; equivilent 'yyyymmdd'
root=sat+'part_'+tres+'.txt'
files=concat_dir(goespenv, fnames+'_'+root)

if ssw_deltat(t1,ref=anytim(reltime(/now),/date_only),/hour) gt 0 then $
    files=[temporary(files),concat_dir(goespenv,root)]

chk=file_exist(files)
sschk=where(chk,chkcnt)

; ---------------------------------------------------

if chkcnt eq 0 then begin
   box_message,['None of the required files are online...',$
		'   ' + files]
   return
endif   

; --------- define file/structure mapping and read via table2struct ---
if n_elements(strtemplate) eq 0 then strtemplate=$
   {date: intarr(3), sec: 0, mjd: 0L, time: 0L, p: fltarr(6), elec: fltarr(3)}
goesp=table2struct(files(sschk), strtemp=strtemplate, nocom=':,#')
; ---------------------------------------------------

goesp.time=goesp.time*1000l         ; secs->msod (utplot compatible)

; ------------- trim times to user inputs --------------------
sst=sel_timrange( anytim(goesp,out='ints'),t0,t1,/between)
if sst(0) eq -1 then begin
  box_message,["No records between your start and stop times"]
  goesp = -1
endif else goesp=goesp(sst)
; ---------------------------------------------------

nrec=n_elements(goesp)

; --------- remove bad/missing records on request ------------
if keyword_set(remove_bad) then begin
   okss=where(total(goesp.p,1) gt (nrec* 1.e-5),okcnt) ; SEL bad =-10000
   case 1 of 
      okcnt eq nrec:                                   ; all ok
      okcnt eq 0:  begin
         box_message,'No good records between start and stop times'
         goesp=-1
      endcase
      else: begin
         box_message,'Removing ' + strtrim(nrec-okcnt,2) + " missing records"
         goesp=goesp(okss)
      endcase
    endcase
endif
; ---------------------------------------------------

return
end
