pro setssw, _extra=_extra, remove=remove, loud=loud, $
   sitepaths=sitepaths, allenv=allenv, allstart=allstart, $
   noexecute=noexecute
;+
;  Name: setssw
;
;  Purpose: add/remove instruments libraries; define environmental & IDL_STARTUP
;
;  Input Paramters:
;      NONE
;
;  Keyword Parameters:
;    _extra - zero or more instrument keywords 
;    remove (switch) - remove libraries from integrated SSW !path
;    loud (switch) - if set, some progress tracking
;    noexecute (switch) - if set, determine lists but don't run (output via keywords for example)
;    sitepaths (output) - list of site setup.<xxx>_paths executed
;    allenv (outpu) - list of setup.<xxx>_env files executed
;    allstart (output) - list of <mmm>/<xxx>/setup/IDL_STARTUP files executed
;
;  Calling Example:
;    IDL> setssw,/sot,/eis,/secchi ; add these instruments & required environment
;
;  History:
;    circa 1999 - S.L.Freeland - thought about this and wrote the 99.9% helpers
;    23-jun-2009 - S.L.Freeland - wrote this
;
;  References:
;    calls ssw_path, ssw_set_instr, get_logenv, main_execute
;   
;-
;
loud=keyword_set(loud)
quiet=1-loud

remove=keyword_set(remove)

if data_chk(_extra,/struct) then begin ; any instrument keywords via inherit?
   ssw_path,_extra=_extra,remove=remove, quiet=quiet
   ssw_set_instr,_extra=_extra,remove=remove ; update $SSW_INSTR list
endif

if remove then begin
   return ; early exit, since !path remove is complete (not bothering to undo env/startups..)
endif

inst=strlowcase(str2arr(get_logenv('SSW_INSTR'),' '))  	; users (adjusted) instrument list
ienv='SSW_'+strupcase(inst)                            	; SSW_XXX- SSW assigned per-instrument env
ipath=get_logenv(ienv) 					; env->local SSW path
instx=ssw_strsplit(ipath,'/',/tail,head=mpath)		; mpath=mission path
mpath=mpath(uniq(mpath,sort(mpath)))			; only need uniq subset
miss=ssw_strsplit(mpath,'/',/tail,head=ssw) 		; mission names
setpath=concat_dir(ipath,'setup')                   	; instrument setup path
setenv=concat_dir(setpath,'setup.'+inst+'_env')         ; instrument setup.xxx_env
setstart=concat_dir(setpath,'IDL_STARTUP')     		; instrument IDL_STARTUPs 
genset=concat_dir(mpath,'gen/setup') 			; mission gen setup path
genenv=concat_dir(genset,'setup.'+miss+'_env')   	; mission setup.mmm_env		
genstart=concat_dir(genset,'IDL_STARTUP')		; mission/gen IDL_STARTUP

siteset=concat_dir(concat_dir('$SSW','site'),'setup')
sitestart=concat_dir(siteset,'IDL_STARTUP')
siteenv=concat_dir(siteset,'setup.'+['ssw',miss,inst]+'_env')

; $SSW/site/setup/setup.<xxx>_paths files
sitepaths=str_replace(siteenv,'_env','_paths')
sitepaths=sitepaths(uniqo(sitepaths))
pex=where(file_exist(sitepaths),ecnt) ; existing subset
if ecnt gt 0 then begin
   sitepaths=sitepaths(pex)
   set_logenv,file=sitepaths,/envlist,quiet=quiet ; allow vectors for path environmentals
endif

allenv=[genenv,setenv,siteenv]   ; aggregate
allenv=allenv(uniqo(allenv))
envex=where(file_exist(allenv),ecnt)
if ecnt gt 0 then begin 
   allenv=allenv(envex)
   set_logenv,file=allenv, quiet=quiet
endif

; IDL_STARTUP
allstart=[genstart,setstart,sitestart,get_logenv('ssw_pers_startup')] ; all + maybe user
allstart=allstart(uniqo(allstart))
sex=where(file_exist(allstart),ecnt)
for i=0,ecnt-1 do main_execute,allstart(sex(i))

return
end





