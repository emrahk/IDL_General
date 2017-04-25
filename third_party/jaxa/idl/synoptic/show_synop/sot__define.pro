;+
; Project     : SOT
;
; Name        : SOT__DEFINE
;
; Purpose     : Class definition for SOT
;
; Category    : Objects
;
; History     : 7 September 2015 Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

;---------------------------------------------------

function sot::init,_ref_extra=extra

if ~self->fits::init(_extra=extra) then return,0
self->setenv,_extra=extra
return,1

end

;---------------------------------------------------

function sot::search,tstart,tend,_ref_extra=extra

return,vso_files(tstart,tend,_extra=extra,window=30,$
         spacecraft='Hinode',inst='SOT',det='FG',/recover_urls)

end

;---------------------------------------------------

pro sot::read,file,_ref_extra=extra,err=err

err=''
self->getfile,file,local_file=rfile,err=err,_extra=extra,count=count
if (count eq 0) || is_string(err) then return

self->empty
have_path=self->have_path()
k=-1
for i=0,count-1 do begin
 chk=get_fits_det(rfile[i])
 if ~stregex(chk,'SOT',/bool,/fold) then begin
  err='Input file not a SOT dataset - '+rfile[i]
  mprint,err
  continue
 endif
 if self->have_path() then begin
  read_sot,rfile[i],index,data,_extra=extra
  if stregex(index.obs_type,'FG',/bool,/fold) then begin
   fg_prep,index,data,oindex,odata,_extra=extra
   if ~is_struct(oindex) then begin
    err='Problem prepping FG data.'
    mprint,err
    continue
   endif
   index=oindex & data=temporary(odata)
  endif
 endif else mreadfits,rfile[i],index,data,_extra=extra
 if stregex(index.obs_type,'SP',/bool,/fold) then begin
  err='SP data not currently supported.'
  mprint,err
  continue
 endif
 k=k+1
 self->mk_map,index,data,k,_extra=extra,filename=rfile[i]
 self->set,k,grid=30,/limb
endfor

return 
end

;-----------------------------------------------------------------------------
;-- check for SOT branch in !path

function sot::have_path,err=err,verbose=verbose

err=''
if ~have_proc('read_sot') then begin
 ssw_path,/sot,/quiet
 if ~have_proc('read_sot') then begin
  err='SOT branch of SSW not installed.'
  if keyword_set(verbose) then message,err,/info
  return,0b
 endif
endif

return,1b
end

;------------------------------------------------------
;-- setup SOT environment variables

pro sot::setenv,_extra=extra

if is_string(chklog('SOT_CALIBRATION')) then return
mklog,'$SSW_SOT','$SSW/hinode/sot',/local
file_env=local_name('$SSW/hinode/sot/setup/setup.sot_env')
file_setenv,file_env,_extra=extra
return & end

;------------------------------------------------------
pro sot__define,void                 

void={sot, inherits fits, inherits prep}

return & end
