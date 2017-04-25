function ssw_gxd_remove_flares, datain, flaress=flaress, $
   remove=remove, fill_data=fill_data, $
   pad_minutes=pad_minutes, above_class=above_class 
;+ 
;   Name: ssw_gxd_remove_flares
;
;   Purpose: ID,fill, or remove GOES events times from input dbase 
;
;   Input Parameters:
;      datain - input time structures (from rd_gxd only, for today at least)
;              (actually the ID/remove should be dbase independent...)
;
;   Output Parameters:
;      function returns time series data with GEV (flare) times filled/remove
;
;   Optional Keyword Parameters:
;      above_classs - optionall lower limit on GOES class (via decode_gev.pro)
;      remove - if set, remove flare times from input
;      fill_data - If defined, fill (don't remove) times using this Value
;                  (only works if input is GXD data)
;      pad_minutes - optional window around flare times to remove in minutes
;                    [may be scalar [+/-n mins] or 2 element [-n,+m mins]
;                    (relative per [GEV START-n,  GEV STOP +m] )
;
;      flaress - (output) boolean n_elemets(datain) -  "in progress"
;
;   History:
;      5-May-2003 - S.L.Freeland
;
;   Method: 
;      Read GEV (goes event dbase) for events within input data time
;      and remove/fill those portions of timeseries data 
; 
;   Calls:
;      time_window, rd_gev, decode_gev and SSW-gen stuff
;
;   Cut&Paste check:
;      IDL> t0='1-mar-1998' & t1='1-apr-1998' & delvarx,xx  ; times
;
;      IDL> wdef,xx,1024,512,/ur                ; make a window
;      IDL> linecolors                          ; fancy colors
;      IDL> plot_goes,t0,t1,back=11,color=7     ; plot goes
;      IDL> rd_gxd,t0,t1,/one,/goes8,gxd        ; read the gxd
;      IDL> noffgxd=ssw_gxd_remove_flares(gxd,pad_min=[-5,60])  
;      IDL> outplot,noffgxd,noffgxd.lo,color=2,psym=3
;
;   Restrictions:
;      Of course, only as good as the GEV data base
;      (maybe I can use this to ID/patch missing GEV events... tbd)
;      Removal sensitive to definition of 'FLARE Stop Time' as
;      implemented by SEC/NOAA - for long baslines, you may want
;      to use large numbers for PAD_MIN=[-n,+m]
;
;-


okin=required_tags(datain,'time,day') or $
     required_tags(datain,'time,mjd') or $
     required_tags(datain,'DATE_OBS')

if not okin then begin 
   box_message,'Need vector of SSW-ready time structures, returning...'
   return,-1
endif 

case n_elements(pad_minutes) of
   0: pad_minutes=[0,0]
   1: pad_minutes=replicate(pad_minutes,2)
   else: pad_minutes=pad_minutes(0:1)
endcase
padsec=abs(pad_minutes)*60.
flaress=lonarr(n_elements(datain))   ; boolean flare?

time_window,datain,time0,time1,minutes=[100]   

rd_gev,time0,time1,gev           ; read GXD database around input times

decode_gev,gev,fstart,fstop,fpeak,out='tai',above=above_class

intimes=anytim(datain,/tai)          

nevts=n_elements(fstart)
box_message,'Found ' + strtrim(nevts,2) + ' events within time range'

for i=0,nevts-1 do begin                           ; fill boolean
   flaress=flaress or (intimes ge (fstart(i) - padsec(0)) $
                   and intimes le (fstop(i)  + padsec(1))   )
endfor

; define return data  
ffss=where(flaress,ffcnt)
noflare=where(1-flaress,nfcnt)

retval=-1
case 1 of 
   keyword_set(fill_data): begin 
      retval=datain
      if  ffcnt gt 0  then begin 
         if required_tags(retval,'lo,hi') then begin 
         retval(noflare).lo=fill_data
         retval(noflare).hi=fill_data
         endif else box_message,'Only GXD records may be FILLED..'
      endif
   endcase
   else: $ 
      if nfcnt gt 0 then retval=datain(noflare) else $ 
         box_message,'Nothing left after removing flares!'
endcase

return,retval
end
             

