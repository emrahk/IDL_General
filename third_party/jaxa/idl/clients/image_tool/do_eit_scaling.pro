;+ Project     : SOHO-CDS
;
; Name        : DO_EIT_SCALING
;
; Purpose     : scale EIT images (degrid, take log, etc) 
;
; Category    : planning
;
; Syntax      : data=do_eit_scaling(data,header,index=index)
;
; Inputs      : DATA = data array
;               HEADER = FITS header (if not entered check INDEX)
;
; Opt. Outputs: DATA = scaled EIT data array
;
; Keywords    : INDEX = index structure (used if HEADER not entered)
;               NO_COPY = input data is destroyed to conserve memory
;               LOG = log10 scale image
;               NORMALIZE = normalize images by exposure time
;               NO_PREP = don't explicitly call EIT_PREP 
;               FLIPPED = flag input image was flipped
;
; History     : Written 1 June 1998 D. Zarro, SAC/GSFC
;               1 September 2000 J. Newmark, add response correction for
;                                eit_prep
;               15-Nov-2001, Zarro (EITI/GSFC) - added check for SSW EIT_PREP
;               10-Dec-2001, Zarro (EITI/GSFC) - added check for Astro libs
;               12-Dec-2006, Zarro (L-3Com/GSFC) - added check for prep'ed data
;
; Contact     : dzarro@solar.stanford.edu
;-

function do_eit_scaling,data,header=header,index=index,no_copy=no_copy,$
                        log=log,normalize=normalize,no_prep=no_prep

err=''
no_copy=keyword_set(no_copy)

;-- check inputs

if not exist(data) then begin
 err='Invalid input data'
 pr_syntax,'data=do_eit_scaling(data,header=header,[index=index])
 return,-1
endif

header_input=datatype(header) eq 'STR'
index_input=datatype(index) eq 'STC'

if header_input then begin
 chk=where(strpos(strup(header),'DEGRIDDED') gt -1,count)
 if count gt 0 then begin
  message,'Image already degridded',/cont
  return,data
 endif
endif


;-- check which EIT degridder is available. Ideally use EIT_PREP, but
;   resort to ITOOL_EIT_DEGRID if unavailable

mk_eit_env
have_eit_prep=have_proc('eit_prep')
if not have_eit_prep then begin
 have_eit_dir=is_dir('$SSW/soho/eit/idl')
 if have_eit_dir then add_path,'$SSW/soho/eit/idl',/append,/expand
 have_astro=is_dir('$SSW/gen/idl_libs/astron')
 if have_astro then add_path,'$SSW/gen/idl_libs/astron',/append,/expand
 have_eit_prep=have_proc('eit_prep')
endif

if no_copy then image=copy_var(data) else image=data

;-- flip if input image was flipped (meaning rotated 180)

flipped=0b
if header_input then begin
 chk=where(strpos(header,'CORRECTED FLIP') gt -1,count)
 flipped = count gt 0
 if flipped then begin
  message,'adjusting degridding for 180 deg roll...',/cont
  image=rotate(temporary(image),2)
 endif
endif

;-- if using EIT_PREP and HEADER was input instead of INDEX, then have
;   to convert it

do_prep=1-keyword_set(no_prep)
if do_prep then begin
 have_sswdb=is_dir('$SSWDB/soho/eit/calibrate')
 if have_eit_prep and have_sswdb then begin
  dprint,'% DO_EIT_SCALING: calling EIT_PREP...'
  if (1-index_input) and (header_input) then begin
   eitstr = call_function('eit_struct',ncomment=20)
;   fits_interp,header,index,instruc=eitstr 
   index = fitshead2struct(header,eitstr) 
   index.p1_x = call_function('eit_fxpar',header, 'P1_X')
   index.p2_x = call_function('eit_fxpar',header, 'P2_X')
   index.p1_y = call_function('eit_fxpar',header, 'P1_Y')
   index.p2_y = call_function('eit_fxpar',header, 'P2_Y')
  endif
  call_procedure,'eit_prep',index,data=image,ni,image,normalize=normalize,/response,/no_roll
 endif else begin
  if (1-header_input) then begin
   err='EIT header was not entered'
   message,err,/cont
   return,-1
  endif
  dark=848
  image=temporary(image)-dark
  image=temporary(image) > 0
  image=itool_eit_degrid(temporary(image),header,/no_copy)
 endelse
endif

if keyword_set(log) then begin
 image=temporary(image) > 1.
 image=alog10(temporary(image))
endif

;-- flip back

if flipped then image=rotate(temporary(image),2)

return,image & end

