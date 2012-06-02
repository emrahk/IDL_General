function findper, fl, rng, src=src, nb=nbins, stat=stat, $
   per=periods, norb=norb, evt=evt, time=goodtime, cnts=counts, $
   bary=bary, plot=plot, rate=rate

if (n_params() eq 0) then begin
    print,'USAGE: period = findper(files,prange,[src=source],[nb=nbins], $'
    print,'   [norb=norb],[evt=evt],[bary=bary],[plot=plot],[rate=rate], $'
    print,'   [stat=statistic],[per=periods],[time=goodtime],[cnts=counts])'
    print,'INPUTS:'
    print,'   files : array of filenames to be searched'
    print,'   prange: range of periods to search'
    print,'OPTIONAL ARGUMENTS:'
    print,'   src   : Source Name for automated binary orbit removal'
    print,'   Names : 0115  - 4U 0115+63   : cenx3 - Cen X-3'
    print,'         : 0535  - A0535+26     : herx1 - Hercules X-1'
    print,'         : 1538  - 4U 1538-52   : lmcx4 - LMC X-4'
    print,'         : 1626  - 4U 1626-67   : smcx1 - SMC X-1'
    print,'         : 1657  - OAO 1657-415 : vela  - Vela X-1'
    print,'         : 1907  - 4U 1907+09   : 1417 - 2S1417-624'
    print,'         : 301   - GX 301-2'
    print,'   nb    : number of period bins to search'
    print,'   norb  : skip binary orbit corrections'
    print,'   evt   : specify that you are searching event lists (defaults to LCs)'
    print,'   bary  : use BARYTIME instead of TIME column'
    print,'   plot  : plot times and search results automatically'
    print,'   rate  : Use RATE instead of COUNTS column in a LC'
    print,'OUTPUTS:'
    print,'   stat  : output array containing either chi2 or z2 statistic'
    print,'   per   : output array containing searched periods'
    print,'   time  : the array of corrected input times'
    print,'   cnts  : counts/rates loaded from lightcurves (undefined for event data)' 
    return,0.d
endif

if (NOT keyword_set(nbins)) then nbins=100

;Which source is being used
IF (keyword_set(src) EQ 0) THEN BEGIN
    print,'WARNING: No Source Selected'
    print,' No binary orbital corrections will be done'
    norb=1
ENDIF ELSE BEGIN
    CASE src OF 
        '0115': BEGIN
            print,'4U 0115+63 Chosen'
            t90=49282.12765D
            porb=24.317037d
            asini=140.13d
            ecc=0.3402d
            omega=47.66d
        END
        '0535': BEGIN
            print,'A0535+26 Chosen'
            t90=0.0d            ; *** THIS NUMBER IS WRONG ***
            porb=110.3d
            asini=267.d
            ecc=0.47d
            omega=130d
        END
	'1417': BEGIN
           print,'2S1417-624 Chosen'
           t90=49688.98102d
           ;t90=49689.016167d   WCs value
           porb=42.178d
           asini=188.d
           ecc=0.446d
           omega=300.3d
	END
        '1538': BEGIN
            print,'4U 1538-52 Chosen'
            t90=45625.719d
            porb=3.72839d
            asini=53.5d
            ecc=0.0d
            omega=0.0d
        END
        '1626': BEGIN
            print,'4U 1626-67 Chosen'
            print,'  No known orbital ephemeris'
            norb=1
        END
        '1657': BEGIN
            print,'OAO 1657-415 Chosen'
            t90=48515.99d
            porb=10.44809d
            asini=106.0d
            ecc=0.104d
            omega=93.d
        END
        '1907': BEGIN
            print,'4U 1907+09 Chosen'
            t90=45578.75d
            porb=8.3745d
            asini=80.2d
            ecc=0.16d
            omega=330.0d
        END
        '301': BEGIN
            print,'GX 301-2 Chosen'
            t90=0.0d            ; *** THIS NUMBER IS WRONG ***
            porb=41.498d
            asini=368.3d
            ecc=0.462d
            omega=310.4d
        END
        'cenx3': BEGIN
            print,'Cen X-3 Chosen'
            t90=48561.656702d
            porb=2.08706533d
            asini=39.627d
            ecc=0.0d
            omega=0.0d
        END
        'herx1': BEGIN
            print,'Hercules X-1 Chosen'
            t90=48799.61235d
            porb=1.700167412d
            asini=13.1853D
            ecc=0.0d
            omega=0.0d
        END
        'lmcx4': BEGIN
            print,'LMC X-4 Chosen'
            t90=47741.9904d
            porb=1.40841d
            asini=26.3d
            ecc=0.006d
            omega=0.0d
        END
        'smcx1': BEGIN
            print,'SMC X-1 Chosen'
            t90=47740.35906d
            porb=3.892116d
            asini=53.4876d
            ecc=0.0d
            omega=0.0d
        END
        'vela': BEGIN
            print,'Vela X-1 Chosen'
            t90=48895.2186
            porb=8.964368d
            asini=113.89d
            ecc=0.0898d
            omega=152.59d
        END
        'xper': BEGIN
            print,'X-Per/4U0352+309 Chosen'
            t90=51215.1d
            porb=250.3d
            asini=454.d
            ecc=0.111d
            omega=288.d
        END
        ELSE: BEGIN
            norb=1
            print,'UNKNOWN SOURCE: '+src
            print,' No binary orbital corrections will be done'
        END
    ENDCASE
ENDELSE


;
; If we input a single filename instead of an array,
; convert it to an array so it will work in the routine
; that I wrote below
;
sz=size(fl)
if ( sz(0) eq 0 ) then begin
   fl=[fl]
   sz=size(fl)
endif
numfiles=sz(1)-1

;
; Let's keep things double precision
;
prange=double(rng)

;Read in the data
; If it's event data read in the times
IF (keyword_set(evt)) THEN begin
    for i=0,numfiles do begin
        IF (i EQ 0) THEN BEGIN
            ;Open and read the FITS file
            hd=headfits(fl(i))
            tab=readfits(fl(i),hd,ext=1)
            
            ;Get the times and counts
            IF (keyword_set(bary)) THEN BEGIN
                print,'Using BARYTIME Column for Light Curve'
                rawtime=fits_get(hd,tab,'BARYTIME')
            ENDIF ELSE BEGIN
                print,'Using TIME Column for Light Curve'
                rawtime=fits_get(hd,tab,'TIME')
            ENDELSE
            
            ;Get the time zero and MJD offset
            timezero=fxpar(hd,'TIMEZERO')
            mjdref=double(fxpar(hd,'MJDREFI')) + double(fxpar(hd,'MJDREFF'))
        ENDIF ELSE BEGIN
            ;Open and read the FITS file
            hd=headfits(fl(i))
            tab=readfits(fl(i),hd,ext=1)
            
            ;Get the times and counts
            IF (keyword_set(bary)) THEN BEGIN
                print,'Using BARYTIME Column for Light Curve'
                rawtime=[rawtime,fits_get(hd,tab,'BARYTIME')]
            ENDIF ELSE BEGIN
                print,'Using TIME Column for Light Curve'
                rawtime=[rawtime,fits_get(hd,tab,'TIME')]
            ENDELSE

        ENDELSE
    ENDFOR
;Different read routine for a light curve    
ENDIF ELSE BEGIN
    FOR i=0,numfiles DO BEGIN
        IF (i EQ 0) THEN BEGIN            ; First file only
            ;Open and read the FITS file
            hd=headfits(fl(i))
            tab=readfits(fl(i),hd,ext=1)
            
            ;Get the times and counts
            IF (keyword_set(bary)) THEN BEGIN
                print,'Using BARYTIME Column for Light Curve'
                rawtime=fits_get(hd,tab,'BARYTIME')
            ENDIF ELSE BEGIN
                print,'Using TIME Column for Light Curve'
                rawtime=fits_get(hd,tab,'TIME')
            ENDELSE

            IF (keyword_set(rate)) THEN BEGIN
                counts=fits_get(hd,tab,'RATE')
            ENDIF ELSE BEGIN
                counts=fits_get(hd,tab,'COUNTS')
            ENDELSE
 
            ;Get the time zero and MJD offset
            timezero=fxpar(hd,'TIMEZERO')
            mjdref=double(fxpar(hd,'MJDREFI')) + double(fxpar(hd,'MJDREFF'))
        ENDIF ELSE BEGIN                  ; All other files
            ;Open and read the FITS file            
            hd=headfits(fl(i))
            tab=readfits(fl(i),hd,ext=1)
            
            ;Get the times and counts
            IF (keyword_set(bary)) THEN BEGIN
                print,'Using BARYTIME Column for Light Curve'
                rawtime=[rawtime,fits_get(hd,tab,'BARYTIME')]
            ENDIF ELSE BEGIN
                print,'Using TIME Column for Light Curve'
                rawtime=[rawtime,fits_get(hd,tab,'TIME')]
            ENDELSE

            IF (keyword_set(rate)) THEN BEGIN
                counts=[counts,fits_get(hd,tab,'RATE')]
            ENDIF ELSE BEGIN
                counts=[counts,fits_get(hd,tab,'COUNTS')]
            ENDELSE
 
        ENDELSE
    ENDFOR
    w=where(counts NE 0, cnt)
    if (cnt ne 0) then begin
        rawtime=rawtime(w)
        counts=counts(w)
    endif
    w=' '
ENDELSE

;Having some problems with zero and negatives times,
; Get rid of them
rawtime=rawtime(where(rawtime GT 0))

;delvar,hd,tab,var,tt,ed
hd=' '
tab=' '
var=' '
tt=' '

print,' '
print,'Removing the binary orbit'
print,' '
IF (keyword_set(norb)) THEN BEGIN
    ;Skip the binary orbit corrections
    goodtime=rawtime-(max(rawtime)+min(rawtime))/2.0d ; recenter
    print,' ...skipping...'
ENDIF ELSE begin
    ;Correct for the system's barycenter and then center the
    ; times around zero.
    temptime=(rawtime+timezero)/86400.00d + mjdref        ; convert to days
    goodtime=removeorb(temptime,asini,porb,t90,ecc,omega) ; remove the orbit
    goodtime=goodtime*86400.00d                           ; convert to secs
    goodtime=goodtime-(max(goodtime)+min(goodtime))/2.0d ; recenter
    print,' orbit removed'
ENDELSE

IF (keyword_set(plot)) THEN BEGIN
    plot,goodtime
ENDIF

;delvar,temptime,rawtime
temptime=' '
rawtime=' '


IF (keyword_set(evt)) THEN BEGIN
    ;Let the user know what we're doing
    print,'Working On Event Data'
    print,'Doing a z^2 search'
    print,' '
    
    ;z^2 deals with freqs and binsizes, not periods and numbins
    ; Have to convert 
    frange=[1.d/min(prange),1.d/max(prange)]
    bsize=(max(frange)-min(frange))/(nbins+1)
    
    ;Calculate the statistic
    z2_range,goodtime,frange,2,stat,low,high,binsize=bsize,silent=1
    
    ;Convert from freqs back to periods
    freq=(low+high)/2.d
    periods=1.d/freq
        
    ;Let the user know it's done
    print,'done z2_range'
ENDIF ELSE BEGIN
    ;Let the user know what we're doing
    print,'Working on a Light Curve'
    print,'Doing a chi^2 search'
    print,' '
    
    ;Calculate the statistic
    chi2_fold,counts,goodtime,prange,stat,nper=nbins,periods=periods,silent=1
    
    ;Let the user know it's done
    print,'done chi2_fold'
ENDELSE

;What's the period at the max statistic
q=max(stat,w)
pers=periods(w)

IF (keyword_set(plot)) THEN BEGIN
    plot,periods,stat,psym=10,ystyle=16,xstyle=1
ENDIF

return,pers
end

