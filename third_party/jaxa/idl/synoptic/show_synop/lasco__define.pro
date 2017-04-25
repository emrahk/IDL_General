;+
; Project     : SOHO
;
; Name        : LASCO__DEFINE
;
; Purpose     : Object class definition for SOHO/LASCO
;
; Category    : Objects
;
; History     : 15-June-2010, Zarro (ADNET) - written
;               6-Feb-2016, Zarro (ADNET) 
;               - resuscitated by adding FESTIVAL and NRLGEN packages
;                 (warning NRLGEN has lots of conflicts with GEN)
;
; Contact     : dzarro@solar.stanford.edu
;- 

function lasco::init,_ref_extra=extra

if ~self->fits::init(_extra=extra) then return,0

;-- setup environment

self->setenv,_extra=extra

return,1 & end

;---------------------------------------------------

function lasco::search,tstart,tend,_ref_extra=extra

return,vso_files(tstart,tend,inst='lasco',_extra=extra)

end


;-----------------------------------------------------------------------------
;-- check for LASCO branch in !path

function lasco::have_path,err=err,verbose=verbose

err=''
if ~have_proc('lasco_readfits') then begin
 ssw_path,/lasco,/quiet
 if ~have_proc('lasco_readfits') then begin
  err='SOHO/LASCO branch of SSW not installed.'
  if keyword_set(verbose) then mprint,err
  return,0b
 endif
endif

return,1b
end

;-----------------------------------------------------------------------------
;-- check for LASCO_PREP in !path

function lasco::have_prep,err=err,verbose=verbose

err=''
if ~have_proc('lasco_prep') then begin
 ssw_path,/festival,/quiet
 if ~have_proc('lasco_prep') then begin
  err='Festival package of SSW not installed.'
  if keyword_set(verbose) then mprint,err
  return,0b
 endif
endif

;-- also need NRLGEN package

nrlgen=local_name('/packages/nrl/idl/nrlgen')
pos=strpos(!path,nrlgen)
if pos gt -1 then return,1b

nrlgen=local_name('$SSW/packages/nrl/idl/nrlgen')
if ~file_test(nrlgen,/dir) then begin
 err='NRLGEN package of SSW not installed.'
 mprint,err
 return,0b
endif

ssw_path,/nrl,/quiet
return,1b
end

;---------------------------------------------------------------------
pro lasco::read,file,index,data,_ref_extra=extra,err=err,no_prep=no_prep,$
                roll_correct=roll_correct

err=''
roll_correct=keyword_set(roll_correct)
self->getfile,file,local_file=rfile,err=err,_extra=extra,count=count
if (count eq 0) || is_string(err) then return

;-check for required modules

self->check_path,have_path,have_prep,_extra=extra
if ~have_path then mprint,'LASCO library not installed. Using standard FITS readers.'
if ~have_prep then mprint,'LASCO Prep routines not installed. Not prepping.'

catch,error
if error ne 0 then begin
 catch,/cancel
 err=err_state()
 mprint,err
 return
endif

self->empty
k=0
for i=0,count-1 do begin
 err=''
 if ~self->is_valid(rfile[i],prepped=prepped) then begin
  err='Not a valid SOHO/LASCO file - '+rfile[i]
  mprint,err
  continue
 endif

 if have_path then begin
  if have_prep && ~keyword_set(no_prep) then lasco_prep,rfile[i],index,data,_extra=extra else $
   data=call_function('lasco_readfits',rfile[i],index,_extra=extra)
 endif else mreadfits,rfile[i],index,data,_extra=extra

 if (size(data,/n_dim) ne 2) || ~is_struct(index) then begin
  err='Error reading - '+rfile[i] 
  mprint,err & continue
 endif
 self->mk_map,index,data,k,_extra=extra,filename=rfile[i],err=err
 if is_string(err) then continue
 if roll_correct then self->rotate,angle,k,roll_angle=0,_extra=extra,err=err
 self->colors,k
 k=k+1
endfor

return & end

;-----------------------------------------------------------------------

pro lasco::colors,k

;-- load colors

index=self->get(k,/index)

if ~is_struct(index) then return
det=strupcase(index.detector)
dsave=!d.name
set_plot,'z'

tvlct,rold,gold,bold,/get
case det of
 'C1': loadct,8,/silent
 'C2': loadct,3,/silent
 'C3': loadct,1,/silent
 else: do_nothing=1
endcase

tvlct,red,green,blue,/get
tvlct,rold,gold,bold

set_plot,dsave

self->set,k,red=red,green=green,blue=blue,/has_colors

return & end

;-----------------------------------------------------------------------
;-- check LASCO library paths

pro lasco::check_path,have_path,have_prep,_ref_extra=extra

forward_function scc_sun_center
have_path=self->have_path(_extra=extra)
have_prep=self->have_prep(_extra=extra)

return & end

;------------------------------------------------------------------------
;-- setup LASCO environment variables

pro lasco::setenv,_extra=extra

mklog,'$SSW_LASCO','$SSW/soho/lasco',/local
file_env=local_name('$SSW_LASCO/setup/setup.lasco_env')
file_setenv,file_env,_extra=extra
mklog,'$NRL_LIB','$SSW_LASCO',/local
mklog,'$MONTHLY_IMAGES','$SSWDB/soho/lasco/monthly',/local

return & end

;------------------------------------------------------------------------

function lasco::is_valid,file,prepped=prepped

prepped=0b
if is_blank(file) then return,0b
mrd_head,file,header,err=err
if is_string(err) then return,0b
s=fitshead2struct(header)
if have_tag(s,'instrume') then if stregex(s.instrume,'LASCO',/bool,/fold) then return,1b
return,0b
end

;--------------------------------------------------------------------------
;-- make normalized image map

pro lasco::mk_img,file,bmin,bmax,_ref_extra=extra,err=err

self->check_path

if ~have_proc('mk_img') then begin
 err='NRLGEN package required.'
 return
endif

if is_blank(file) then dfile='' else dfile=file
if ~file_test(dfile) then begin
 err='Missing input file name.'
 mprint,err
 return
endif 

if ~is_number(bmin) then bmin=.9
if ~is_number(bmax) then bmax=1.3

img=call_function('mk_img',dfile,bmin,bmax,header,/use_mod,/ratio,/mask_,/roll,/do_bytscl,/no_disp) 
wdel,6
index2map,header,img,map
self->set,map=map
self->set,index=header

return & end

;------------------------------------------------------

pro lasco__define,void                 

void={lasco, inherits fits, inherits prep}

return & end
