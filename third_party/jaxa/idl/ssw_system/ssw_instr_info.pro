pro ssw_instr_info, mpaths, ipaths, upaths,            $
   idlpaths=idlpaths, setup_files=setup_files, idl_startups=idl_startups, $
   loud=loud, real_loud=real_loud, debug=debug, no_expand_path=no_expand_path
;+
;   Name: ssw_instr_info
;   
;   Purpose: return info about callers $SSW_INSTR
;  
;   Input Parameters:
;      None
;  
;   Output Parameters:
;      mpaths - mission top level paths (uniq set, order per $SSW_INSTR elements)
;      ipaths - instrument top level paths (uniq)
;      upaths - associated 'ucon' paths, if any
;  
;   Keyword Parameters:
;      no_expand_path (switch) - if set, idlpaths return not expanded (parents only)
;      setup_files    (output) - vector of associated setup files
;      idl_startups   (output) - vector of associated IDL startup files
;      idlpaths       (output) - idl path vector implied by $SSW_INSTR
;
;   13-oct-1997 - S.L.Freeland - extract some code from ssw_path.pro
;                 simplify ssw_path and compartmentalize sytstem dependencies.
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;
;-
debug=keyword_set(debug)
real_loud=keyword_set(real_loud)
loud=keyword_set(loud) or debug or real_loud

; ------- Get SSW-wide information --------------
allinstr=strtrim(str2arr(get_logenv('SSW_INSTR_ALL'),' '),2)
allm=ssw_strsplit(allinstr,get_delim(),tail=alli)
upallinstr=strupcase(alli)
upallmiss =strupcase(allm)
missions=strtrim(str2arr(get_logenv('SSW_MISSIONS'),' '),2)
upmissions=strupcase(missions)
nmissions=n_elements(missions)
; --------------------------------------------------

; -------   get user $SSW_INSTR --------
thisinstr=strtrim(str2arr(strcompress(get_logenv('SSW_INSTR')),' '),2)
notgen=rem_elem(strlowcase(thisinstr),'gen',ngcount)
if ngcount eq 0 then thisinstr='gen' else thisinstr=thisinstr(notgen)
thisinstr=thisinstr(uniqo(thisinstr))
nsi=n_elements(thisinstr)
upinstr =strupcase(thisinstr)
lowinstr=strlowcase(thisinstr)
; --------------------------------------------------

if nsi eq 1 and thisinstr(0) eq '' then nsi=0         ; gen only

mlist=upinstr
ilist=upinstr

; ----- for each element in $SSW_INSTR, do the right thing --------
for i=0,nsi-1 do begin
  ssi=where(strpos(upallinstr,upinstr(i)) ne -1, ssicnt)
  ssm=where(strpos(upallmiss, upinstr(i)) ne -1, ssmcnt)
  case 1 of
      ssmcnt ge 1: begin
	 mlist(i)=upallmiss(ssm(0))
         ilist(i)=''
      endcase
      ssicnt ge 1: mlist(i)=upallmiss(ssi(0))
      else: begin
	 message,/info,'No mission match>> ' + upinstr(i)
         mlist(i)=''
	 ilist(i)=''
       endcase
    endcase    
endfor  
; -----------------------------------------------------------

ilist=strarrcompress(ilist)
mlist=strarrcompress(mlist)

;                    |add to list if required...|
mlok=rem_elem(mlist,['PACKAGES'],mok)             ; dont consider these 'missions'
if mok gt 0 then mlist=mlist(mlok) else mlist=''

mlist=mlist(uniqo(mlist))                         ; Uniq, ordered missions only 

; ------------ special handling --------------
; 1) backward compatability with existing Yohkoh systems
if get_logenv('SSW_YOHKOH') eq '' and get_logenv('ys') ne '' then $
    set_logenv,'SSW_YOHKOH',get_logenv('ys'),/quiet
; ----------------------------------------------------------------

caseproc=(['strlowcase','strupcase'])(os_family() eq 'vms')
; ----------------------------------------------------------------
ipaths=get_logenv('SSW_'+ilist)       ; allow split up of SSW tree
mpaths=get_logenv('SSW_'+mlist)
ssnull=where(mpaths eq '',ncnt)

if ncnt gt 0 then mpaths(ssnull) = $               ; default is under $SSW
    concat_dir(get_logenv('SSW'),mlist(ssnull))
; ----------------------------------------------------------------
mpaths=call_function(caseproc,mpaths)

genstr=call_function(caseproc,'gen')
setstr=call_function(caseproc,'setup')

gendir=concat_dir(mpaths,genstr)
msetdir=concat_dir(mpaths,setstr)

ssgen=where(file_exist(gendir),sscnt)
if sscnt gt 0 then mpaths(ssgen) =gendir(ssgen)

mpaths=call_function(caseproc,mpaths)
ipaths=call_function(caseproc,ipaths)
isetdir=concat_dir(ipaths,setstr)

if loud then box_message, [ $
   'SSW_INSTR (uniq): ' + arr2str(thisinstr), $
   'MISSIONS        : ' + arr2str(mlist),     $
   '   ' + mpaths,                            $
   'INSTRUMENTS     : ' + arr2str(ilist),     $
   '   ' + ipaths]
 
allpaths=[mpaths,ipaths]
pexist=file_exist(allpaths)
ssok=where(pexist,okcnt)
ssbad=where(1-pexist,badcnt)

; derive top level IDL paths 
; Preserve instrument order [mission-gens, instruments, special]

if okcnt gt 0 then allpaths=allpaths(ssok) 


; ================= Setup file configuration =========================

sitesetup=concat_dir(concat_dir('$SSW','site'),'setup')
gensetup =concat_dir(concat_dir('$SSW','gen'),'setup')
ssw_setup=  [concat_dir(sitesetup,'setup.ssw_paths'), $
             concat_dir(gensetup, 'setup.ssw_env')  ]   

;          ----- order for mission/instr config ------
porder=[sitesetup, gensetup, get_logenv('HOME')] ; gen->site->home

mission_site_paths=concat_dir('$SSW_SITE_SETUP','setup.'+mlist+'_paths')
mission_setup=concat_dir(porder,'setup.'+ mlist+'_env')     

instr_site_paths=concat_dir('$SSW_SITE_SETUP','setup.'+ilist+'_paths')
instr_setup=''
for i=0,n_elements(ilist)-1 do instr_setup=[instr_setup, $
       concat_dir([isetdir,porder],'setup.'+ ilist+'_env')]

setup_files=[ssw_setup, $
             mission_site_paths, mission_setup, $
             instr_site_paths,   instr_setup]
setup_files=call_function(caseproc,setup_files)
suok=where(file_exist(setup_files),sucnt)
if sucnt eq 0 then setup_files='' else setup_files=setup_files(suok)


; ==========================================================================
; the following lines might move (to ssw_path, for example)
; enable path list search for files setup.XXX_paths
if loud then box_message,['Executing setup files:', setup_files]
pathfiles=strpos(strlowcase(setup_files),'_paths') ne -1    ; flag pathfiles
for i=0,sucnt-1 do set_logenv,file=setup_files(i), quiet=(1-real_loud), $
                envlist=pathfiles(i)
; ==========================================================================

; ==========================================================================


; -----------------------------------------------------------------

suok=where(file_exist(setup_paths),sucnt)
if sucnt gt 0 then setup_paths=setup_paths(suok) else setup_paths=''

; -------------------- IDL paths --------------------------
idl_paths=concat_dir(allpaths,'idl')
not_standard=where(1-file_exist(idl_paths),nscnt)

if nscnt gt 0 then idl_paths(not_standard)=allpaths(not_standard)
idl_paths=idl_paths(uniqo(idl_paths))
okcnt=n_elements(idl_paths)

; derive associated idl_paths - expand unless told otherwise
idlpaths=''
if keyword_set(no_expand_path) then idlpaths=idl_paths else begin
   for i=0,okcnt-1 do begin
      if loud then box_message,'Expanding path: ' + idl_paths(i)
      temp=expand_path('+'+idl_paths(i),/array)
      idlpaths=[temporary(idlpaths),$
          temp(sort (strmids(temp,strlen(idl_paths(i))+1,10)))]
   endfor
endelse

idpok=where(idlpaths ne '',idcnt)
if idcnt gt 0 then idlpaths=idlpaths(idpok) else idpaths=''
; -----------------------------------------------------------------

if debug then stop
return
end
