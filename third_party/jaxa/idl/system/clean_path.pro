;+
; Project     : SOHO-CDS
;
; Name        : CLEAN_PATH
;
; Purpose     : clean up SSW path by reorganizing directories
;
; Category    : utility
;
; Explanation : use this to move SUMER and YOHKOH UCON libraries to
;               end of IDL path to avoid potential conflicts.
;
; Syntax      : clean_path,new_path
;
; Outputs     : NEW_PATH = rearranged IDL !path
;
; Keywords    : SITE = include site directories
;               RESET = reset back to original state
;               UCON = include Yohkoh UCONS
;               SDAC = include SDAC FUND_LIB
;               NRL  = include NRL directories
;               JHU = include JHU directories
;               NO_CURRENT = exclude current working directory
;
; Side effects: If NEW_PATH not on command line, !path is reset automatically
;
; History     : Written 22 Oct 1997, D. Zarro, SAC/GSFC
;		Version 2, 11-Dec-2001, William Thompson, GSFC
;			Moved rsi to top, so $IDL_DIR/lib/obsolete is not
;			removed from the path.
;			Don't change case of directories.
;               12-Feb-02 - Zarro (EITI/GSFC) - made Windows compatible and
;                       added check for pre-version 4 directories in
;                       !path
;               29-Aug-13 - Zarro (ADNET) - removed defunct directories and added
;                           optional directory keywords.
;               19-Feb-16 - Zarro (ADNET) - removed IDL obsolete from !path
;
; Contact     : dzarro@solar.stanford.edu
;-
;----------------------------------------------------------------------------

pro check_idl_path,dir,libs,dlibs,exclude=exclude

delvarx,dlibs
if (n_elements(dir) eq 0) or (n_elements(libs) eq 0) then return

clibs=strlowcase(libs)

find_dir=strpos(clibs,strlowcase(local_name(dir)))
if n_elements(exclude) gt 0 then begin
 ex_dir=strpos(clibs,strlowcase(local_name(exclude)))
 have_dir=where((find_dir gt -1) and (ex_dir eq -1),count)
 no_dir=where( (find_dir lt 0) or (ex_dir gt -1),ncount)
endif else begin
 have_dir=where(find_dir gt -1,count)
 no_dir=where(find_dir lt 0,ncount)
endelse

if count gt 0 then dlibs=libs(have_dir)
if ncount gt 0 then libs=libs(no_dir) else delvarx,libs
if ncount eq 1 then libs=libs[0]
if count eq 1 then dlibs=dlibs[0]

return & end

;----------------------------------------------------------------------------

pro clean_path,new_path,reset=reset,site=site,ucon=ucon,no_current=no_current,$
                        sdac=sdac,nrl=nrl,jhu=jhu,_extra=extra


common clean_path,orig_path,sav_path

message,'...cleaning !path',/info

if keyword_set(reset) then begin
 if exist(orig_path) then !path=orig_path
 return
endif else begin
 if ~exist(orig_path) then orig_path=!path
endelse

libs=get_lib()
delim=get_path_delim()

;-- remove path elements

ssw=chklog('$SSW')
rsi=chklog('IDL_DIR')
libs=local_name(libs)
check_idl_path,local_name(curdir()),libs,personal_libs

check_idl_path,'$SSW/gen/idl_libs',libs,astro_libs
check_idl_path,'$SSW/gen/idl/fund_lib/sdac',libs,sdac_libs
check_idl_path,'$SSW/gen/idl/fund_lib/jhuapl',libs,jhu_libs
check_idl_path,'$SSW/gen/idl_fix',libs,fix_libs
check_idl_path,'$SSW/gen/idl_test',libs,test_libs
check_idl_path,'$SSW/gen/idl',libs,gen_libs

check_idl_path,'$SSW/proba2',libs,proba_libs

check_idl_path,'$SSW/packages/nrl',libs,nrl_libs
check_idl_path,'$SSW/packages',libs,pack_libs
check_idl_path,'idl/lib/itools',libs,obs_libs
check_idl_path,'idl/lib/obsolete',libs,obs_libs
check_idl_path,'idl/lib/imsl',libs,obs_libs

check_idl_path,rsi,libs,rsi_libs
check_idl_path,'$SSW/site',libs,site_libs
check_idl_path,'$SSW/spartan',libs,spart_libs
check_idl_path,'$SSW/sdo',libs,sdo_libs
check_idl_path,'$SSW/hinode',libs,hinode_libs
check_idl_path,'$SSW/solarb',libs,solarb_libs
check_idl_path,'$SSW/stereo',libs,stereo_libs
check_idl_path,'$SSW/goesimg',libs,sxi_libs
check_idl_path,'$SSW/vobs',libs,vobs_libs
check_idl_path,'$SSW/goes',libs,goes_libs

check_idl_path,'$SSW/yohkoh/ucon',libs,ucon_libs
check_idl_path,'$SSW/yohkoh',libs,yohkoh_libs

check_idl_path,'$SSW/smm',libs,smm_libs

check_idl_path,'$SSW/trace/ssw_contributed',libs,trace_cont
check_idl_path,'$SSW/trace/idl',libs,trace_libs

check_idl_path,'$SSW/hessi',libs,hessi_libs
check_idl_path,'$SSW/batse',libs,batse_libs
check_idl_path,'$SSW/optical',libs,opt_libs
check_idl_path,'$SSW/soho/gen/idl',libs,soho_libs
check_idl_path,'$SSW/soho/sumer/idl',libs,sumer_libs
check_idl_path,'$SSW/soho/lasco/idl',libs,lasco_libs
check_idl_path,'$SSW/soho/mdi/idl',libs,mdi_libs
check_idl_path,'$SSW/soho/cds/idl',libs,cds_libs
check_idl_path,'$SSW/soho/eit/idl',libs,eit_libs
check_idl_path,'$SSW/ssw_bypass',libs,bypass_libs
check_idl_path,'$SSW/radio',libs,radio_libs
check_idl_path,'$SSW/hxrs',libs,hxrs_libs

if ~exist(libs) then libs=''

dprint,'% CLEAN_PATH: ',libs

keep_current=~keyword_set(no_current)
if keep_current then begin
 if exist(personal_libs) then begin
  if is_blank(libs) then begin
   libs=personal_libs 
  endif else begin
   for i=0,n_elements(personal_libs)-1 do begin
    rpe=replicate(personal_libs[i],n_elements(libs))
    chk=where(file_same(rpe,libs),count)
    if count gt 0 then libs=[libs,personal_libs[i]]
   endfor
  endelse
 endif 
endif else cd,get_temp_dir()

if exist(gen_libs) then libs=[libs,gen_libs]
if exist(rsi_libs) then libs=[libs,rsi_libs]
if exist(astro_libs) then libs=[libs,astro_libs]
if exist(hessi_libs) then libs=[libs,hessi_libs]
if exist(sdo_libs) then libs=[libs,sdo_libs]
if exist(vobs_libs) then libs=[libs,vobs_libs]
if exist(hinode_libs) then libs=[libs,hinode_libs]
if exist(stereo_libs) then libs=[libs,stereo_libs]
if exist(soho_libs) then libs=[libs,soho_libs]
if exist(eit_libs) then libs=[libs,eit_libs]
if exist(cds_libs) then libs=[libs,cds_libs]
if exist(mdi_libs) then libs=[libs,mdi_libs]
if exist(yohkoh_libs) then libs=[libs,yohkoh_libs]
if exist(radio_libs) then libs=[libs,radio_libs]
if exist(pack_libs) then libs=[libs,pack_libs]
if exist(trace_libs) then libs=[libs,trace_libs]
if exist(proba_lib) then libs=[libs,proba_libs]
if keyword_set(jhu) then if exist(jhu_libs) then libs=[libs,jhu_libs]
if exist(sxi_libs) then libs=[libs,sxi_libs]
if exist(goes_libs) then libs=[libs,goes_libs]
if exist(batse_libs) then libs=[libs,batse_libs]
if exist(opt_libs) then libs=[libs,opt_libs]
if exist(hxrs_libs) then libs=[libs,hxrs_libs]
if exist(sumer_libs) then libs=[libs,sumer_libs]
if exist(lasco_libs) then libs=[libs,lasco_libs]

if keyword_set(nrl) then begin
 if exist(nrl_libs) then libs=[libs,nrl_libs]
 if exist(nrl_pack) then libs=[libs,nrl_pack]
endif

if exist(smm_libs) then libs=[libs,smm_libs]
if keyword_set(sdac) and exist(sdac_libs) then libs=[libs,sdac_libs]
if exist(bypass_libs) then libs=[libs,bypass_libs]
if keyword_set(ucon) then if exist(ucon_libs) then libs=[libs,ucon_libs]
if exist(spart_libs) then libs=[libs,spart_libs]
if exist(fix_libs) then libs=[libs,fix_libs]
if exist(test_libs) then libs=[libs,test_libs]
if exist(trace_cont) then libs=[libs,trace_cont]
if keyword_set(site) and exist(site_libs) then libs=[libs,site_libs]

ok=where(trim2(libs) ne '',count)
if count gt 0 then libs=libs[ok]
new_path=arr2str(libs,delim=delim)
if n_params() eq 0 then !path=new_path

sav_path=new_path
return & end


