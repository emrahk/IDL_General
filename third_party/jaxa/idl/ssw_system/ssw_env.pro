pro ssw_env, soho=soho, yohkoh=yohkoh, loud=loud, _extra=_extra, $
	remove=remove, path_only=path_only, setup=setup
;+
;   Name: ssw_env
;
;   Purpose: add & remove SSW elements IDL !path, optionally run setup.NNN
;
;   Category: system, environment
;
;   Calling Sequence:
;      ssw_path,/instrument [,/instrument ,/remove]
;
;   History:
;      15-Jun-1995 (SLF)
;-
loud=keyword_set(loud)

instr=''
if keyword_set(_extra) then instr=tag_names(_extra)
stop
sinstr=ssw_instruments(/soho)
yinstr=ssw_instruments(/yohkoh) 

imap=strupcase([sinstr,yinstr])
mmap=strupcase([replicate('soho',n_elements(sinstr)),$
   replicate('yohkoh',n_elements(yinstr))])

if keyword_set(soho)   then instr=[instr,sinstr]
if keyword_set(yohkoh) then instr=[instr,yinstr]

case 1 of 
   n_elements(instr) eq 1 and instr(0) eq '': begin
      message,/info,"Need to supply at least one keyword
      return
   endcase
   instr(0) eq '': instr=instr(1:*)
   else:
endcase

instr = strupcase(instr)

ipat=''
mpat=''

for i=0,n_elements(instr)-1 do begin
   pattern=instr(i)
   mission=where(imap eq pattern ,pcnt)
   if pcnt eq 0 then message,/info,"Instrument: " + pattern(0) + $
      " not recognized" else begin
      mpattern=mmap(mission(0))
      mpat=[mpat,mpattern]
      ipat=[ipat,pattern]
   endelse
endfor

if n_elements(ipat) gt 1 then begin
   ipat=ipat(1:*)
   mpat=mpat(1:*)
endif

delim=(['/','.'])(strupcase(!version.os) eq 'VMS')
proc= (['strlowcase','strupcase'])(strupcase(!version.os) eq 'VMS')

stop
if keyword_set(remove) and ipat(0) ne '' then begin
       
   ipat=delim+ call_function(proc,ipat)+delim
   if loud then prstr,['Removing paths:',ipat]
print,(1-loud)
   pathfix,ipat, quiet=(1-loud)
endif else begin
   
endelse

return
end      


