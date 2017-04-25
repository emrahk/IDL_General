;+
; Project     : SOHO-CDS
;
; Name        : FILT_DATA
;
; Purpose     : filter data according to specified criteria
;
; Category    : utility
;
; Syntax      : ij=filt_data(data)
;
; Inputs      : DATA = data array
;
; Outputs     : IJ = indicies of filtered data
;
; Keywords    : MIN = filter out data below DMIN
;               MAX = filter out data above DMAX
;               MISSING = filter out data values that equal MISSING
;               POSITIVE = filter out negative or zero data
;               INVERSE = return indicies of unfiltered data
;               COUNT = # of filtered data values
;               EXCLUDE = filter out these indicies
;               NAN = check for NaNs
;
; History     : Written 16 Feb 1999, D. Zarro, SM&A/GSFC
;               Modified 31 October 2003, Zarro (L-3/GSFC) - added check for NaNs
;
; Contact     : dzarro@solar.stanford.edu
;-
function filt_data,data,min=dmin,max=dmax,inverse=inverse,nan=nan,$
           missing=missing,positive=positive,count=count,exclude=exclude

count=0l
chk=-1
acount=0l
above=-1
if not exist(data) then begin
 pr_syntax,'fdata=filt_data(data,[/pos,missing=missing,dmin=dmin,dmax=dmax])'
 return,chk
endif

pmax=max(data)
if exist(exclude) then begin
 np=n_elements(data)
 ok=where((exclude ge 0) and (exclude lt np),count)
 if (count gt 0) and (count le np) then begin
  exclude=exclude[ok]
  data[exclude]=2*pmax
 endif
endif

dpos=keyword_set(positive)
dmiss=exist(missing)
hmin=exist(dmin)
hmax=exist(dmax)

defsysv,'!values',exists=defined
dnan=keyword_set(nan) and defined
if dnan then fnan=!values.f_nan
lax=[dpos,dmiss,hmin,hmax,dnan]

opp=''
inverse=keyword_set(inverse)
stc_start='chk=where( '
stc=stc_start

if inverse then begin
 s1=' (data le 0) '
 s2=' (data eq missing) '
 s3=' (data lt dmin) ' 
 s4=' (data gt dmax) '
 s5=' (data ne fnan) '
 conn=' or '
endif else begin
 s1=' (data gt 0) '
 s2=' (data ne missing) '
 s3=' (data ge dmin) '
 s4=' (data le dmax) '
 s5=' (data ne fnan) '
 conn=' and '
endelse

stat=[s1,s2,s3,s4]

amp=' '
for i=0,3 do begin
 if lax[i] then begin
  stc=stc+amp+stat[i]
  if (amp eq ' ') then amp=conn
 endif
endfor

if stc ne stc_start then begin
 stc=stc+',count)'
 doexe=execute(stc)
endif

if count eq 1 then chk=chk[0]
return,chk & end

