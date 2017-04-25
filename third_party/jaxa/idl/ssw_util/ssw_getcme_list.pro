function ssw_getcme_list, time0, time1, _extra=_extra, refresh=refresh, $ 
   cdaw=cdaw, cactus=cactus, $
   debug=debug, search_array=search_array, $
   tcount=tcount, count=count, $
   sswdb=sswdb, nosswdb=nosswdb, save_sswdb=save_sswdb , force_save=force_save
;
;+
;   Name: ssw_getcme_list
;
;   Purpose: return LASCO CME data for input time range & optional search params
;
;   Input Parameters:
;      time0 - optional  time or start time of range (mission list if none)     
;      time1 - stop time if range
;
;   Output:
;      function returns list as structure, including ssw compliant times
;
;   Keyword Parameters:
;      cdaw - if set, use list at cdaw.gsfc.nasa.gov/CME_list/ (default..)
;             By: Gopalswamy, N., Yashrio, S., Michalek, G. and Numes, S.
;      count - number of elements (cme matches/structures) returned
;      tcount - number of elements within intput time range 
;      search_array - optional search strings (see struct_where.pro)   
;                     (valid tags include {cpa, width, lspeed, accel,remarks})
;      sswdb - use sswdb index (new default); socket -> gsfc
;      cactus - if set, apply times&search to CACTUS list 
;      nosswdb - if set, do NOT use the sswdb catalog; instead, re-parse original
;                WWW at either CDAW (defalt) or CACTUS (or future lists..)
;                (used by SSWDB generators - much SLOWER...)
;      save_sswdb - (restricted) - generate the SSWDB cdaw&cactus catalogs 
;      force_save - if /save_sswdb, force overwrite even if no changes
; 
;   Calling Examples:
;      cmes=ssw_getcme_list('15-mar-2001','15-jul-2001') ; all within range
;      halos=ssw_getcme_list(search=['width=360'])      ; mission Halos
;      partial=ssw_getcme_list('1-jan-2005','1-feb-2005', $
;         search=['width=180~360','lspeed>1000',''accel>10'])
;
;       Note: values of ACCEL etc set to -9999 are undefined
;       For example, high speed halos w/high linear speed and negative ACCEL
;       which only include valid ACCEL values....
;       IDL> fhalo=ssw_getcme_list( search= $
;          ['width=360','lspeed>500','accel=-1000~0'])
;
;   Context Example: - show times of all CDAW Halo events in list via utplot
;                      Then get&plot CACTUS Halos for same time range
;      IDL> halos=ssw_getcme_list(search=['width=360']) ; mission search
;      IDL> utplot,halos, halos.lspeed,psym=2
;      IDL> time_window,halos,t0,t1  ; cdaw halo time range -> T0&t1
;      IDL> cact_halos=ssw_getcme_list(t0,t1,/cactus,search=['width=360']) 
;      IDL> utplot,cact_halos,cact_halos.lspeed, psym=4
;         
;   Method:
;      1st call - socket access list -> convert to "ssw" structure 
;                 subsequent, use common (/REFRESH to force recopy->structs)
;
;   Restrictions:
;      more of a comment - 1st call in session will take a minute or two
;      subsequent calls Much faster - /NOSSWDB  generally only used by 
;      meta generator but feel free... - that goes back to the original
;      site and reparses the entire site->ssw structures
;      Note that CDAW & CACTUS lists (and output structures) contain different
;      info so not search parameters work for both - but times and a subset of 
;      tags ARE equivilent, including {LSPEED,CPA,WIDTH}
;
;   History:
;      8-sep-2005 - S.L.Freeland - Written
;     14-Sep-2005 - S.L.Freeland - change 2nd order field names; def vals 
;     21-sep-2005 - S.L.Freeland - Added 'event_name' tag "for later" 
;                   make sswdb default
;     27-sep-2005 - S.L.Freeland - def values-> (-9999) + documentation
;     28-sep-2005 - S.L.Freeland - add TCOUNT output keyword&function
;     23-FEB-2006 - S.L.Freeland - broke cdaw www parse -> ssw_getcme_cdaw.pro
;                   and enabled /CACTUS (now a wrapper for these and future cme lists)
;      7-mar-2006 - S.L.Freeland - (restricted) - if /SAVE_SSWDB set, only
;                   overwrite existing if anything changed $SSDB:remove
;                   (use /FORCE_SAVE to override default)
;

common ssw_getcme_cdaw_blk, cmestr_mission_cdaw   ; mission long lists ("cache")
common ssw_getcme_cactus_blk, cmestr_mission_cactus 

cactus=keyword_set(cactus)

cme_site=(['cdaw','cactus'])(cactus)
debug=keyword_set(debug)
refresh=keyword_set(refresh) 
sswdbf=cme_site+'_cme_index.geny' ; $SSWDB name
sswdb_url='http://sohowww.nascom.nasa.gov/sdb/packages/cmes/' + sswdbf
sswdb_dir=concat_dir('$SSWDB','packages/cmes')
sswdb_nam=concat_dir(sswdb_dir,sswdbf)

if keyword_set(save_sswdb) and is_member(get_user(),'freeland') then begin
   force=keyword_set(force_save) 
   box_message,'Generating SSWDB catalogs...
   cdaw=ssw_getcme_cdaw()
   sname=sswdb_nam
   restgenx,file=sname,ecdaw
   if str_diff(ecdaw,cdaw) or force then begin 
      box_message,'Updating SSWDB CDAW/CME catalog'
      savegenx,file=sswdb_nam,cdaw,/over
   endif else box_message,'No changes in CDAW/CME since last SSWDB generation'

   cactus=ssw_getcme_cactus()
   sname=str_replace(sswdb_nam,'cdaw','cactus')
   restgenx,file=sname,ecactus
   if str_diff(ecactus,cactus) or force then begin 
      box_mesage,'Updating SSWDB CACTUS catalog
      savegenx,file=sname,cactus,/over
   endif else box_message,'No changes in CACTUS/CME since last SSWDB generation'
   return,''   ; <<<<<<<< early exit
endif

if keyword_set(nosswdb) then begin 
   box_message,'Warning: parsing entire remote dbase; may take a while...'
   cmestr_mission=call_function('ssw_getcme_'+cme_site,refresh=refresh)
endif else begin 
;  TODO - use cache_data.pro in following segment....
   cache='cmestr_mission_'+cme_site	
   reread=1
   esat=execute('reread=n_elements('+cache+') eq 0 or refresh')
   if reread then begin  
      if file_exist(sswdb_nam) then lfile=sswdb_nam else begin  ; local?
         tmp=get_temp_dir()
         lfile=concat_dir(tmp,sswdbf)
         box_message,'First access remote, may take a minute..'
         sock_copy,sswdb_url,out_dir=tmp                             ; gsfc->local
      endelse
      if not file_exist(lfile) then begin 
         box_message,'Problem with cme index access'
         return,-1
      endif
      restgenx,file=lfile,cmestr_mission      ; db->variable structure-vector
      estat=execute(cache+'=cmestr_mission')  ; -> cache
;     ----------------------------------------; cache_data
   endif else estat=execute('cmestr_mission='+cache)
endelse
estat=execute(cme_site+'_cmestr_mission=cmestr_mission') ; -> cache

sscnt=-1
case n_params() of
   0: retval=cmestr_mission
   1: begin    
        dt=abs(anytim(time0) - cmestr_mission.anytim_dobs)
        sss=(where(dt eq min(dt),sscnt))(0)
   endcase
   2: begin 
       sss=where(anytim(time0) le cmestr_mission.anytim_dobs and $ 
                  anytim(time1) ge cmestr_mission.anytim_dobs,sscnt)
   endcase
endcase
 
if sscnt gt 0 then retval=cmestr_mission(sss)

count=0
tcount=sscnt

if n_elements(retval) eq 0 then begin 
   box_message,'No cmes meet time/search criteria'
   retval=-1
endif

; now perform optional searches...

if data_chk(search_array,/string) then begin 
   sss=struct_where(retval,test=search_array, _extra=_extra, count)
   if count eq 0 then begin 
      box_message,['No matches for your search criteria:',search_array]
      retval=''
   endif else retval=retval(sss)
endif

count=n_elements(retval) * (data_chk(retval,/struct))    

if debug then stop,'before return'

return,retval
end
