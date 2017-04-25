pro ssw_check_contrib, delete=delete, mail=mail, details=details, $
		       move=move, backup=backup, loud=loud, nomail=nomail, $
                       testing=testing, noaction=noaction, no_delete=no_delete
;+  
;
;   Name: ssw_check_contrib
;
;   Purpose: check local contrib area to see if routines have made it online
;
;   Keyword Parameters:
;      loud     - if set, print some status messsages
;      nomail   - if set, dont mail results (implies /LOUD)
;      testing  - if set, check and mail but dont move or delete
;      noaction - synonym for TESTING
;      move     - optional path to move to  (default=$SSW_CONTRIB_BACKUP)
;      backup   - synonym for MOVE
;      delete   - if set, DELETE as well as Copy (ie, a true move)
;      no_delete - if set, dont delete after copy (/DELETE IS DEFAULT)
;
;   Calling Sequence:
;      ssw_check_contrib,/delete     ; monitor $SSW_CONTRIBUTED
;                                    ; move files which are identical to 1st
;                                    ; $SSW match - send email 
;
;      ssw_check_contrib,/testing    ; just check status and send email
;
;   History:
;      6-may-1997 - S.L.Freeland
;      9-may-1997 - S.L.Freeland, flag files hanging around too long
;                                 files OLDER than corresponding SSW
;                                 pretty up output messages.
;                                 made /delete the default
;                                 notify $SSW_SW_NOTIFY
;      9-Sep-1997 - M.D.Morrison, Send mail only on Sundays
;       3-Dec-1997 - S.L.Freeland, initialize a variable 
;
;-  
new_cutoff=7                ; number of days when we start to worry...

testing=keyword_set(testing) or keyword_set(noaction)
loud=keyword_set(loud)
contdir=get_logenv('$SSW_CONTRIBUTED')          ; 
no_delete=keyword_set(no_delete) or testing
delete=1-keyword_set(no_delete)                 ; default is delete

if not file_exist(contdir) then begin
  if loud then message,/info,"No directory: $SSW_CONTRIBUTED exists.."
  return
endif

files=file_list(contdir,'*.pro')
if files(0) eq '' then begin
  if loud then message,/info,"$SSW_CONTRIBUTED (" + contdir + ") is empty..."
  return
endif

break_file,files,ll,pp,ff,ee,vv

contribs=strrep_logenv(files,'SSW_CONTRIBUTED')
firstmatch=strarr(n_elements(contribs))
status=strarr(n_elements(contribs))+ 'NOT ONLINE'

pr_status,allmess,caller='ssw_check_contrib',/idlcomment

info=file_info2(files,cont_info)
match_info=cont_info

thismatch=''
for i=0,n_elements(files)-1 do begin
  thiscont=contribs(i)
  fi=ff(i)+ee(i)
  sswloc,'/'+fi,matches, count				; search $SSW
  if strpos(matches(0),concat_dir('site','idl')) ne -1 then begin
    ss=rem_elem(matches,matches(0),count)
    if count gt 0 then matches=matches(ss)              ; ignore GSF C site
  endif
  if count eq 0 then begin
     mess="Routine " + fi + " not yet online..."
  endif else begin     
      thismatch=strcompress(strrep_logenv(matches(0),'SSW'),/remove)
      thismatch=str_replace(thismatch,'_system','ssw_system')
      firstmatch(i)=thismatch
      diff=file_diff(files(i),matches(0),mess=mess,status=fdstatus,/idl)
      info=file_info2(matches(0),minfo)
      match_info(i)=minfo
      case diff of
	0: begin
           status(i)= 'IDENTICAL' 
         endcase
       1: begin
           status(i)=(['OLDER THAN', 'NEWER THAN'])( (int2secarr([cont_info(i),match_info(i)]))(1) lt 0)
          endcase
       endcase
     endelse  
   mess= thiscont + status(i) + thismatch
   if loud then message,mess,/info
endfor
firstmatch=str_replace(firstmatch,'$SSW/','')
allmess=[allmess,strjustify(contribs) + '  ' + strjustify(status) + '  ' + firstmatch]

   newer=where((strpos(status,"NEWER") ne -1) or $
                (strpos(status,"NOT")   ne -1), ncnt)
   if ncnt gt 0 then begin
      today=anytim2ints(!stime)
      ndays=round(abs(int2secarr(cont_info(newer),today))/(24.*60*60.))
      toolong=where(ndays gt new_cutoff,tlcnt)
      if tlcnt gt 0 then begin
         allmess = [allmess, '', $
    strjustify(["The following have been around a while and not propagated to SSW", $
         "   " + strjustify(files(newer(toolong)))+ '  ' + $
                 fmt_tim(cont_info(newer(toolong)))],/box)]
      endif
   endif

   older=where(strpos(status,"OLDER") ne -1, ocnt)
   if ocnt gt 0 then begin
      allmess=[allmess,'', $
      strjustify(["The following $SSW_CONTRIB files are OLDER than ", $
      "the existing SSW versions - please verify , merge, and resubmit ", $
      "   " + files(older)],/box)]
   endif

moveit=status eq 'IDENTICAL'
which=where(moveit,mcnt)

if mcnt gt 0 then begin
   case 1 of
      data_chk(move,/string): outdir=move
      data_chk(backup,/string): outdir=backup
      get_logenv('SSW_CONTRIB_BACKUP') ne '': outdir= get_logenv('SSW_CONTRIB_BACKUP')
      else: begin
         mess=["Sorry, Dont know where you want to move the backupse...", $
               "Define $SSW_CONTRIB_BACKUP or use MOVE or BACKUP to name paths"]
         prstr,mess
         return
      endcase
   endcase
   if not file_exist(outdir) then begin
      message,/info,"SSW_CONTRIB_BACKUP does not exist, exiting..."
      return
   endif
   utfid=ex2fid(ut_time(/ex))
   newnames=concat_dir(outdir,ff(which)+ee(which)+ '_' + utfid)
   oldnames=strjustify(files(which))
   cpcmds='cp -p ' + oldnames + ' ' + newnames
   allmess=[allmess,'',';------- issuing the following copy commands ----', $
            cpcmds]
   if not testing then for i=0,mcnt-1 do spawn,cpcmds(i)
   allmess=[allmess,'','--------------------------------------']
   if delete then file_delete,strtrim(oldnames,2)
   allmess=[allmess,'','----- Auto Delete is ' + (['OFF','ON'])(delete)+ ' ----']
endif else begin
   allmess=[allmess,"No routines to move at this time"]
endelse

; for now, mail on any 'event' 
sendmail =(ocnt gt 0) or (tlcnt gt 0)  or (mcnt gt 0)
sendmail = sendmail and (utc2dow(!stime) eq 0)		;MDM 9-Sep-97

if sendmail then begin
   users='freeland@penumbra.nascom.nasa.gov'
   ssw_sw_notify=get_logenv('SSW_SW_NOTIFY')
   if ssw_sw_notify(0) ne '' then users=[users,str2arr(ssw_sw_notify)] 
   mail,allmess,/no_def,subj="SSW_CONTRIBUTED STATUS", user=users
endif
return



end
