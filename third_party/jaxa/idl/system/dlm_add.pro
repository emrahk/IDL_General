;+
; Project     : VSO
;
; Name        : DLM_ADD
;
; Purpose     : Add OS/platform-specific DLM's
;
; Category    : utility system
;
; Syntax      : IDL> DLM_ADD
;
; Inputs      : PROC (optional) = DLM name (e.g. fmedian) to add.
;               If PROC not entered, all DLM's found under TOP_DIR are added.
;
; Keywords    : TOP_DIR = top directory for binary directory
;                         with DLM's [def = $SSW/gen/dlm]
;               SITE = search SITE directory
;
; Outputs     : None 
;
; History     : Written, 11-Nov-2012, Zarro (ADNET)
;-

pro dlm_add,proc,top_dir=top_dir,verbose=verbose,site=site

verbose=keyword_set(verbose)

case 1 of
 keyword_set(site): dlm_dir=local_name('$SSW/site/dlm')
 is_string(top_dir): dlm_dir=local_name(top_dir)
 is_string(getenv('SSW_DLM_TOP')): dlm_dir=local_name('SSW_DLM_TOP')
 else: dlm_dir=local_name('$SSW/gen/dlm')
endcase

binary_type=!version.os+'.'+!version.arch
dlm_path=concat_dir(dlm_dir,binary_type)
if verbose then message,'Searching '+dlm_path,/info
if ~file_test(dlm_path,/directory) then begin
 if verbose then message,"No DLM's found.",/info
 return
endif

if is_string(proc) then begin
 dlm_name=file_break(proc,/no_exten)
 dlm_file=concat_dir(dlm_path,dlm_name+'.dlm')
 if ~file_test(dlm_file) then begin
  if keyword_set(verbose) then message,'No such file - '+dlm_file,/info
  return
 endif
 count=1
endif else begin
 dlm_file=file_search(concat_dir(dlm_path,'*.dlm'),count=count)
 if count eq 0 then begin
  if verbose then message,"No DLM's found.",/info 
  return
 endif
endelse

if verbose then message,"Found DLM's in - "+dlm_path,/info

for i=0,count-1 do begin
 dlm_register,dlm_file[i]
 dlm_load,file_break(dlm_file[i],/no_exten)
endfor

return & end
