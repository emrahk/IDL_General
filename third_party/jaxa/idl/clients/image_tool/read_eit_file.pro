;+
; Project     : SOHO-CDS
;
; Name        : READ_EIT_FILE
;
; Purpose     : read EIT files 
;
; Category    : planning
;
; Syntax      : data=read_eit_file(file)
;
; Inputs      : FILE = EIT filename
;
; Opt. Outputs: DATA = EIT data array
;
; Keywords    : HEADER = EIT file header
;               INDEX = index structure (only returned if READ_EIT used)
;
; History     : Written 21 May 1998 D. Zarro, SAC/GSFC
;	       	Version 2, 17-Jun-1997, William Thompson, GSFC
;			Corrected bug with binned EIT files.
;              	Version 3, 7-Jun-1998, Zarro (SM&A/GSFC)
;                       Added check for compressed EIT files
;              	Version 4, 20-Nov-2001, Zarro (EITI/GSFC)
;                       Added check for READ_EIT in !path
;              
; Contact     : dzarro@solar.stanford.edu
;-

function read_eit_file,file,header=header,index=index,err=err

on_error,1
err=''

;-- check inputs

if datatype(file) ne 'STR' then begin
 err='Invalid filename'
 pr_syntax,'data=read_eit_file(file,[header=header])
 return,-1
endif

chk=find_compressed(file,/verb,err=err,status=status)

if chk(0) eq '' then return,-1 else tfile=chk(0)

;-- check which EIT reader is available. Ideally use READ_EIT, but
;   resort to FXREAD if unavailable

mk_eit_env
SSW_EIT_RESPONSE=local_name('$SSW/soho/eit/response')
mklog,'SSW_EIT_RESPONSE',SSW_EIT_RESPONSE

have_read_eit=have_proc('read_eit')
if not have_read_eit then begin
 have_eit_dir=is_dir('$SSW/soho/eit/idl')
 if have_eit_dir then add_path,'$SSW/soho/eit/idl',/append,/expand
 have_read_eit=have_proc('read_eit')
endif

if not have_read_eit then begin
 fxread,tfile,data,header,err=err
 if err ne '' then begin
  message,err,/cont
  return,-1
 endif
 
;-- patch EIT pointing header (bad, bad, kludge)

 naxis1=fxpar(header,'naxis1')
 if naxis1 eq 512 then fxaddpar,header,'crpix1',253.0 $
  else if naxis1 eq 1024 then fxaddpar,header,'crpix1',506.0
 naxis2=fxpar(header,'naxis2')

 if naxis2 eq 512 then fxaddpar,header,'crpix2',257.0 $
  else if naxis2 eq 1024 then fxaddpar,header,'crpix2',514.0

endif else read_eit, tfile, index, data,header=header

if status then rm_file,tfile
return,data & end

