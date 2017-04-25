pro ssw_addmm_gen, mmmissions, no_startup=no_startup
;
;+
;   Name: ssw_addmm_gen
;
;   Purpose: add $SSW_MMM gen libraries for multi-instrument missions
;
;   Input Parameters:
;      mmmissions - optional vector of missions to include
;
;   Keyword Parameters:
;      no_startup - (switch) if set, don't execute $SSW/<MM>/setup/IDL_STARTUP(s) 
;
;   History:
;      9-March-2005 - S.L.Freeland - long planned rationalization...
;     27-sep-2005   - S.L.Freeland - fix multi insstr/mission bug
;                                    reported by W.Thompson 
;     18-oct-2005   - S.L.Freeland - add <MM>/gen/setup/IDL_STARTUP support 
;                                    and /NO_STARTUP keyword 
;     26-jun-2006   - S.L.Freeland - turn on solarb..
;     30-Sep-2006   - Zarro - added HINODE
;-
on_error,1
startup=1-keyword_set(no_startup) ; default is to execute MM IDL_STARTUP(s)

if n_elements(mmmisions) eq 0 then $
   mmmissions=['stereo','vobs','radio','optical','solarb','hinode']

nmm=n_elements(mmmissions)

sswinstr=strtrim(strlowcase(get_logenv('SSW_INSTR')),2)  ; current user list
sswinstr=str2arr(strcompress(sswinstr),' ')

lowmiss=strlowcase(mmmissions)
upmiss=strupcase(mmmissions)
mmgen=concat_dir(concat_dir(concat_dir('$SSW',lowmiss),'gen'),'idl')
sugen=concat_dir(str_replace(mmgen,'idl','setup'),'IDL_STARTUP')

for i=0,nmm-1 do begin 
  mminst=str2arr(get_logenv('SSW_'+upmiss(i)+'_INSTR'),' ') ; mission insts,
  ss=where_arr(lowmiss(i)+'/'+sswinstr,mminst,count)
  if count gt 0 and strpos(!path,mmgen(i)) eq -1 then begin  
      ssw_path,mmgen(i),/quiet
      if startup then main_execute,sugen(i) 
  endif
endfor

return
end
