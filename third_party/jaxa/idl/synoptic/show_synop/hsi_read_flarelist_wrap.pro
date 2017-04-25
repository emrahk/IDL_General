;+
; Project     : HESSI
;
; Name        : HSI_READ_FLARELIST_WRAP
;
; Purpose     : IDL-IDL Bridge wrapper around HSI_READ_FLARELIST
;               to read RHESSI flare catalog in background thread.
;
; Category    : RHESSI utility
;
; Syntax      : IDL> hsi_read_flarelist_wrap
;
; Inputs      : None
;
; Outputs     : None
;               There is no direct output since this procedure is called
;               by hsi_read_flarelist_thread. Once it has completed 
;               reading the flare catalog, it populates the common block:
;               common hsi_flarelist, flare_data, flare_info
;               with the corresponding catalog data. It does this by
;               using save/restore to copy the data from the child
;               process to the parent process.  
;
; Keywords    : VERBOSE = set for verbose output
;
; History     : 27-Oct-2010, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro hsi_read_flarelist_wrap,_extra=extra,verbose=verbose

verbose=keyword_set(verbose)

squiet=!quiet
!quiet=~verbose
flare_data=hsi_read_flarelist(info=flare_info,/pointer,_extra=extra)

if exist(flare_data) and exist(flare_info) then begin
  temp_file=concat_dir(get_temp_dir(),'hsi_flarelist.sav')
  save,flare_data,flare_info,file=temp_file
  file_chmod,temp_file,/a_write,/a_read
  if verbose then message,'Saved to '+temp_file,/cont
endif
!quiet=squiet

return
end
