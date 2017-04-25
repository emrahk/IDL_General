;+
; Project     : VSO
;
; Name        : GET_FITS_DET
;
; Purpose     : Get detector or instrument name from FITS header
;
; Category    : imaging, FITS
;
; Syntax      : inst=get_fits_det(file)
;
; Inputs      : FILE = FITS file name or header
;
; Outputs     : DET = detector name
;
; Keywords    : PREPPED = 1/0 if file is prepped or not
;               INSTRUMENT = look for instrument before detector
;
; History     : 24 July 2009, Zarro (ADNET) - written
;               23 December 2014, Zarro (ADNET)
;               - read multiple extensions
;               25 November 2014, Zarro (ADNET)
;               - check for HMI
;               31-Dec-2014, Zarro (ADNET) - improved error handling
;               11-Feb-2016, Zarro (ADNET) 
;                - added /INSTRUMENT 
;                - removed instrument-specific references
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_fits_det,file,_ref_extra=extra,err=err,stc=stc,prepped=prepped,$
             quiet=quiet,extension=extension,header=header,instrument=instrument

verbose=~keyword_set(quiet)

err='' & prepped=0b
header=''
if is_blank(file) then begin
 err='Invalid input file name entered.'
 mprint,err
 return,''
endif

;-- check if remote or local file, or header input

if n_elements(file) gt 1 then header=file else begin
; if stregex(file_basename(file),'^tri',/bool) then return,'TRACE'
 if is_url(file,read_remote=read_remote) then begin
  if read_remote then sock_fits,file,header=header,extension=extension,/nodata,_extra=extra,err=err else begin
   err='Cannot determine instrument from header of remote compressed file.'
   return,''
  endelse
 endif else begin
  if is_number(extension) then begin
   mrd_head,file,header,extension=extension,_extra=extra,err=err
  endif else begin
   n_ext=get_fits_extn(file,err=err)
   if is_string(err) then return,''
   if n_ext eq 1 then begin
    mrd_head,file,header,extension=0,_extra=extra,err=err
   endif else begin 
    for i=0,n_ext-1 do begin
     det=get_fits_det(file,extension=i,err=err,_extra=extra,stc=stc,prepped=prepped,$
                       quiet=quiet,instrument=instrument)
     if is_blank(err) then return,det
    endfor
   endelse
  endelse
endelse

 if is_string(err) then begin
  if verbose then mprint,err & return,''
 endif
endelse

;-- look for "standard" keywords

det=''
stc=fitshead2struct(header)
if keyword_set(instrument) then chk=['instr','detec','tele'] else $
  chk=['detec','instr','tele']
for i=0,n_elements(chk)-1 do begin
 if have_tag(stc,chk[i],/start,index) then begin
  tdet=stc.(index)
  if is_string(tdet) then begin
   det=tdet & break
  endif
 endif
endfor

if is_blank(det) then begin
 err='Could not determine detector or instrument.'
 return,''
endif

;-- check if prepped by looking for "Degrid" or "Flat Field" keywords

det=strupcase(det)
prepped=0b
chk=where(stregex(header,'(Flat fielded|Applied Flat Field|Applied Calibration Factor|Prepped|_prep)',/bool,/fold),count)
prepped=count gt 0

return,det
end
