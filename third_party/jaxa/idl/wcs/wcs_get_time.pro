;+
; Project     :	STEREO
;
; Name        :	WCS_GET_TIME()
;
; Purpose     :	Get date/time strings from WCS structures
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	This procedure extracts date/time strings from WCS.TIME
;               substructures.  Depending on the keywords passed, the routine
;               will look for specific elements within the structure.  If not
;               found, it will fall back to look for similar elements.
;
; Syntax      :	Time = WCS_GET_TIME( WCS  [, TAG_USED, keywords ...]  )
;
; Examples    :	Time = WCS_GET_TIME(WCS)        ;Returns OBSERV_DATE
;               Time = WCS_GET_TIME(WCS,/END)   ;Returns OBSERV_END
;               Time = WCS_GET_TIME(WCS,/MID,/CORRECTED)
;                                               ;Returns CORRECTED_MID
;
; Inputs      :	WCS     = Structure from FITSHEAD2WCS
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the date/time found, or the null
;               string if nothing is found.
;
; Opt. Outputs:	TAG_USED  = String containing the tag or expression used to
;                           calculate the time returned.
;
; Keywords    :	START     = If set, look for the start time (OBSERV_DATE).
;                           This is the default.  Fails over to MJD_OBS
;
;               ENDTIME   = Look for the end time (OBSERV_END).  Fails over to
;                           START+EXPTIME.
;
;               AVG       = Look for the average time (OBSERV_AVG).  Fails over
;                           to MJD_AVG, the midpoint time, or (START+END)/2, or
;                           START+EXPTIME/2.
;
;               MID       = Look for the midpoint time (OBSERV_MID).  Fails
;                           over to (START+END)/2, or START+EXPTIME/2.
;
;               CORRECTED = Look for the corrected version of the time.  Fails
;                           over to the uncorrected version.
;
;               FITS      = Look for the FITS creation date (FITS_DATE).
;
;               Although the average and midpoint times are generally treated
;               as synonyms of each other, they aren't necessarily the same.
;               The midpoint time is defined specifically as (START+END)/2,
;               while the average time is defined as "a representative time for
;               the whole observation", with the exact definition being left up
;               to the data provider.
;
; Calls       :	VALID_WCS, TAG_EXIST
;
; Common      :	None.
;
; Restrictions:	Only one of the /START, /ENDTIME, /AVG, or /MID keywords can be
;               passed.
;
; Side effects:	If the MJD_OBS or MJD_AVG keywords are passed, then they will
;               serve as failover values for either corrected or uncorrected
;               times.
;
;               No attempt is made to apply a time correction algorithm if the
;               corrected date/time values are not found.  If only one time is
;               found in the FITS header, there is a possibily that this time
;               has already been corrected.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 10-Jan-2006, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
function wcs_get_time, wcs, tag_used, start=start, endtime=endtime, avg=avg, $
                       mid=mid, corrected=corrected, fits=fits
on_error, 2
;
if not valid_wcs(wcs) then message, 'Input not recognized as WCS structure'
;
;  If no TIME substructure was found, then return the null string.
;
result = ''
tag_used = ''
if not tag_exist(wcs,'TIME') then goto, finish
time = wcs.time
;
;  Collect all the tag names.
;
names = strupcase(tag_names(time))
;
;  If the /FITS keyword was passed, then return the FITS creation date.
;
if keyword_set(fits) then begin
    w = where(names eq 'FITS_DATE', count)
    if count gt 0 then begin
        result = time.(w[0])
        tag_used = 'FITS_DATE'
    endif
    goto, finish
endif
;
;  Look for the exposure time, used in some of the calculations.  If not found,
;  take the difference between the start and end times.
;
w = where(names eq 'EXPTIME', count)
if count gt 0 then exptime = time.(w[0]) else exptime = 0
;
;  Initialize the prefix to look for to either 'OBSERV' or 'CORRECTED'.  This
;  may be changed father downstream.
;
if keyword_set(corrected) then prefix = 'CORRECTED' else prefix = 'OBSERV'
start:
;
;  If the /END keyword was passed, then look for OBSERV_END.  Otherwise, add
;  EXPTIME to the start time.
;
if keyword_set(endtime) then begin
    w = where(names eq prefix+'_END', count)
    if count gt 0 then begin
        result = time.(w[0])
        tag_used = prefix+'_END'
        goto, finish
    end else begin
        w = where(names eq prefix+'_DATE', count)
        if count gt 0 then begin
            result = time.(w[0])
            tag_used = prefix+'_DATE'
            if exptime ne 0 then begin
                result = tai2utc(utc2tai(result)+exptime, /ccsds)
                tag_used = tag_used + '+EXPTIME'
            endif
            goto, finish
        endif
    endelse
;
;  If the /AVG keyword was passed, then look for OBSERV_AVG.  If not found,
;  look for MJD_AVG.  Next, look for OBSERV_MID.  Next, try the midpoint
;  between OBSERV_DATE and OBSERV_END.  Otherwise, add EXPTIME/2 to the start
;  time.
;
end else if keyword_set(avg) then begin
    w = where(names eq prefix+'_AVG', count)
    if count gt 0 then begin
        result = time.(w[0])
        tag_used = prefix+'_AVG'
        goto, finish
    end else begin
        w = where(names eq 'MJD_AVG', count)
        if count gt 0 then begin
            result = time.(w[0])
            mjd = floor(result)
            time = round(8.64d7 * (result - mjd))
            result = utc2str({mjd: mjd, time: time})
            tag_used = 'MJD_AVG'
            goto, finish
        end else begin
            w = where(names eq prefix+'_MID', count)
            if count gt 0 then begin
                result = time.(w[0])
                tag_used = prefix+'_MID'
                goto, finish
            end else begin
                w = where(names eq prefix+'_DATE', count)
                if count gt 0 then begin
                    result = time.(w[0])
                    tag_used = prefix+'_DATE'
                    w = where(names eq prefix+'_END', count)
                    if count gt 0 then begin
                        result = (utc2tai(result) + utc2tai(time.w[0])) / 2.d0
                        result = tai2utc(result, /ccsds)
                        tag_used = '('+prefix+'_DATE+'+prefix+'_END)/2'
                    end else if exptime ne 0 then begin
                        result = tai2utc(utc2tai(result)+exptime/2.d0, /ccsds)
                        tag_used = tag_used + '+EXPTIME/2'
                    endif
                    goto, finish
                endif
            endelse
        endelse
    endelse
;
;  If the /MID keyword was passed, then look for OBSERV_MID.  If not found, try
;  the midpoint between OBSERV_DATE and OBSERV_END.  Otherwise, add EXPTIME/2
;  to the start time.
;
end else if keyword_set(mid) then begin
    w = where(names eq prefix+'_MID', count)
    if count gt 0 then begin
        result = time.(w[0])
        tag_used = prefix+'_MID'
        goto, finish
    end else begin
        w = where(names eq prefix+'_DATE', count)
        if count gt 0 then begin
            result = time.(w[0])
            tag_used = prefix+'_DATE'
            w = where(names eq prefix+'_END', count)
            if count gt 0 then begin
                result = (utc2tai(result) + utc2tai(time.w[0])) / 2.d0
                result = tai2utc(result, /ccsds)
                tag_used = '('+prefix+'_DATE+'+prefix+'_END)/2'
            end else if exptime ne 0 then begin
                result = tai2utc(utc2tai(result)+exptime/2.d0, /ccsds)
                tag_used = tag_used + '+EXPTIME/2'
            endif
            goto, finish
        endif
    endelse
;
;  Otherwise, we must be looking for the start time.
;
end else begin
    w = where(names eq prefix+'_DATE', count)
    if count gt 0 then begin
        result = time.(w[0])
        tag_used = prefix+'_DATE'
        goto, finish
    end else begin
        w = where(names eq 'MJD_OBS', count)
        if count gt 0 then begin
            result = time.(w[0])
            mjd = floor(result)
            time = round(8.64d7 * (result - mjd))
            result = utc2str({mjd: mjd, time: time})
            tag_used = 'MJD_OBS'
            goto, finish
        endif
    endelse
endelse
;
;  If we reached this point, and the prefix is 'CORRECTED', try looking for the
;  uncorrected version.
;
if prefix eq 'CORRECTED' then begin
    prefix = 'OBSERV'
    goto, start
endif
;
finish:
return, result
end
