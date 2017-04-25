;+
; Project     : VSO
;
; Name        : PREP_DATA
;
; Purpose     : PREP byte data using corresponding instrument prep routine
;
; Category    : utility analysis
;
; Inputs      : IDATA = input byte data
;
; Outputs     : ODATA = prepped byte data
;
; Keywords    : EXTRA = prep keywords to pass to prep routine
;               ERR = error string
;               SESSION = session ID for temporary files
;               IFILENAME = filename associated with IDATA
;               OFILENAME = filename associated with ODATA
;
; History     : 25-Dec-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro prep_data,idata,odata,ifilename=ifilename,_ref_extra=extra,err=err,session=session,$
              ofilename=ofilename

odata=!null
err=''
ofilename=''

if ~is_url(idata,/scheme) && ~is_byte(idata) then begin
 err='Only URL or byte streams supported.'
 mprint,err
 return
endif 

;-- temporary location for data files

temp_dir=get_temp_dir()
if is_blank(session) then session=session_id()
tdir=concat_dir(temp_dir,session)
file_mkdir,tdir
ifile=session+'.dat' 

;-- write byte data to temporary file
 
if is_byte(idata) then begin
 uncompress=1b
 if is_string(ifilename) then begin
  ifile=file_basename(ifilename)
  compressed=is_compressed(ifile)
  if compressed then uncompress=0b
 endif
 tifile=concat_dir(tdir,ifile)
 write_stream,tifile,idata,err=err,uncompress=uncompress,_extra=extra
 if is_string(err) then goto,cleanup
endif else tifile=idata

;-- try to prep it

prep_file,tifile,tofile,err=err,_extra=extra,out_dir=tdir

;-- read prepped file back into byte stream

if is_blank(err) then $
 odata=file_stream(tofile,_extra=extra,/compress,err=err)

ofilename=file_basename(tofile)

cleanup: file_delete,tdir,/quiet,/allow,/recursive

return
end
