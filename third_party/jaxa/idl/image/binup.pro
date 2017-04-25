;+
; NAME:
;	binup
; PURPOSE:
;	to rebin data into arbitrary dimensions
; CATEGORY:
;       utility
; CALLING SEQUENCE:
;	b=binup(a,m1,m2,m3,m4...m10)
; INPUTS:
;	a= multidimension array
;       m_i = factor by which to rebin i'th dimension
; OPTIONAL INPUT PARAMETERS:
;       none
; OUTPUTS:
;	rebinned array
; OPTIONAL OUTPUT PARAMETERS:
;       none
; SIDE EFFECTS:
;       none    
; RESTRICTIONS:
;      dimensions of input array must not be greater than 10
; PROCEDURE:
;       Uses REBIN function , improved to allow non-integer binning
;       e.g. if a=a(n1,n2,n3) then
;             b=binup(a,m1,m2,m3) = a(n1*m1,n2*m2,n3*m3) if m > 1
;                                 = a(n1/m1,n2/m2,n3/m3) if m <-1
;             b=binup(a,2) will increase first dimension by 2
;             b=binup(a,-2) will decrease first dimension by 2 (i.e. double bin)
; MODIFICATION HISTORY:
;	Written by DMZ (ARC) July 1990
;-

function binup,a,m0,m1,m2,m3,m4,m5,m6,m7,m8,m9

;-- read command line for magnifications (there must be a better way)

nmag=n_params()-1
if n_elements(a) eq 0 then return,0
if (nmag eq 0) then return,a
s=size(a) & ndim=s(0) 
if ndim eq 0 then return,a
mags=0.
for i=0,nmag-1 do begin
 statement='mags=[mags,'+'m'+string(i,'(i1)')+']'
 status=execute(statement)
endfor
mags=mags(1:*)
if nmag gt ndim then mags=mags(0:ndim-1)
if nmag lt ndim then begin
 buff=replicate(1,ndim-nmag) & mags=[mags,buff]
endif
;mags=fix(mags)

;-- now cycle thru each magnification
;   if -1 <= m_i <= 1  then skip
;   if m_i < -1 then decrease dimension by grouping
;   if m_i > 1 then increase dimension by replication

arg1=strarr(ndim) & arg2=arg1
for i=0,ndim-1 do begin
 fac=mags(i) & sk='s('+string(i+1,'(i1)')+')'
 arg1(i) =sk & arg2(i)='*'
 if (fac gt 1) or (fac lt -1) then begin
  mk='mags('+string(i,'(i1)')+')'
  if fac gt 1 then arg1(i)='round('+sk+'*'+mk+')'
  if fac lt -1 then arg1(i)='round('+sk+'/abs('+mk+')'+')'

;-- dimension must be exactly divisible by mag for rebin to work
;   if not then decrease dimension by stripping off ends

  if fac lt -1 then begin
   if abs(fac) gt s(i+1)  then mags(i)=s(i+1)
   nr=s(i+1) mod abs(mags(i)) 
   if nr gt 0 then begin
    if (nr mod 2) ne 0 then begin
     str1=string((nr-1)/2,'(i2)')
     str2=string((nr+1)/2,'(i2)')
     arg2(i)=str1+':'+sk+'-1-'+str2
    endif else begin
     str=string(nr/2,'(i2)')
     arg2(i)=str+':'+sk+'-1-'+str
    endelse
   endif
  endif
 endif
 if i gt 0 then begin arg1(i)=','+arg1(i) & arg2(i)=','+arg2(i) & endif
endfor

sum1='' & sum2=''
for i=0,ndim-1 do begin sum1=sum1+arg1(i) & sum2=sum2+arg2(i) & endfor
sum1=strtrim(sum1,2) & sum2=strtrim(sum2,2)
expr2='b=a('+sum2+')' & expr1='b=rebin(b,'+sum1+')'
status=execute(expr2) & s=size(b) & status=execute(expr1)

return,b
end
