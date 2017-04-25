;+
;   Name: go_file_purge
;
;   Purpose: cron driver for file_purge
;
;   History: 
;       09-Aug-1993 (SLF) (keep backup data bases in check)
;       23-may-1995 (SLF) add option 3
;        2-oct-1995 (SLF) add file filter option (column 4)
;        8-Aug-1997 (SLF) adjust for SSW use
;        7-Oct-1997 (SLF) appended SITE template file
;-

authorized=getenv('FILE_PURGE_USERS')
noauthorize=strpos(authorized,getenv('USER')) eq -1

if noauthorize then begin
   if authorized eq '' then message,/info, $
	'No authorization list defined....' else begin
      message,/info,'Only the following users are authorized...'
      prstr,str2arr(authorized)
   endelse
endif   

; read the file_purge data file
file=concat_dir(concat_dir('$SSW_SITE_SETUP','data'),'file_purge.dat')
if file_exist(file) then begin
   fdata=rd_tfile(file,nocomment=';',4)			; 4 columns
endif else message,'No purge data file: ' + file

for i=0,n_elements(fdata(0,*))-1 do begin
;  ------------------ by FID (xxxYYMMDD.HHMM) -----------------
   if long(fdata(2,i)) eq 3 then begin			; by FID
      yfiles=file_list(fdata(0,i),'?????????.????')
      break_file,yfiles,logs,paths,nnnyymmdd,hhmm,vers
      order=sort(strmid(nnnyymmdd,3,11))		; order by fid
      if n_elements(order) gt fix(fdata(1,i)) then begin
;         file_delete,yfiles(order(0:fix(fdata(1,i))-1))      
      endif
;  --------------------------------------------------------------
   endif else begin
;  -------- bydir 
      message,/info, $
         'file_purge,dir=' + fdata(0,i) + ',KEEP=' + fdata(1,i) + $
      ',bydate=' + fdata(2,i) + ',FILTER=' + strtrim(fdata(3,i),2)
       file_purge,dir=fdata(0,i), keep=fix(fdata(1,i)), bydate=fdata(2,i), $
	   filter=strtrim(fdata(3,i),2)
   endelse
endfor

end
; --------------------------------------------------------------------------
; Following is a TEMPLATE of a SITE purge data file
; GO_FILE_PURGE.PRO looks for a file $SSW/site/setup/data/file_purge.dat
; This is used to define daily calls to FILE_PURGE.PRO (via cron, for example)
; You may specify  pathnames, file filters, number to KEEP and search priority
; (by name, creation date or file "FID" = YYYYMMDD.HHMMSS)
; You may keep the header on the file since free-form comments delimited
; Semicolon ";" are ignored
; --------------------------------------------------------------------------
; file_purge.dat
;
; Data file for cron job which purges files (via go_file_purge.pro)
;
; Format - 3 columns
; directory	keep	bydate
; 
;   directory - path or environmental to purge (see WARNING)
;   keep      - number of files to keep
;   option    = optional flag  use creation date, not file name 
;		0 - by file name
;               1 - by creattion date
;               3 - by FID time
;
;   Include data file comments with semicolon 	;(partial line comments ok)

; WARNING: - if environmental is used, assure that IDL evnvironmental context
; 	     (for example, master or backup host?)
;
; EXAMPLES
; DIRECTORY			KEEP	OPTION  File Pattern
;
; $DIR_SFD_DAILY1		  30	 0		;env, by name
; /yd2/sfd_daily		  30	 0		;hard path, not env.
; $ydb/pnt			  10	 1 		;by creation date
; $http_movies                    40     1       *.mpg  ; only *.mpg files
; $http_movies                    200    1       *.gif  ; only *.gif files
; $http_movies_scratch            300    1       *.gif
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------

