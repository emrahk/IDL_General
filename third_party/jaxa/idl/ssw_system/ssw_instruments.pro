function ssw_instruments, _extra=_extra, inc_mission=inc_mission
;+
;   Name: ssw_instruments
;
;   Purpose: return list of instruments under SSW 
;
;   Calling Sequence:
;      instr=ssw_instruments([/soho,/yohkoh,/trace])
;
;   Restrictions:
;      assumes SSW_MISSIONS, SSW_xxx_INSTR defined in setup
;-
missions=str2arr(get_logenv('SSW_MISSIONS'),' ')

; missions may be passed as keyword (inheritence)
if n_elements(_extra) eq 1 then missions=tag_names(_extra)
missions=strupcase(missions)

retval=''
for i=0,n_elements(missions)-1 do begin
   app=(['',missions(i)+'_'])(keyword_set(inc_mission))
   instr=str2arr(get_logenv('SSW_'+missions(i)+'_INSTR'),' ')
   if instr(0) ne '' then retval=[retval,app+instr]
endfor

; remove junk
ss=where(retval ne '',sscnt)
if sscnt eq 0 then retval='' else retval=retval(ss)

return,strupcase(retval)

end
