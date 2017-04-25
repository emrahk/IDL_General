pro ssw_contrib_monitor, online=online, $
     incoming_dir=incoming_dir, processed_dir=processed_dir, $
     notify=notify, age_contrib=age_contrib, noremove=noremove
;+
;   Name: ssw_contrib_monitor
;
;   Purpose: monitor "ssw_contrib"uted SW, optionally online=>SSW
;
;   Input Parameters:
;
;   Keyword Parameters:
;      incoming_dir  - local directory where ssw_contrib stuff is placed
;      processed_dir - local directory where processing is done
;      notify - if set, name of user(s) to notify when some processing is done
;      noremove - if set, dont remove versions from incoming_dir 
;
;   Method:
;      Uses information in 'ssw_contrib' job description.
;
;   Side Effects:
;     any ssw_contrib files under /<incoming_dir> are moved to /<processed_dir>
;
;   History:
;      1-Mar-1999  - S.L.Freeland
;     21-Sep-1999  - S.L.Freeland - mods for update format, functional
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;-

noremove=keyword_set(noremove)

pr_status                      ; show when/where run
ssw=get_logenv('SSW')
contrib_default=concat_dir(ssw,'offline/contrib')

case 1 of
   data_chk(incoming_dir,/string): incoming=incoming_dir
   get_logenv('ssw_contrib_incoming') ne '': incoming=get_logenv('ssw_contrib_incoming')
   file_exist(contrib_default): incoming=contrib_default
   else: incoming=''
endcase

if not file_exist(incoming) then begin 
   box_message,'Cannot find SSW contributed incoming directory, returning'
   return
endif

case 1 of
   data_chk(processed_dir,/string): processed=processed_dir
   get_logenv('ssw_contrib_processed') ne '': processed=get_logenv('ssw_contrib_processed')
   file_exist(incoming+'_processed'): processed=incoming+'_processed'
   else: processed=''
endcase

if not file_exist(processed) then begin 
   box_message,'Cannot find SSW contributed processed directory, returning'
   return
endif

if n_elements(age_contrib) eq 0 then age_contrib=0  ; 
tarfiles=dir_since(incoming,age_contrib,/sub,pattern='*tar')

if tarfiles(0) eq '' then begin 
   box_message,'No new TAR files found under: '+ incoming + ' ,returning...'
   return
endif

tcnt=n_elements(tarfiles)
jobfiles=ssw_strsplit(tarfiles,'.tar',/last,/head)
jobexist=file_exist(jobfiles)
ssjob=where(jobexist,jcnt)
ssbad=where(1-jobexist,bjcnt)

case 1 of 
   jcnt eq 0: begin
      box_message,"NO JOB FILES FOUND!!, returning"
      return                                            ; EARLY EXIT
   endcase
   bjcnt gt 0 : begin 
      box_message,["Some JOB files are missing",jobfiles(ssbad)]
   endcase
   else: box_message,'All JOB files exist...' 
endcase

tarfiles=tarfiles(ssjob)
jobfiles=jobfiles(ssjob)

tarname=ssw_strsplit(tarfiles,'/',/last,/tail)        ; extract tar name
jobname=ssw_strsplit(jobfiles,'/',/last,/tail)        ; extract jobname
jobcols=str2cols(jobname,'.',/unaligned)          ; parse->cols
strtab2vect,jobcols, ssc, juser, jdate, jtime     ; cols->vectors

outdirs=concat_dir(processed,juser)               ; where to stick it
tcpcmd='cp ' + tarfiles + ' ' + outdirs + '/'
jcpcmd='cp ' + jobfiles + ' ' + outdirs + '/'

proctar=concat_dir(outdirs,tarname)
tarcmd='tar -xf '+ proctar

for i=0,jcnt-1 do begin 
   jobinfo=ssw_contrib_info(jobfiles(i), pcnt, pros=pros)        ; job->struct
   help,jobinfo,/str
   box_message,'Processing JOB: ' + gt_tagval(jobinfo,/JOBNAME)
   
;  --------------- copy -> process area -------------------
   if not file_exist(outdirs(i)) then $
      spawn,str2arr(['mkdir -p '+outdirs(i)],' '),/noshell ; make USER subdir
   spawn,str2arr(tcpcmd(i),' '),/noshell
stop,'tcpcmd
   spawn,str2arr(jcpcmd(i),' '),/noshell
stop,'jcpcmd
;  --------------------------------------------------------
   
;  -------------------- untar the file --------------------
   if not keyword_set(notar) then begin 
      pushd,curdir()                           ; save current dir
      cd,outdirs(i)                            ; move to processed
      spawn,str2arr(tarcmd(i),' '),/noshell    ; restore "current"
      popd
   endif
;  --------------------------------------------------------

;  ---------- Check for transferred files (tar contents) -------
   ftfiles=gt_tagval(jobinfo,/FILESTRANSFERED,missing='')
   ftfiles=strarrcompress(str2arr(ftfiles,' '),/trim)
   
   onlineit=keyword_set(online) or ssw_contrib_ok2online(jobinfo)

   if ftfiles(0) ne '' then begin 
      if onlineit then begin
	 pushd,curdir()
         cd,outdirs(i)
         for ft=0,n_elements(ftfiles)-1 do begin  
            curfile=concat_dir(curdir(),ftfiles(ft))
	    chkfile=file_exist(ftfiles(ft))
            if chkfile then begin
               box_message,'File Found: ' + ftfiles(ft)
	    endif else box_message,'File: ' + curfile + ' Not Found'
	 endfor
         popd
     endif
   endif else box_message,'No Files actually transfered in job: ' + gt_tagval(jobinfo,/JOBNAME)
;  -----------------------------------------------------------------
   
;  ----------- remove the job from the incoming area ------------
   if not keyword_set(noremove)  and file_exist(proctar(i)) then begin 
      rfiles=[tarfiles(i),jobfiles(i)]
      box_message,['Removing files:','   '+rfiles]
      file_delete,rfiles
   endif
;  ----------------------------------------------------------------

stop
endfor

return
end
