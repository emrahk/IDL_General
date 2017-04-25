;+
; Project     : HESSI
;
; Name        : LIST_NAR
;
; Purpose     : determine NOAA AR's within center/fov
;
; Category    : synoptic
;
;
; Syntax      : IDL> list_nar,tstart,tend,center,fov
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


function list_nar,tstart,tend,center,fov,count=count,tol=tol,all=all

count=0
if not valid_time(tstart) then return,''
if not valid_time(tend) then tend=tstart

if exist(center) then dcenter=center else dcenter=[0.,0.]
if is_string(dcenter) then dcenter=hel2xy(dcenter) else dcenter=[0.,0.]

if exist(fov) then dfov=fov else dfov=2.*960.
if is_string(dfov) then dfov=str2arr(dfov,delim=',')*60.

nar=get_nar(tstart,tend,count=count,/quiet,/unique)

if count eq 0 then return,''

ok=where(nar.noaa gt 0,count)
if count eq 0 then return,''
nar=nar[ok]

if (1-keyword_set(all)) then begin

 if is_number(tol) then dtol=tol else dtol=20.
 dtol=1.+dtol/100.

 dfov=dfov*dtol
 xsize=dfov[0]
 if n_elements(dfov) lt 2 then ysize=xsize else ysize=dfov[1]
 xc=dcenter[0]
 yc=dcenter[1]

 xlim=[xc-xsize/2.,xc+xsize/2.]
 ylim=[yc-ysize/2.,yc+ysize/2.]

 xn=nar.x
 yn=nar.y

;-- overlapping NOAA regions

 ok=where(  (xn le xlim[1]) and $
            (xn ge xlim[0]) and $
            (yn le ylim[1]) and $
            (yn ge ylim[0]), count)

 if count eq 0 then return,'' 

 nar=nar[ok]
endif

ns=nar.location[1,*]
ew=nar.location[0,*]
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
ndate=trim2(gt_day(nar,/str))
name=trim2(nar.noaa)

result=[ndate[*]+','+loc[*]+','+name[*]]
result=arr2str(result,delim='+')


return,result

end

