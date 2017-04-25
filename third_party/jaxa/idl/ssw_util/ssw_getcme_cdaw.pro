function ssw_getcme_cdaw, time0, time1, _extra=_extra, refresh=refresh, $ 
   debug=debug, cdaw=cdaw, noevent_name=noevent_name
;
;+
;   Name: ssw_getcme_cdaw
;
;   Purpose: return LASCO CME data from CDAW site -> SSWIDL structure
;
;   Output:
;      function returns list as structure, including ssw compliant times
;
;   Keyword Parameters:
;      cdaw - if set, use list at cdaw.gsfc.nasa.gov/CME_list/ (default..)
;             ( per 23-feb-2006, always implied for this routine)
;             By: Gopalswamy, N., Yashrio, S., Michalek, G. and Numes, S.
;  
;   Calling Examples:
;       PRIMARILY USED TO GENERATE missiong long CDAW->SSWDB (or reparse)
;       Users may use wrapper 'ssw_getcme_list.pro' for CDAW, CACTUS 
;       searches by time and CME parameter - see header. for example calls.
;         
;   Method:
;      1st call - socket access list -> convert to "ssw" structure 
;                 subsequent, use common (/REFRESH to force recopy->structs)
;
;   History:
;      8-sep-2005 - S.L.Freeland - ssw_getcme_list w/cdaw hooks Written
;     23-feb-2006 - S.L.Freeland - broke CDAW parsing logic from ssw_getcme_list
;                   and assume That routine is primary ssw/CME interface
;                   to CDAW, CACTUS , and future lists
;-
common ssw_getcme_cdaw_blk,cmestr_mission_cdaw

debug=keyword_set(debug)
refresh=keyword_set(refresh) 
cdaw_url='http://cdaw.gsfc.nasa.gov/CME_list/UNIVERSAL/text_ver/univ_all.txt'

refresh=keyword_set(refresh) or n_elements(cmestr_mission_cdaw) eq 0
top=cdaw_url ; 
if refresh then begin 
   box_message,'1st access and refresh; url->structure... please be patient
   sock_list,top,list
   if n_elements(list) lt 25 then begin 
      box_message,'Problem listing '+top
      return,''
   endif
  
   topss=(where(is_number(strmid(list,0,1))))(0) ; start of valid data
   lcols=str2cols(list(topss:*),/trim)
   strtab2vect,lcols,date,time,cpa,width,lspeed,inits,finals,second_order,accel,mass,kenergy,mpa,remarks

   cnvts=str2arr('cpa,width,lspeed,inits,finals,second_order,accel,mass,kenergy')
   for i=0,n_elements(cnvts)-1 do begin
 
      estat=execute(cnvts(i)+"(where(1-is_number("+cnvts(i)+")))='-9999'")
      estat=execute(cnvts(i)+"=float("+cnvts(i)+")")
   endfor
   cmestr={Anytim_dobs:0.d,mjd:0l,time:0l,cpa:0,width:0,lspeed:0,$
qspeed_init:0,qspeed_final:0,qspeed_2or:0,accel:0.0,mass:0.0,kenergy:0.0,mpa:0,remarks:'',event_name:''}
   dobs=anytim(date + ' ' + time,/utc_int)
   cmestr_mission_cdaw=replicate(cmestr,n_elements(dobs))
   cmestr_mission_cdaw.mjd=dobs.mjd
   cmestr_mission_cdaw.time=dobs.time
   cmestr_mission_cdaw.anytim_dobs=anytim(dobs)
   cmestr_mission_cdaw.cpa=fix(cpa)
   cmestr_mission_cdaw.width=fix(width)
   cmestr_mission_cdaw.lspeed=fix(lspeed)
   cmestr_mission_cdaw.qspeed_init=fix(inits)
   cmestr_mission_cdaw.qspeed_final=fix(finals)
   cmestr_mission_cdaw.qspeed_2or=fix(second_order)
   cmestr_mission_cdaw.accel=accel
   cmestr_mission_cdaw.mass=mass
   cmestr_mission_cdaw.kenergy=kenergy
   cmestr_mission_cdaw.mpa=fix(mpa)
   cmestr_mission_cdaw.remarks=remarks
endif 

if not keyword_set(noevent_name) and refresh then begin
   box_message,'Deriving CME/CDAW names, please be patient..'
   retval=ssw_cme2event(cmestr_mission_cdaw)
   delvarx,cmestr_mission_cdaw
   cmestr_mission_cdaw=retval
endif

return,retval
end
