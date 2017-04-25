function flare_hist, time0, time1,  bin_days=bin_days, debug=debug
;
;+
;   Name: flare_hist
;
;   Purpose: return flare class (daily) frequencies for desired time range
;
;   Input Paramters:
;      time0,time1 - time range to consider (def=1980 -> today)
;
;   Output Paramters:
;      function returns structure vector, 1 element per day in range:
;      {time:0l,day:0,nb:0,nc:0,nm:0,nx:0,ntot:0,fmax:'',fmaxt:''}
;
;   History:
;      20-sep-2005 - S.L.Freeland
;
;-   
;
; 
debug=keyword_set(debug)
if n_elements(time0) eq 0 then time0=anytim('1-jan-1980',/ecs)
if n_elements(time1) eq 0 then time1=reltime(/now,out='ecs')
;tgrid=anytim(timegrid(time0,time1,/day),/date_only,out='int')

hstr={time:0l,day:0,nb:0,nc:0,nm:0,nx:0,ntot:0,fmax:'',fmaxt:''}
if n_elements(bin_days) eq 0 then bin_days=1

gev=get_gev(time0,time1)
ss=uniq(gev.day)
ng=n_elements(ss)
retval=replicate(hstr,ng)
retval.time=gev(ss).time
retval.day=gev(ss).day

for i=0,ng-1 do begin ; could do with some vectorization if you get a chance.. 
  class=str2arr('B,C,M,X')
  gevx=gev(where(gev.day eq retval(i).day))
  for c=0,3 do begin 
    retval(i).(c+2)=total(fix(gevx.st$class(0)) eq (byte(class(c)))(0))
    retval(i).ntot=retval(i).ntot+retval(i).(c+2)
    if debug then stop,'gevx
  endfor
  decode_gev,gevx,class=classx,f0,fn,fp
  sclass=classx(sort(classx))
  sss=(where(classx eq last_nelem(sclass)))(0) 
  retval(i).fmax=classx(sss)
  retval(i).fmaxt=fp(sss)
endfor
return,retval
end



