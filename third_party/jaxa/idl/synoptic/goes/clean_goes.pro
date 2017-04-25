;+
; Project     :  SDAC
;
; Name        :  CLEAN_GOES
;
; Purpose     :  This procedure finds and removes the glitches in the
;         GOES xray data due to the changes in the analogue
;         filtering used to accommodate the full dynamic range.
;
; Category    :  GOES
;
; Explanation :  CLEAN_GOES finds bad data points (spikes or bad values due to gain changes)
;                eliminates them, and interpolates across them by using the surrounding
;                points.
;
;
; Use         : clean_goes, goes, tarray = tarray, yarray = yarray, yclean = yclean, $
;               bad0 = bad0, bad1 = bad1, numstat=numstat, tstat=tstat, stat=stat, error=error
;
; Inputs      :
;
; Opt. Inputs : GOES - structure obtained from RD_GXD with tags time, day, lo, and hi
;        replacing TARRAY and YARRAY.
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : TARRAY- time in utime format, sec from 1-jan-1979, dblarr(nbins)
;        YARRAY- raw GOES, fltarr(nbins, 2)
;        YCLEAN- despiked YARRAY
;        SATELLITE- GOES satellite number, GOES8 and 9 are considerably more
;        resilient to gain change spikes, use integers
;        BAD0 - indices of cleaned Lo channel
;        BAD1 - indices of cleaned Hi channel
;        NUMSTAT- Default value is -1, if not then data are assumed
;        to originate in SDAC format GOES fits files.  Gain change
;        times are indicated in TSTAT
;        TEST- scaling factor for glitch test, default 7, larger
;        values make the clean more (too) sensitive.
;        SECOND- Second pass through for clean
;        TSTAT
;        STAT
;        ERROR
;
; Calls       : CHECKVAR, ANYTIM, DATATYPE, FIND_FITS_BAD, FCHECK, SPLINE, F_DIV
;
; Common      : None
;
; Restrictions:
;
; Side effects: None.
;
; Prev. Hist  :
;
; Modified    : New version of CLEAN_GOES, based on clean_goes.old by AKT
;        This version uses a faster and simpler despike algorithm
;        based exclusively on scaled first differences.  This is
;        a test version.  When the spikes are located, the spline
;        interpolation algorithm is used to fill the data.
;        Version 1, ras, 29-jan-1997
;        Version 2, ras, 4-feb-1997, good data is checked to avoid
;        repeats before using spline interpolation.  Spline interpolation
;        only used over short intervals containing bad data points
;        instead of passing the entire observing interval to the
;        spline routine.
;        Version 3, ras, 7-feb-1997, data isn't cleaned if it is
;        less than default values of ([7e-8,1e-8])(ich), cleaning
;        test more stringent on GOES8+, removed 2nd cleaning,
;        added satellite keyword.
;        Version 4, RAS, 9-apr-1997, modified cleaning algorithm to
;        exclude long gaps.
;        Version 5, RAS, 19-May-1997, long gap algorithm patched
;        temporarily, needs re-examination.
;      19-Apr-2007, Kim.  Made a few variables long (nstep, nstep2) and added
;     test to skip cleaning if every element in yarray is bad.
;   8-Aug-2008, Kim.
;     1. Also, changed test for spikes: changed test to either y val used in difference
;       > ymin,  and removed adding one to bad.
;     2. Previously called find_fits_bad only if numstat ne -1, but it also
;       checks for data values = -99999, so always call it.
;     3. Fixed calculation of bad point indices when excluding long gaps
;     4. If old satellite (sms-1,sms-2,goes1,2,3) set different ymin
;   5-Jun-2012, Kim. Reformatted indentations to make easier to read
;-
;==============================================================================

pro clean_goes, goes, tarray = tarray, yarray = yarray, yclean = yclean, $
second=second, test=test, satellite=satellite, $
bad0 = bad0, bad1 = bad1, numstat=numstat, tstat=tstat, stat=stat, error=error

if datatype(goes) eq 'STC' then begin
    tarray = anytim( /sec, goes)
    yarray = reform( [goes.lo,goes.hi],n_elements(tarray), 2)
    endif

error = 1
yclean = yarray
checkvar, numstat, -1
checkvar, second, 0
checkvar, satellite, 6
trel = tarray - tarray(0)
nel  = n_elements(trel)
if trel(nel-2) eq trel(nel-1) then trel(nel-1)=trel(nel-2)+3.0

npts = n_elements(tarray)

bad0 = -1 & bad1 = -1

; Return indices of bad points (data=-99999, gain change, eclipse, calibration,
; or detector off) in bad0, bad1 for chan 0, 1.
find_fits_bad, tarray, yarray, bad0, bad1, numstat, tstat, stat

old_sat = (satellite le 3) or (satellite ge 91)
for ich = 0,1 do begin
    ;print,'channel = ',ich
    y = yarray(*,ich)

    ;
    ;  We have two ymin's, one for a comparison (ymin) and the other for a floor.
    ;
    ymin = ([7e-8, old_sat ? 4e-8 : 1e-8])(ich)
    ymin2= ([1e-8, 1e-10])(ich)
    y = y>ymin2

    ;if ich eq 1 then test = .22 else test = .17
    checkvar,test, 7.
    if satellite ge 8 and ich eq 0 then test = test/5.
    if numstat ne -1 then if ich eq 0 then bad = bad0 else bad = bad1 else begin

        ; 8-aug-2008, Kim.  changed from ....*test ge 1 and y gt ymin.  If spike is in neg direction,
        ; wasn't finding it if it was < ymin.  Now if either the low point or the one before
        ; it is > ymin, it will find it.  Also, I don't think adding one to bad is needed.
        bad   =where( abs(f_div( f_div(y(1:*)-y,y), $
        (trel(1:*)-trel)/3.0 ) )* test ge 1 and (y(1:*) gt ymin or y gt ymin), nbad)
        ;    if nbad ge 1 then bad = bad+1
        endelse
    if bad(0) ne -1 and n_elements(bad) lt n_elements(y) then begin
        ;
        ; Remove spikes and interpolate
        ;

        y(bad) = 0.0
        ;
        ; Start at the first bad data point, select a range 10 points below to 200 points
        ; beyond,  if there are no points in the last 10, use spline.  Go on to the
        ; next set of bad points and repeat
        bad_left = bad
        nleft = n_elements(bad_left)
        nstep = 150L
        nstep2= 50L
        while nleft gt 0 do begin

            ist = bad_left(0) - 10 > 0
            addmore:
            ind = bad_left(0) + nstep < (nel-1)
            nuse= ind-ist+1
            wuse= lindgen(nuse) + ist
            ;
            ;  Are there any bad points in the tail of the group of points selected?
            ;  If so take another nstep2
            ;
            wend= where(bad_left ge (ind-9) and  bad_left le ind, nend)
            if nend gt 1 and ind lt (nel-1) then begin
                nstep = nstep + nstep2
                goto, addmore
                endif
            ;
            ;  Now we have a sub interval including bad points and good points
            ;  to pass into the spline interpolation routine.  There are
            ;  some repeated points in the Yohkoh GOES database which must
            ;  be filtered from the Spline routine.
            ;
            yuse = y(wuse)
            tuse = trel(wuse)
            wbad = wuse( where_arr( wuse, bad_left) )

            wg=where(yuse gt 0.0 and tuse(1:*)-tuse gt 0.0, ngd)
            if ngd gt 5 then begin
                ;
                ;    Exclude long data gaps from interpolation correction
                ;
                if n_elements( wbad) ge 50 then begin
                    wbad2 = where(wbad ne (wbad(1:*)-1), nbad2)
                    if nbad2 eq 0 then wcont=reform([0,n_elements(wbad)-1],2,1) else $
                    wcont=transpose([[0,wbad2+1],[wbad2,n_elements(wbad)-1]])
                    length = wcont(1,*)-wcont(0,*)+1
                    wshort=where( length lt 10, nshort)
                    if nshort ge 1 then begin
                        wbad2 = 0
                        ;            for i=0,nshort-1 do wbad2 = [wbad2, length(wshort(i))+wcont(0,i)] ; 8-Aug-2008
                        for i=0,nshort-1 do wbad2 = [wbad2, indgen(length[wshort[i]])+wcont[0,wshort[i]]]
                        wbad = wbad(wbad2(1:*))
                        endif else begin
                        wbad = -1
                        endelse
                    endif

                if wbad(0) ne -1 then $
                yclean(wbad,ich) = spline(tuse(wg), (yuse(wg) >1.e-10), trel(wbad) )
                endif $
            else clean_error=1
            wleft = where( bad_left gt ind, nleft)
            if nleft gt 0 then bad_left=bad_left(wleft)
            endwhile
        if ich eq 0 then bad0 = bad else bad1 = bad
        yclean(*,ich) = yclean(*,ich)>ymin2
        endif
    endfor

if n_elements(y) gt 1 then delvarx, y

error=fcheck(clean_error,0)  ;something is returned
;if not error and not second then begin
;     clean_goes, tarray=tarray, yarray=yclean, yclean=yclean1,numstat=-1,$
;     error=error, satellite=satellite, /second
;     if not error then yclean = yclean1
;     delvarx, yclean1
;endif

end
