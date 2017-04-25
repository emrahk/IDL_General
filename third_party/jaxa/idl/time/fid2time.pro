;+
; Project     : SOHO - SUMER
;
; Name        : FID2TIME
;
; Purpose     : Infer file time from file ID name with "_yymmdd_hhmmss"
;
; Category    : I/O
;
; Explanation : Same as EXTRACT_FID, but sets missing elements to 0
;
; Syntax      : IDL> times=fid2time(files)
;
; Inputs      : FILES = file names (e.g. sum_961020_201023.fits)
;
; Opt. Inputs : None
;
; Outputs     : TIMES = string times (e.g. 20-Oct-96 20:10:23)
;
; Opt. Outputs: None
;
; Keywords    : DELIM = time delimiter (def= '_')
;               TAI = return time in TAI format
;               YMD = return yymmdd
;               COUNT= number of files processed
;               DATE_ONLY = return date only
;               NO_MIN = exclude MIN and SEC
;               NO_SEC = exclude sec
;               ;
; History     : Version 1,  20-May-1998, Zarro (SM&A) - written
;               Version 2,  1-Feb-1999, Zarro - made Y2K compliant
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
;

function fid2time,files,delim,tai=tai,ymd=ymd,err=err,count=count,$
                  index=index,verbose=verbose,date_only=date_only,no_min=no_min,$
                  no_sec=no_sec,full=full

count=0
on_error,1
err=''
verbose=keyword_set(verbose)

if datatype(files) ne 'STR' then begin
 pr_syntax,'times=fid2time(files,[delim,tai=tai])'
 err='invalid input'
 return,''
endif

dprint,'% FID2TIME'
nf=n_elements(files)
times=strarr(nf)
ymd=strarr(nf)
if keyword_set(tai) then times=dblarr(nf) 
mons=['Jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']


if datatype(delim) ne 'STR' then delim='_'
blim=byte(delim)
for i=0l,nf-1 do begin
 break_file,trim2(files(i)),fdsk,fdir,fname,fext
 temp=byte(fname)
 nt=n_elements(temp)
 chk=where(blim(0) eq temp,count)
 if count gt 0 then begin
  if count gt 2 then f1=chk(count-2) else f1=chk(0)
  if ((f1+1) lt nt) and ((f1+2) lt nt) then yy=string(temp(f1+1:f1+2)) else yy=''
  if ((f1+3) lt nt) and ((f1+4) lt nt) then mm=string(temp(f1+3:f1+4)) else mm=''             
  if ((f1+5) lt nt) and ((f1+6) lt nt) then dd=string(temp(f1+5:f1+6)) else dd='00'

;-- Y2K correction

  if (yy eq '19') or (yy eq '20') then begin
   yy=mm & mm=dd 
   if ((f1+7) lt nt) and ((f1+8) lt nt) then dd=string(temp(f1+7:f1+8)) else dd='00'
  endif

;-- use 50 as pivot year

  if strlen(yy) eq 2 then begin
   if (yy ge '50') and (yy le '99') then full_yy='19'+yy else full_yy='20'+yy
  endif

  hh='00' & min='00' & ss='00'
  if count gt 1 then begin   
   if count gt 2 then f2=chk(count-1) else f2=chk(1)
   if ((f2+1) lt nt) and ((f2+2) lt nt) then hh=string(temp(f2+1:f2+2)) 
   if ((f2+3) lt nt) and ((f2+4) lt nt) then min=string(temp(f2+3:f2+4)) 
   if ((f2+5) lt nt) and ((f2+6) lt nt) then ss=string(temp(f2+5:f2+6)) 
  endif

  if is_number(mm) then begin
   mon=fix(mm)
   if (mon ge 1) and (mon le 12) and (yy ne '') and (dd ne '') then begin
    string_mon=get_month(mon-1,/trun)
    time=dd+'-'+string_mon+'-'+full_yy
    if (1-keyword_set(date_only)) then begin
     time=time+' '+hh 
     if (1-keyword_set(no_min)) then begin
      time=time+':'+min
      if (1-keyword_set(no_sec)) then time=time+':'+ss
     endif
    endif
    err=''
    ymd(i)=yy+mm+dd
    if keyword_set(full) then ymd(i)=full_yy+mm+dd

    if keyword_set(tai) then ftime=anytim2tai(time,err=err) else $
;     ftime=anytim2utc(time,err=err,/vms) 
     ftime=time
    if err eq '' then times(i)=ftime
   endif
  endif
 endif
endfor

nf=n_elements(times)
if nf eq 1 then begin 
 times=times(0)
 ymd=ymd(0)
endif

terr='filename(s) do not use minimum IAU naming conventions: yymmdd_hhdd'
if datatype(times) eq 'STR' then $
 index=where(trim2(times) ne '',count) else $
  index=where(times gt 0.,count) 
if (count lt nf) then begin
 err=terr & if verbose then message,err,/cont
endif
if count eq 0 then err=terr

return,times & end



