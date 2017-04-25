pro ssw_path, path, soho=soho, yohkoh=yohkoh, $
   _extra=_extra, remove=remove, test=test, prepend=prepend, $
   show=show, inquire=inquire, quiet=quiet, $
   save=save, restore=restore, ucon=ucon, more=more, ops=ops, $
   full_prepend=full_prepend ;, $
   ; chianti=chianti, ztools=ztools
;+
;   Name: ssw_path
;
;   Purpose: add or remove SSW elements from IDL path
;
;   Input Parameters:
;      path - optional path to add (if not an SSW instrument)
;
;   Keyword Parameters:
;      remove  - switch, if set, remove (default is to ADD paths)
;      test    - switch, if set, add/remove the TEST directory (def=idl)
;      prepend - switch, if set, Prepend the paths (default is append to SSW paths)
;      quiet   - switch, if set, suppress some messages
;      show/inquire switch, if set, print current !path to screen and exit
;      more    - switch, if set, same as SHOW with MORE-like behavior
;      save    - switch, if set, store current !path prior to change
;      restore - switch, if set, restore !path saved with /save (previous call)
;      ops     - switch, if set, $SSW/MMM/ops/III/idl (ops software)
;      full_prepend - switch, if set, then put paths at the front of everything
;
;      <instrument> - switch, any SSW instrument [/eit,/sxt,/cds,/mdi,/bcs...]
;                     (may use multiple instrument switches in single call)
;
;   Category: environment, system
;
;   Calling Sequence:
;      ssw_path,/instrument [,/instrument ,/remove]
;
;   Calling Examples:
;      ssw_path,/show		   ; display current !path
;      ssw_path,/eit,/sxt	   ; append  EIT and SXT paths
;      ssw_path,/eit,/sxt,/remove  ; remove  EIT and SXT paths
;      ssw_path,/cds,/prepend	   ; prepend CDS paths
;      ssw_path,/save,/sumer	   ; save current !path, then add SUMER
;      ssw_path,/restore	   ; restore saved !path and exit
;      ssw_path,/ucon,/yohkoh	   ; add "selected" Yohkoh ucon areas 
;				   ; (only those UCON with external references)
;      ssw_path,/ops,/cds	   ; deal with OPS SW (instead of ANAL)
;
;   Side Effects:
;      *** Updates IDL !PATH *** 
;
;   History:
;      15-Jun-1995 (SLF)
;      15-Feb-1996 (S.L.Freeland) - major overhaul, keywords added, etc
;      13-mar-1996 (S.L.Freeland) - add /OPS keyword and function
;      28-May-1996 (S.L.Freeland) - prepend atest if present
;      18-aug-1996 (S.L.Freeland) - add SPARTAN
;      29-aug-1996 (S.L.Freeland) - status message (order changed?) , add TRACE
;      31-Oct-1996 (M.D.Morrison) - Added /FULL_PREPEND
;      10-nov-1996 (S.L.Freeland) - library "protect" $SSW/gen/idl_libs/..
;       4-mar-1997 (S.L.Freeland) - Applied Richard Schwartz counting correction
;      30-apr-1997 (S.L.Freeland) - "Temporary" upgrade (big change coming)
;                                   (chianti/ztools hook->ssw_packages)
;      17-Mar-2000 (R.D.Bentley)  - added hessi bit...
;      31-Mar-2000 S.L.Freeland - missing CGRO
;      10-Apr-2000 S.L.Freeland - OPTICAL and RADIO
;      22-Jan-2001 S.L.Freeland - HXRS 
;      23-Jan-2002 S.L.Freeland - SMEI
;      12-jul-2002 S.L.Freeland - GOES/SXI
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;      23-Jan-2004, Zarro (L-3Com/GSFC) - changed return to skip for 
;                                         unrecognized instrument
;      11-Feb-2004, S.L.Freeland - VOBS (egso/cosec/vso)
;      12-Mar-2004, S.L.Freeland - STEREO
;                                  (impact/plastic/secchi/swaves/ssc)
;      30-Sep-2006, Zarro - added HINODE
;       5-oct-2006, S.L.Freeland - sterinstr->hinodeinstr
;      15-jan-2009, S.L.Freeland - proba2 (swap&lyra)
;      15-feb-2010, S.L.Freeland - sdo(!)
;      24-mar-2012, S.L.Freeland - iris - (while I was "in there" , repaired an ancient chianti artifact)
;      10-apr-2013, S.L.Freeland - so (solar orbiter) - still plan to make this auto updating via $SSW/gen/setup/setup.ssw_env, but not this rev.
;
;   Common Block:
;      ssw_path_private1 - for !path when called with /save and /restore
;      
;   Method:
;      uses keyword inheritance for Instrument keywords 
;      uses <expand_path> for additions
;
;   Notes:
;      adding an Instrument tree also adds the associated Mission tree
;-
; common for save and restore function
common ssw_path_private, save_path
save=keyword_set(save)
restore=keyword_set(restore)
remove=keyword_set(remove)

; restore function
if restore then begin
   if n_elements(save_path) eq 0 then begin
      message,/info,"No !path saved yet, returning..."
   endif else begin
      message,/info,"Restoring !path from last save..."
      !path=save_path
   endelse
   return						; early exit...
endif
quiet=keyword_set(quiet)

if save then begin
   if not quiet then $
      message,/info,"Saving !path (before changes); use IDL> ssw_path,/restore to recover"
   save_path=!path				   ; save !path on request
endif

; system dependent !path delimiter
pdelim=([':',','])(strupcase(!version.os) eq 'VMS')	; function!!!
pdelim=([pdelim,';'])(strpos(!path,';') ne -1)   
fdelim=get_delim()
oldpath=str2arr(!path,pdelim)			 	; save contents
nold=n_elements(oldpath)

ssw=get_logenv('SSW')
show=keyword_set(show) or keyword_set(inquire) or keyword_set(print) or keyword_set(more)

; - special package handling until conflicts resolved -
if keyword_set(chianti) then ssw_packages,/chianti,/append, remove=remove
if keyword_set(ztools)  then ssw_packages,/ztools,/append, remove=remove

if show then begin
   prstr,strrep_logenv(str2arr(!path,pdelim),'SSW'),nomore=1-keyword_set(more)
   message,/info,"Number of current paths: " + strtrim(nold,2)
   return
endif

instr=''
if not keyword_set(path) then path=''
if n_elements(_extra) eq 1 then $ 
   instr=tag_names(_extra)

; ---------------------------------------------------------------
; ------------------ MAKE THIS CODE SELF UPDATING ---------------
sinstr=ssw_instruments(/soho)
yinstr=ssw_instruments(/yohkoh) 
smminstr=ssw_instruments(/smm)
radinstr=ssw_instruments(/radio)
optinstr=ssw_instruments(/optical)
packinstr=ssw_instruments(/packages)
spinstr=ssw_instruments(/spartan)
trinstr=ssw_instruments(/trace)
hsinstr=ssw_instruments(/hessi)
csinstr=ssw_instruments(/cgro)
hxinstr=ssw_instruments(/hxrs)
smeinstr=ssw_instruments(/smei)
goesinstr=ssw_instruments(/goes)
vobsinstr=ssw_instruments(/vobs)
sterinstr=ssw_instruments(/stereo)
solbinstr=ssw_instruments(/solarb)
hinodeinstr=ssw_instruments(/hinode)
proba2instr=ssw_instruments(/proba2)
sdoinstr=ssw_instruments(/sdo)
irisinstr=ssw_instruments(/iris)
soinstr=ssw_instruments(/so)

imap=strupcase([sinstr,yinstr,smminstr,radinstr,optinstr,packinstr,spinstr,trinstr,hsinstr,csinstr,hxinstr,smeinstr,irisinstr,goesinstr,vobsinstr,sterinstr,hinodeinstr,proba2instr,sdoinstr,soinstr])
mmap=strupcase([replicate('soho',n_elements(sinstr)),$
                replicate('yohkoh',n_elements(yinstr)), $
                replicate('smm',n_elements(smminstr)), $
                replicate('radio',n_elements(radinstr)), $
                replicate('optical',n_elements(optinstr)), $
                replicate('packages',n_elements(packinstr)), $
                'SPARTAN','TRACE','HESSI','CGRO','HXRS','SMEI','IRIS', $
                replicate('goes',n_elements(goesinstr)),    $
                replicate('vobs',n_elements(vobsinstr)),     $
                replicate('stereo',n_elements(sterinstr)), $
                replicate('hinode',n_elements(hinodeinstr)), $
                replicate('proba2',n_elements(proba2instr)), $
                replicate('sdo',n_elements(sdoinstr)), $
                replicate('so',n_elements(soinstr))])

soho=keyword_set(soho)
yohkoh=keyword_set(yohkoh)
smm=keyword_set(packages)
radio=keyword_set(radio)
optical=keyword_set(optical)
packs=keyword_set(packages)
spartan=keyword_set(spartan)
trace=keyword_set(trace)
hessi=keyword_set(hessi)
cgro=keyword_set(cgro)
hxrs=keyword_set(hxrs)
smei=keyword_set(smei)
goes=keyword_set(goes)
vobs=keyword_set(vobs)
stereo=keyword_set(stereo)
solarb=keyword_set(solarb)
hinode=keyword_set(hinode)
proba2=keyword_set(proba2)
sdo=keyword_set(sdo)
iris=keyword_set(iris)
so=keyword_set(so)

if soho    then instr=[instr,sinstr]
if yohkoh  then instr=[instr,yinstr]
if smm     then instr=[instr,smminstr]
if radio   then instr=[instr,radinstr]
if optical then instr=[instr,optinstr]
if packs   then instr=[instr,packinstr]
if spartan then instr=[instr,spinstr]
if trace   then instr=[instr,trinstr]
if hessi   then instr=[instr,hsinstr]
if cgro    then instr=[instr,cinstr]
if hxrs    then instr=[instr,hxinstr]
if smei    then instr=[instr,smeinstr]
if goes    then instr=[instr,goesinstr]
if vobs    then instr=[instr,vobsinstr]
if stereo  then instr=[instr,sterinstr]
if hinode  then instr=[instr,hinodeinstr]
if proba2  then instr=[instr,proba2instr]
if sdo	   then instr=[instr,sdoinstr]
if iris    then instr=[instr,irisinstr]
if so 	   then instr=[instr,soinstr]
; ---------------------------------------------------------------
; ---------------------------------------------------------------

case 1 of 
   n_params() gt 0:					; optional input path
   keyword_set(ucon): begin
     ucon_path, yohkoh=yohkoh, soho=soho, remove=remove, prepend=prepend
     return						;!! unstructured exit
   endcase

   n_elements(instr) eq 1 and instr(0) eq '' and not keyword_set(save): begin
      ssw_path,/show					;!! recurse
      return						;!! unstructured exit
   endcase
   soho and remove: begin				;!! *** fix this
      remain=where(strpos(oldpath,fdelim+'soho'+fdelim) eq -1,rcnt)
      !path=arr2str(oldpath(remain),pdelim)
      return
   endcase
   yohkoh and remove: begin				;!! *** fix this
      remain=where(strpos(oldpath,fdelim+'yohkoh'+fdelim) eq -1,rcnt)
      !path=arr2str(oldpath(remain),pdelim)
      return						;!! unstructured exit
   endcase
   instr(0) eq '': instr=instr(1:*)
   else:
endcase

instr = strupcase(instr)

ipat=''
mpat=''

; ********** can be made more concise after ssw_instrument update *****
for i=0,n_elements(instr)-1 do begin
   pattern=instr(i)
   mission=wc_where(imap , '*'+pattern+'*' ,pcnt)
   if pcnt eq 0 then begin
      box_message,"Instrument: " + pattern(0) + " not recognized, skipping..." 
;         return
   endif else begin
      mpattern=mmap(mission(0))
      mpat=[mpat,mpattern]
      ipat=[ipat,pattern]
   endelse
endfor

if n_elements(ipat) gt 1 then begin
   ipat=ipat(1:*)
   mpat=mpat(1:*)
endif
; *****************************************************************

delim=(['/','.'])(strupcase(!version.os) eq 'VMS')
proc= (['strlowcase','strupcase'])(strupcase(!version.os) eq 'VMS')
ipat=call_function(proc,ipat)
mpat=call_function(proc,mpat)

if keyword_set(remove) then begin
;  use existing <pathfix.pro> for removal
   if ipat(0) eq '' and path ne '' then ipat=path
   for i=0,n_elements(ipat)-1 do begin
      if strpos(ipat(i),'$') eq 0 then begin
         env=ssw_strsplit(ipat(i),delim,/head,tail=tail)
         pat=concat_dir(get_logenv(env),tail) + delim + '*'
      endif else pat=delim + '*' + ipat(i) + delim + '*'
      pathfix,pat,/quiet
   endfor
endif else begin
   newpath=path
   addinst=ipat(0) ne '' 
   if addinst then begin
;     Add SSW Mission generic (GEN) tree 
      for i=0,n_elements(mpat)-1 do begin
         genpath=concat_dir(concat_dir(ssw,mpat(i) ),'gen')
         if mpat(i) eq 'yohkoh' then genpath = concat_dir(get_logenv('ys'),'gen')
         newpath=[newpath,concat_dir(genpath,(['idl','test'])(keyword_set(test)))]
      endfor

;     Add SSW Instrument tree
      for i=0,n_elements(ipat)-1 do begin
         if keyword_set(ops) then $
            top=concat_dir(concat_dir(concat_dir(ssw,mpat(i)),'ops'),ipat(i) ) else $
            top=get_logenv('SSW_'+strupcase(ipat(i)))
         if top eq '' then top=concat_dir(ssw,concat_dir(mpat(i),ipat(i)) )
         newpath=[newpath,concat_dir(top,(['idl','test'])(keyword_set(test)))]
      endfor
   endif
   np=where(newpath ne '',npcnt)
   if npcnt gt 0 then newpath=newpath(np)
   if npcnt eq 0 then message,/info,"No new paths..." else begin
      for i=0,n_elements(newpath)-1 do pathfix,newpath(i),/remove,/quiet
      sswp=where(strpos(oldpath,ssw) ne -1  and $
		 strpos(oldpath,'idl_libs') eq -1,sswcnt)        ; SSW part of !path
;     generate new path array

      nps=strarr(npcnt*2)
      nps( indgen(npcnt)*2)=concat_dir(newpath,'atest')
      nps( indgen(npcnt)*2 +1)=newpath
      newpath=nps
      new=expand_path('+' + arr2str(newpath,pdelim+ '+'),/array,count=ncount)

;
      sswpaths=''		; SSW part
      trailer=''		; post SSW part
      header=''			; pre  SSW part

      if sswcnt gt 0 then begin
         if sswp(0) ne 0 then header=oldpath(0:sswp(0)-1)
         if sswp(sswcnt-1) ne (n_elements(oldpath)-1) then $
              trailer=oldpath(sswp(sswcnt-1)+1:*) 
         sswpaths=oldpath(sswp(0):sswp(sswcnt-1))
      endif

      case 1 of 
         keyword_set(prepend): sswpaths=[new,sswpaths]
	 keyword_set(full_prepend): header=[new, header]
         else: sswpaths=[sswpaths,new]
      endcase

;     new path array and cleanup
      outarr=[header,sswpaths,trailer]
      outarr=outarr(where(strtrim(outarr,2) ne ''))
      outarr=outarr(uniqo(outarr))
      if not quiet then begin
         if new(0) ne '' then prstr, /nomore, $
            ['Including Paths:',strjustify(str_replace(new,ssw,'$SSW'),/box)] else $
            message,/info,"No matches, nothing added..."
      endif
      !path=arr2str(outarr,pdelim)		; **** update !path ***
   endelse
endelse

newpath=str2arr(!path,pdelim)			 ; save contents
nnew=n_elements(newpath)
case 1 of
   nnew eq nold: begin
     changed=where(newpath ne oldpath,ccnt)
     mess=(['Path ORDER changed ','Path not changed ']) (ccnt eq 0) + $
              "Number of paths: "+strtrim(nnew,2)
   endcase
   else: mess="Number of paths changed from " + strtrim(nold,2) + " to "   + strtrim(nnew,2)
endcase

if not quiet then message,/info,mess

return
end      


