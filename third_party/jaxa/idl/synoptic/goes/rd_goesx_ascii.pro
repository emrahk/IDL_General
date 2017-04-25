pro rd_goesx_ascii,  t0 , t1, goesx, $
         goes9=goes9, goes8=goes8, goes10=goes10, goes11=goes11,goes12=goes12, $
         goes13=goes13, goes14=goes14, goes15=goes15, $
         files=files, $
         five_minute=five_minute, one_minute=one_minute, $
         remove_bad=remove_bad, $
         plabels=plabels, elabels=elabels,labels_only=labels_only , $
         debug=debug, primary=primary, secondary=secondary
      
;+
;   Name: rd_goesx_ascii
;
;   Purpose: read goes ascii xray files (SEC) and return structure vector
;
;   Input Parameters:
;      t0, t1 - start and stop time desired  
;
;   Output Parameters
;      goesx - vector of goes xray structures between t0 and t1
;
;   Keyword Parameters:
;      goes{8,9,10,12}- data set (satellite) to use - default=/GOES10
;      remove_bad - switch, if set, remove bad/missing data records
;      files (output) - list of ascii file names read
;      elabels (output) - text descriptors of energy bands (plott annotate..) 
;      labels_only - (switch) - if set, just define PLABLES and ELABLES
;                               and exit without reading files 
;      /PRIMARY , /SECONDARY - (after Dec 1 2009 - SEC naming convention change
;                              (as of Now, only /primary is available)
;
;   Calls:
;      table2struct, sel_timrange,  concat_dir, get_logenv, set_logenv,
;      anytim, timegrid, time2file, file_exist, box_message
;   
;   History:
;      16-Dec-2002 - S.L.Freeland - XRay counterpart from  rd_goesp_ascii
;       6-Apr-2002 - S.L.Freeland - fix GOES12 related typo (add quotes)
;      22-jun-2006 - S.L.Freeland - add GOES11 (replace G10 as XR 2ndary default)
;       4-Dec-2009 - S.L.Freeeland - add /PRIMARY & /SECONDARY (SEC Dec 2009 file name change)
;       8-Feb-2011 - Aki Takeda - correct file name (g? -> G?), 
;                               - add GOES15 link to 'Gp_', and
;                               - set 'Gp_' as default sat.id after '26-nov-2009'.
;
;-
common rd_goesx_ascii_blk, strtemplate        ; file/structure template

debug=keyword_set(debug)
elabels=['Low: 1-8A',$
         'High: .5-4A']

if keyword_set(labels_only) then return       ; <<<< UNSTRUCTURED EXIT

; ------------ check input validity -------------------
if n_params() lt 3 then begin
    box_message,["Supply start and stop time and an output parameter...", $
		 "IDL> rd_goesx_ascii, t0, t1, outgoesp [,/goes9, /goes8]"]
    return
endif
; -------------------------------------------------------

primary=keyword_set(primary)
secondary=keyword_set(secondary)
case 1 of                         ; Which data base (satellite)?
  primary: sat='Gp_'
  secondary: sat='Gs_'
  keyword_set(goes8): sat='G8'
  keyword_set(goes9): sat='G9'
  keyword_set(goes10): sat='G10'
  keyword_set(goes12): sat='G12'
  keyword_set(goes11): sat='G11'
  keyword_set(goes14): sat='Gp_'
  keyword_set(goes15): sat='Gp_'
  else: begin
     sat=(['G9','G10'])(ssw_deltat(t1,ref='25-jul-1998') gt 0)       
     sat=([sat,'G11'])(ssw_deltat(t0,ref='21-jun-2006') gt 0)
     sat=([sat,'G10'])(ssw_deltat(t0,ref='1-apr-2009') gt 0)
     sat=([sat,'Gp_'])(ssw_deltat(t0,ref='26-nov-2009') gt 0)
  endcase
endcase  
; -------------------------------------------------------
if is_number(strmid(sat,1,0)) then sat=strupcase(sat)

case 1 of                          ; Time resolution (5 only currently)
   keyword_set(one_minute):  tres='1m' 
   keyword_set(five_minute): tres='5m'
   else: tres= (['5m','1m'])(ssw_deltat(t0,ref=reltime(/now),/day) gt -10)                           
endcase
; -------------------------------------------------------


; ------- define the file path ------------------
goexpenv=get_logenv('SSW_GOESX')
if goexpenv eq '' then begin
   goesxenv=concat_dir(concat_dir('$SSWDB','goes'),'xray')
   set_logenv,'SSW_GOESX',goexpenv
endif
; ------------------------------------------------

; --------- determine file names (assume SEL convention) --------
dategrid=timegrid(t0,reltime(t1,/days),/day)           ; make daily grid
fnames=time2file(dategrid,/date_only)   ; equivilent 'yyyymmdd'
root=sat + 'xr_'+tres+'.txt'
files=concat_dir(goesxenv, fnames+'_'+root)

if ssw_deltat(t1,ref=anytim(reltime(/now),/date_only),/hour) gt 0 then $
    files=[temporary(files),concat_dir(goesxenv,root)]

chk=file_exist(files)
sschk=where(chk,chkcnt)

; ---------------------------------------------------

if chkcnt eq 0 then begin
   box_message,['None of the required files are online...',$
		'   ' + files]
   return
endif   
if debug then stop,'files...'

; --------- define file/structure mapping and read via table2struct ---
if n_elements(strtemplate) eq 0 then strtemplate=$
   {date: intarr(3), sec: 0, mjd: 0L, time: 0L, HI:0., LO:0. }
goesx=table2struct(files(sschk), strtemp=strtemplate, nocom=':,#')
; ---------------------------------------------------

goesx.time=goesx.time*1000l         ; secs->msod (utplot compatible)
goesx=sort_index(goesx)

; ------------- trim times to user inputs --------------------
sst=sel_timrange( anytim(goesx,out='ints'),t0,t1,/between)
if sst(0) eq -1 then begin
  box_message,["No records between your start and stop times"]
  goesx = -1
endif else goesx=goesx(sst)
; ---------------------------------------------------

nrec=n_elements(goesx)

; --------- remove bad/missing records on request ------------
if keyword_set(remove_bad) then begin
   okss=where(total(goesx.lo,1) gt (nrec* 1.e-5),okcnt) ; SEL bad =-10000
   case 1 of 
      okcnt eq nrec:                                   ; all ok
      okcnt eq 0:  begin
         box_message,'No good records between start and stop times'
         goesx=-1
      endcase
      else: begin
         box_message,'Removing ' + strtrim(nrec-okcnt,2) + " missing records"
         goesx=goesx(okss)
      endcase
    endcase
endif
; ---------------------------------------------------

return
end
