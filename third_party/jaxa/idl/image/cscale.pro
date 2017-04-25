;+
; Project     : SOHO - CDS     
;                   
; Name        : CSCALE
;               
; Purpose     : my own color scale routine
;               
; Category    : display
;               
; Syntax      : IDL> a=cscale(b)

; Inputs      : ARRAY = input array to scale
;               
; Outputs     : CARRAY = byte scaled array
;               
; Keywords    :
;               TOP = top color index to scale to [def=!d.table_size-1]
;               BOTTOM = bottom color index to scale to [def=0]
;               MIN = min data to scale [def=min(array)]
;               MAX = max data to scale [def=max(array)]
;               MISSING = data to exclude [i.e., set to dmin]
;               NO_COPY = destroy input array
;               REVERSE = reverse color scale min->max
;               LOG     = use log10 scale
;               DRANGE  = same as [min,max]
;               
; History     : Version 1,  17-Jan-1998,  D M Zarro.  Written
;               Modified  24-Nov-1999, Zarro (SM&A/GSFC) - added check
;               for unnecessary call to filt_data
;               Modified  14-March-2000, Zarro (SM&A/GSFC) - fixed
;               bug in use of cmin/cmax
;               Modified  1-Jun-2000, Zarro (EIT/GSFC) - fixed another
;               bug with cmin/cmax
;               Modified  4-Feb-2003, Zarro (EER/GSFC) - added DRANGE
;               Modified  11-Jun-2003: Csillaghy (ETH Zurich) - added /NAN
;               Modified  28-Oct-2003: Zarro (GSI/GSFC) - fixed log scaling bug
;                where positive values below 1 were being ignored.
;               Modified 2-Apr-2007, Zarro (ADNET)
;                - returned used TOP/BOTTOM color limits
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            


function cscale,array,top=top,bottom=bottom,reverse=reverse,$
                      err=err,_extra=extra,crange=crange,obottom=obottom,$
                      otop=otop

carray=dscale(array,_extra=extra,err=err,nok=nok,crange=crange,$
              count=ncount,above=above,acount=acount)

if is_string(err) then return,carray

;-- set color limits

cmax=max(crange,min=cmin)
lmax=!d.table_size-1
if not exist(top) then ctop=lmax else ctop=top < lmax
if not exist(bottom) then cbot=0. else cbot=bottom > 0.
ctop=float(ctop)
cbot=float(cbot)

if keyword_set(reverse) then begin
 temp=ctop & ctop=cbot & cbot=temp
endif

slope=(ctop-cbot)/(float(cmax)-float(cmin))
off=ctop-slope*float(cmax)
carray=slope*float(temporary(carray))+off
carray=nint(temporary(carray))
if ncount gt 0 then carray[nok]=cbot
chk=where( (carray lt cbot) or (carray gt ctop), count)
if count gt 0 then carray[chk]=cbot
if acount gt 0 then carray[above]=ctop
carray=byte(temporary(carray))

obottom=byte(cbot)
otop=byte(ctop)
return,carray
end

