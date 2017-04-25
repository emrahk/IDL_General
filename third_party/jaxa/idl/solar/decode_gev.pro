pro decode_gev, gev, gev_start, gev_stop, gev_peak,       $
       above=above, class=class,                          $
       fstart=fstart, fstop=fstop, fpeak=fpeak,           $
       location=location, noaa_ar=noaa_ar,                $
       out_style=out_style, debug=debug,                  $
       _extra=_extra, ss=ss, found=found
;+
;   Name: decode_gev
;
;   Purpose: decode gev structures (return event times in desired format)
;
;   Input Parameters:
;      gev - Goes Event (GEV) structure(s) (output of rd_gev, get_gev...)
;  
;   Output Parameters:
;      gev_start - event start time list 
;      gev_stop  - event stop time list
;      gev_peak  - event peak time list
;
;   Keyword Parameters:
;      above  - if set, only return subset >= this GOES class
;      fstart - keyword synonym for gev_start  
;      fstop  - keyword synonym for gev_stop
;      fpeak  - keyword synonym for gev_peak
;      class  - (output) GOES XRay Class (string, such as C2.5, X9.1...)
;      noaa_ar - (output) return NOAA active region - string 'xxxxxx'
;      location - (output) heliographic location - string {N,S}nsdeg{E,W}ewdeg
;      found  - (output flag) - true if at least one event returned
;      ss     - (output) - SubScripts of decoded events (reflects 
;                         events matching ABOVE criteria if set)
;
;      out_style - desired SSW time format for output - default=CCSDS
;                  [see anytim.pro for options, inc 'ecs','vms','ints'...
;      _extra - switch synonyms for OUT_STYLE - supports anytim.pro 
;               format switches such as [/vms] [/ints] [/utc_ints] [/ecs]...
;
;   Calling Examples:
;                       IN     OUT     OUT    OUT
;      IDL> decode_gev, gevin, fstart, fstop, fpeak
;      IDL> decode_gev, gevin, fstart, fstop, fpeak, [,/ecs][,/ccsds][,/int]
;
;      SSWIDL Context Example:
;      Read goes events for desired time range, check/decode events
;           greater than specified level - plot lightcurve around
;           1st event window and read the corresponding trace catalog
;          
;      gev=get_gev(time0, time1)            
;      decode_gev,gev,fstart,fstop, fpeak, above='C1', found=found, ss=ss,/int
;      if found then begin                     ;(at least 1 event > C1)
;         fdur=ssw_deltat(fstop,ref=fstart,/minute)       ; T(start->end)
;         start2peak=ssw_deltat(fpeak,ref=fstart,/minute) ; T(start->peak)
;         peak2end=ssw_deltat(fstop,ref=fpeak,/minute)    ; T( peak->end)
;         time_window,[fstart(0),fstop(0)],t0,t1,min=30   ; event +/- 30 min
;         plot_goes,t0,t1                                 ; plot event window
;         trace_cat,fstart(0),fstop(0),tcat               ; goes -> trace
;         [---- etc.... other event actions... ----]
;      endif
;
;   History:
;      26-June-2000 - S.L.Freeland - simplify GEV:SSWDB cross reference
;      27-oct-2004  - S.L.Freeland - add NOAA_AR and LOCATION output keywords
;       3-dec-2004  - S.L.Freeland - fix typo in doc-header context example
;      15-aug-2005  - S.L.Freeland - fixup old ngdc derived (only integer classes avail)
;      18-dec-2006 -  S.L.Freland - fix bug if new+old mix
;      12-jun-2008 -  S.L.Freeland - per Shaun Bloomfield, handle NOAA>10000 
;      21-Aug-2014 -  K. Tolbert - changed fix for class for older data to include X flares
;-

debug=keyword_set(debug)

found=0
; verify input is a GEV structure...
if not required_tags(gev,'TIME,DAY,PEAK,DURATION,ST$HALPHA') then begin 
   return   
endif

class=strupcase(string(gev.st$class))
; Fix incorrect class in older data (pre 1982?) - e.g. M0.2, X0.2, C0.8 should be M2.0, X2.0, C8.0
;ssold=where(strpos(class,'0.') ne -1 and strlen(class) eq 4 $
;   and strmid(class,0,1) ne 'X',sscnt)
ssold=where(strmid(class,1,2) eq '0.' and strlen(class) eq 4,sscnt)
if sscnt gt 0 then begin
   box_message,'Older data, only integer class info available for some entries'
   class(ssold)=strmid(class(ssold),0,1) + strmid(class(ssold),3,1) + '.0'
endif
                                             
if keyword_set(above) then begin
    ss=where(class ge strupcase(above),ccnt)
    if ccnt eq 0 then begin
       box_message,'No events > CLASS ' + above
       return
    endif      
endif else ss=lindgen(n_elements(gev))
found=ss(0) ne -1                                   ; at least one event

case 1 of 
   data_chk(out_style,/string): 
   data_chk(_extra,/struct): begin 
      out_style='ccsds'
      tag0=(tag_names(_extra))(0)
      if is_member(tag0,'vms,ccsds,int,utc_in,tai,yohk',/ignore_case,/wc) then $
         out_style=tag0
   endcase
   else: out_style='ccsds'
endcase
if debug then stop

class=class(ss)
noaa=gev(ss).noaa
noaa=noaa+([0,10000])(noaa ge 1 and noaa lt 9900 and ssw_deltat(gev,ref='15-jun-2002') gt 0)
; above assumes no GEVs came from AR 10000, which I believe is valid assumption...

noaa_ar=strtrim(noaa,2)
ssnull=where(noaa_ar eq '0',ssncnt)
if ssncnt gt 0 then noaa_ar(ssnull)=''

location=strarr(n_elements(ss))
validloc=where(gev(ss).location(0,*) ne -999,vcnt)
if vcnt gt 0 then begin 
   location(ss(validloc))=$
      (['S','N'])( gev(ss(validloc)).location(1) ge 0 ) + $
                 string(abs(gev(ss(validloc)).location(1)),format='(I2.2)') + $
      (['E','W'])( gev(ss(validloc)).location(0) ge 0 ) + $
                 string(abs(gev(ss(validloc)).location(0)),format='(I2.2)')
endif
gev_start=anytim(anytim2ints(gev(ss)),out_style=out_style,/trunc)
gev_stop=anytim(anytim2ints(gev(ss),off=gev(ss).duration), out_style=out_style,/trunc)
gev_peak=anytim(anytim2ints(gev(ss),off=gev(ss).peak), out_style=out_style,/trunc)
fstart=gev_start
fstop=gev_stop
fpeak=gev_peak

if keyword_set(debug) then stop

return
end
