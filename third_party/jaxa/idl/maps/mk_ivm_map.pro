;+
; Project     : SOHO-CDS
;
; Name        : MK_IVM_MAP
;
; Purpose     : Make an image map from a Imaging Vector Magnetograph (IVM) data
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : map=mk_ivm_map(file)
;               map=mk_ivm_map(data,header)
;
; Examples    :
;
; Inputs      : FILE = FITS file name (or FITS data + HEADER)
;
; Opt. Inputs : None
;
; Outputs     : MAP = map structure from MK_MAP
;
; Opt. Outputs: None
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 22 January 1997, D. Zarro, ARC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_ivm_map,data,header,stc=stc

;-- check inputs

if datatype(data) eq 'STR' then begin
 fl=loc_file(data,count=count,err=err)
 if count eq 0 then begin
  message,err,/cont & return,0
 endif
 file=fl(0)
 err=''
 fxread,file,fdata,fhead,err=err
 if err ne '' then begin
  message,err,/cont
  return,0
 endif
endif else begin
 if exist(data) then fdata=data
 if datatype(header) eq 'STR' then fhead=header
endelse

if (not exist(fdata)) or (not exist(fhead)) then begin
 pr_syntax,'map=mk_ivm_map(data,header)'
 return,0
endif

;-- extract pointing stuff

stc=head2stc(fhead)
dx=float(stc.cdelt1)
dy=float(stc.cdelt2)
xcen=float((stc.naxis1+1)*dx)/2.
ycen=float((stc.naxis2+1)*dy)/2.
xorg=float(stc.crpix1)*dx
yorg=float(stc.crpix2)*dy
xc=xcen-xorg
if tag_exist(stc,'crval1') then xc=xc+stc.crval1
yc=ycen-yorg
if tag_exist(stc,'crval2') then yc=yc+stc.crval2

if tag_exist(stc,'INSTRUME') then inst=trim(stc.instrume) else inst=''
if tag_exist(stc,'DETECTOR') then det=trim(stc.detector)  else det=''

r=anytim2tai('1-jan-1970')
time=''
if tag_exist(stc,'date_obs') then time=anytim2utc(stc.date_obs,/ecs,/vms) 
if time eq '' then begin
 if tag_exist(stc,'start') then begin
  t1=stc.start+stc.start_f/100.d0+21.d
  time=anytim2utc(r+double(t1),/vms)
 endif
endif
tstart=time
 
tend=''
if tag_exist(stc,'date_end') then tend=anytim2utc(stc.date_end,/ecs,/vms) 
if tend eq '' then begin
 if tag_exist(stc,'stop') then begin
  t2=stc.stop+stc.stop_f/100.d0+21.d
  tend=anytim2utc(r+double(t2),/vms)
 endif
endif

dur=0.
if dur eq 0. then begin
 if (tstart ne '') and (tend ne '') then begin
  dur=anytim2tai(tend)-anytim2tai(tstart)
 endif
endif
if tag_exist(stc,'wavelnth') then wave=stc.wavelnth else wave=''
id=trim(inst+' '+det+' '+wave)

bz=fdata(*,*,1)*.1
;jz=fdata(*,*,13)*.01
bt=fdata(*,*,2)*.1

;-- use heliographic coords

use_earth_view
sz=size(data)
nx=sz(1) & ny=sz(2)
lat=data(*,*,6)*.001
lon=data(*,*,7)*.001 
c=hel2arcmin(lat,lon,date=time,soho=0)
xc=reform(c(0,*),nx,ny)*60. 
yc=reform(c(1,*),nx,ny)*60.
map=make_map(bz,xc=xc,yc=yc,time=time,dur=float(dur),id=id,soho=0,/old)

return,map


end
