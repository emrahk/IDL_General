pro go_ssw_batch, jobfile, logfile, $
   site=site, batch_cmd=batch_cmd, $
   nodate=nodate, background=background
;
;+
;   Name: go_ssw_batch
;
;   Purpose: run sswidl jobs from application or cronjobs
;
;   Input Parameters:
;      jobfile - the *.pro to run; main level program format
;      logfile - job output (def=$SSW/site/logs/<job>.log
;
;   Keyword Parameters:
;      site - (switch) if set, use $SSW/site/bin/ssw_batch
;                      (def=$SSW/gen/bin/ssw_batch)
;      batch_cmd - explicit command (def= .../ssw_batch )
;      nodate - (switch) - if set, dont append date to <logfile>
;      background - (switch) - if set, background task
;                              (def = in-line/sycncronous)
;
;   Calling Sequence:
;      IDL> go_ssw_batch,'program.pro'[,logfile],[/background]
;
;   Application: 
;      appliclation generates <job.pro> dynamically - then
;      call this to execute it within the application.
;
;   History:
;       Circa 1-jan-???? - S.L.Freeland  
;       21-Nov-2005 - S.L.Freeland - added doc header,/BACKGROUND
;
;   Restrictions:
;      os_family()='unix' only 
;
;-
if os_family() ne 'unix' then begin
   box_message,'UNIX family OS only...'
   return
endif


if n_params() lt 1 then begin 
   box_message,'Need input job file name'
   return
endif

case 1 of 
   data_chk(batch_cmd,/string): 
   keyword_set(site): batch_cmd=concat_dir('$SSW','site/bin/ssw_batch')
   else: batch_cmd=concat_dir('$SSW','gen/bin/ssw_batch')
endcase

if not file_exist(batch_cmd(0)) then begin 
   box_message,'Cannot find batch cmd> ' + batch_cmd(0)
   return
endif

break_file,jobfile,ll,pp,ff
if not keyword_set(logfile) then $  
   logfile=concat_dir('$SSW','site/logs/'+ff+'.log')
     

bcmd=[batch_cmd(0),jobfile,logfile]
if not keyword_set(nodate) then bcmd=[bcmd,'/date']

if keyword_set(background) then $
   spawn,'nohup ' + arr2str(bcmd,' ')+ ' &' else $
   spawn,bcmd,/noshell ; in line execution

return
end

