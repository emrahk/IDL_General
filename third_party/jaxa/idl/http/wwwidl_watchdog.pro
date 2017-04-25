function wwwidl_watchdog, watch_file, value, outdir=outdir, $
			  update=update, check=check, loud=loud
;+
;
;    Name: wwwidl_watchdog
;
;    Purpose: perform a watchdog check (update or read/compare)
;
;    Input Parameter:
;       watch_file - file to update
;                  ; default=$SSW_SITE_LOGS/wwwidl_watchdog_<host>_0X2010CAFE
;       value - (update or readback check) 
;  
;    History:
;       7-May-1999 - S.L.Freeland - for IDL/WWW server health check
;-  
update=keyword_set(update)
check=keyword_set(check)
loud=keyword_set(loud)
if not keyword_set(outdir) then outdir=get_logenv('SSW_SITE_LOGS')
if n_elements(host) eq 0  then host=get_host()
if n_elements(serverid) eq 0 then serverid='0X2010CAFE'
watch_file=concat_dir(outdir,arr2str(['wwwidl_watchdog',host,serverid],'_'))

retval=0
if n_elements(value) eq 0 then value='idl_www watchdog ' + systime()
case 1 of
   keyword_set(update): begin
      file_delete, watch_file
      if not file_exist(watch_file) then begin
         file_append,watch_file,value
	 retval=(rd_tfile(watch_file))(0) eq value
      endif else box_message,'No permission to update: ' + watch_file
   endcase
   keyword_set(check):  begin
     if n_elements(value) gt 0 then begin 
        oldvalue=(rd_tfile(watch_file))(0)
        retval=value eq oldvalue
     endif else box_message,'Need to supply check VALUE'
   endcase
   else:
endcase

return, retval

end
