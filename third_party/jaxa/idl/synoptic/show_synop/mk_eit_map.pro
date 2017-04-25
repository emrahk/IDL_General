;+
; Project     : SOHO-CDS
;
; Name        : MK_EIT_MAP
;
; Purpose     : Make an image map from EIT FITS data
;
; Category    : imaging
;
; Syntax      : map=mk_eit_map(data,header) or mk_eit_map(index,data)
;
; Inputs      : DATA,HEADER = FITS image/header combination
;               INDEX,DATA  = index/data combination
;
; Outputs     : MAP = map structure
;
; Keywords    : SUB = set to compute subarray
;               OUTSIZE = output size of data
;
; History     : Written 22 January 1997, D. Zarro, ARC/GSFC
;               Modified 31 Oct 2000, Zarro (EIT/GSFC) - added file input option;               Modified July 9, 2003 Zarro (EER/GSFC) - check SOHO orientation
;
; Contact     : dzarro@solar.stanford.edu
;-


function mk_eit_map,index,data,sub=sub,$
            outsize=outsize,_extra=extra

data_head=(datatype(data) eq 'STR') and (size(index))(0) eq 2
index_data=(datatype(index) eq 'STC') and $
           (data_chk(index,/nx) eq (data_chk(data,/nim)))
file_index=datatype(index) eq 'STR'


if (1-data_head) and (1-index_data) and (1-file_index) then begin
 pr_syntax,'eit_map=mk_eit_map(data,header) or mk_eit_map(index,data) or mk_eit_map(file)'
 return,-1
endif

if file_index then begin
 chk=loc_file(index,count=count,err=err)
 if count eq 0 then begin
  message,err,/cont
  return,-1
 endif
 read_eit,index,nindex,ndata
 eit_prep,nindex,data=ndata,ti,td,_extra=extra
endif
                     

;-- INDEX/DATA is the preferred new way

if index_data or file_index then begin
 if file_index then args='ti,td' else args='index,data'
 state='index2map,'+args+',map,sub=sub,outsize=outsize,/positive,/soho,_extra=extra'
 s=execute(state)
 nmap=n_elements(map)
 roll_center=make_array(2,nmap,/float)
 add_prop,map,roll_center=roll_center,/replace
 return,map
endif

;-- decode header (this is the old way)

get_fits_par,data,xc,yc,dx,dy,time=time,stc=stc,err=err
if err ne '' then return,-1

;-- rebin image?

image=index
if exist(outsize) then begin
 msize=float([outsize(0),outsize(n_elements(outsize)-1)])
 sz=float(size(index))
 if (sz(1) ne msize(0)) or (sz(2) ne msize(1)) then begin
  image=congrid(temporary(image),msize(0),msize(1))
  dx=dx*sz(1)/msize(0)
  dy=dy*sz(2)/msize(1)
 endif
endif

;-- extract sub-array

if keyword_set(sub) then begin
 exptv,alog10(index > .01)
 wshow
 sub_data=temporary(tvsubimage(image,x1,x2,y1,y2))
 delvarx,sub_data
 sub_array=[x1,x2,y1,y2]
endif

;-- make map
 
map=make_map(temporary(image) > 0,xc=xc,yc=yc,dx=dx,dy=dy,time=time,dur=float(stc.exptime),$
     id='EIT:'+num2str(stc.wavelnth),/soho,sub=sub_array,_extra=extra)

return,map & end

