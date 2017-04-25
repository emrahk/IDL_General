;+
; Project     : HESSI
;
; Name        : LIST_GEV
;
; Purpose     : determine GOES events within center/fov
;
; Category    : synoptic
;;
; Syntax      : IDL> list_gev,tstart,tend,center,fov
;
; Inputs      : TSTART, TEND = start/end time range
;               CENTER =[xc,yc] center fov is arcsecs
;               FOV = [xsize,ysize] fov size in arcmin
;
; Outputs     : NOAA = string list, e.g., 1-may-00,N20E30,8311
;
; History     : 6-Nov-2000, D.M. Zarro (EIT/GSFC),  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function list_gev,tstart,tend,center,fov,count=count,all=all

count=0
if not valid_time(tstart) then return,''
if not valid_time(tend) then tend=tstart 

if exist(center) then dcenter=center else dcenter=[0.,0.]
if is_string(dcenter) then dcenter=hel2xy(dcenter) else dcenter=[0.,0.]

if exist(fov) then dfov=fov else dfov=2.*960.
if is_string(dfov) then dfov=str2arr(dfov,delim=',')*60.

gev=get_gev(tstart,tend,count=count,/quiet)

if count eq 0 then return,''

ns=gev.location[1,*]
ew=gev.location[0,*]

if (1-keyword_set(all)) then begin
 xsize=dfov[0]
 if n_elements(dfov) lt 2 then ysize=xsize else ysize=dfov[1]
 xc=dcenter[0]
 yc=dcenter[1]

 xlim=[xc-xsize/2.,xc+xsize/2.]
 ylim=[yc-ysize/2.,yc+ysize/2.]

;-- convert to arcseconds

 ok=where( (abs(ns) le 90) and (abs(ew) le 90),count)
 if count eq 0 then return,''
 gev=gev[ok]
 ns=ns[ok]
 ew=ew[ok]

 xy=hel2arcmin(ns,ew,date=tstart)*60.
 xn=xy[0,*]
 yn=xy[1,*]


 ok=where(  (xn le xlim[1]) and $
            (xn ge xlim[0]) and $
            (yn le ylim[1]) and $
            (yn ge ylim[0]), count)

 if count eq 0 then return,'' 
 gev=gev[ok]

endif

class=trim(string(gev.st$class))
day=trim(gt_day(gev,/str)) & fstart=strmid(trim(gt_time(gev,/str)),0,5)

south=where(ns lt 0,scount)
north=where(ns ge 0,ncount)
east=where(ew lt 0,ecount)
west=where(ew ge 0,wcount)
ns=string(abs(ns),'(i2.2)')
ew=string(abs(ew),'(i2.2)')
if scount gt 0 then ns(south)='S'+ns[south]
if ncount gt 0 then ns(north)='N'+ns[north]
if ecount gt 0 then ew(east)='E'+ew[east]
if wcount gt 0 then ew(west)='W'+ew[west]

loc=ns+ew

result=[day[*]+','+fstart[*]+','+class[*]]
result=arr2str(result,delim='+')


return,result

end
