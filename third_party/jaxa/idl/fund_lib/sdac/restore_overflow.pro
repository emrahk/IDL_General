
;+
; PROJECT:
;	SDAC
; NAME:   
;	RESTORE_OVERFLOW
;
; PURPOSE:
;	This procedure controls the correction of counter overflow in BATSE and HXT  data.
;
; CATEGORY: 
;	BATSE, HXT,  TELEMETRY, UTILITY, INSTRUMENT
;
;
; CALLING SEQUENCE:
;	RESTORE_OVERFLOW, Data, Det_sorted
;
; CALLED BY:
;	fdbread, fs_acc, fs_acc_cont, fs_acc_discsp
;	read_4_spex
; CALLS TO:
;	jumper, jumper2
;
; INPUTS:
;       Data      - array of counts (nchan x det_id x time_bins), 
;		    fltarr or lonarr, signed but otherwise uncorrected
;	Det_sorted- aspect ordered detector ids, of 0-7, from most to least sunward 
;
; OUTPUTS:
;       data arrays corrected for two byte overflow
;
; KEYWORDS:
; 	MAXINDEX - values after this index in BATSE arrays are zero,
;		   used with common block arrays in fs_saveaccum.pro
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
; COMMONS:
;	RESTORE_OVERFLOW
; Procedure:
;	Data is accumulated in two-byte registers and thus suffers frequent
;	counter-overflow.  This routine is used to correct the counts returned by
;	telemetry for this overflow.
; 
;  Given data(or any) rates with possible overflow, use jumper to reconstruct rates.
;  This code assumes that data have not been modified by livet. 
;  HISTORY:
;	Originally RESET and BATSE_OVERFLOW.
;  Modification history:  AES 6/30/94  Channels are now identified starting
;                         from 0.  I.e., old channel 4 is now channel 3.  
;                         This affects only the channel ID the user sees,
;                         not the code.
;  
;	Version 2	  ras, 15-dec-1995, added nonzero test inside to avoid
;			  creating doubling the size of the data area needed
;			  in the main routines
;	Version 3	  ras, 30-jan-1996, added hxt cal data, 10 channels, 64 detectors
;	Version 4, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;-

pro restore_overflow, data, det_sorted, maxindex=maxindex

on_error,2
;spex_over_test - if this is set, then an alternative technique is used to
;		  discover overflow conditions and correct them.  Not the
;		  standard technique in the BATSE directory
common restore_overflow, spex_over_test

;SETUP NEW ARRAY
;
;LOOP THROUGH FIRST 4 CHANNELS IN EACH DETECTOR, INCLUDING TOTAL NaI rate
;
;START AT THE LEAST SUNWARD DETECTOR, HIGHEST ENERGY CHANNEL
;CORRECT IT FOR OVERFLOW AND SO IN SUCCESSION TILL DONE
;
ndet = n_elements(data(0,*,0))
checkvar, det_sorted, indgen(ndet)

det_id = det_sorted(0)
nchan = n_elements( data(*,0,0) )
komni = 0
checkvar, maxindex, n_elements(data(0,0,*))-1
;
; Look for HXT cal data first
;
case ndet of 
    
    64: begin   ; HXT CAL
        ichan = 10
        i_init= 9
        data = data * 256L	
        end
    else: begin
        
        case nchan of
            6: begin    ; DISCLA data
                ; If any part of interval is in omni mode, can't use channel 3.
                ; CHANGE:  channel 3 has been redefined from channel 4
                qomni = where ((data(0,0,*) ne 0) and (data(3,0,*) eq 0), komni)
                if komni then i_init = 2 else i_init = 3
                ichan = 5
                end
            16: begin   ; CONT data
                ichan = 15
                i_init = 14
                end
            4:  begin   ; DISCSP data
                ichan = 3
                i_init = 2
                end 
            endcase
        end
    endcase

FOR I = I_init,0,-1 DO BEGIN 		;START AT THE HIGHEST ENERGY
    ;
    if i eq 0 and nchan eq 4 then $	;correct channel 0 of discsp by subtracting higher cleaned rates
    data(0,*,*) = data(0,*,*) - data(1,*,*)
    ;LOOP THROUGH EACH DETECTOR
    ;
    FOR J=ndet-1,0,-1 DO BEGIN			;START AT THE LEAST SUNWARD
        ;
        ;Identify the current detector and channel and the last one corrected
        ;
        
        last_id   =  det_id  			;last detector corrected
        last_chan =  ichan			;last channel corrected
        det_id = det_sorted(j)			;current detector
        ichan = i				;current channel
        ;
        wnz   = where( total( abs(data(*,det_id,0:maxindex)),1) ne 0.0 $
        and total( abs(data(*,last_id,0:maxindex)),1) ne 0.0, nzero)
        if nzero gt 0 then begin
            
            jumper, reform(data(ichan,det_id,wnz)), clean, summed=summed
            ;
            ;TEST TO SEE WHETHER FIRST OVERFLOW CORRECTION WAS SUFFICIENT
            ;
            wless = where( clean lt 0, nless)
            if total(summed) ne 0 or nless ge 1 then begin 
                ;
                ; Change below:  channel 2 is now the next to the last
                ; channel.
                ;
                ; if we're in omni mode, and on channel 2, and least sunward
                ; detector and first overflow correction was not sufficient,
                ; can't do any more.  Write message and get out.
                if komni and (i eq I_init) and (J eq 7) then begin
                    printx, ' '
                    printx,'Error - unable to correct overflow.'
                    printx,'  Omni antenna was used during part of the ' + $
                    'overflow interval, resulting'
                    printx,'  in incomplete data in high energy channels.'
                    printx, ' '
                    goto, getout
                    endif
                ;COMPARE NEW RATE WITH LAST CLEANED RATE AND LOOK FOR JUMPS
                ;
                jumper, reform(clean-data(last_chan,last_id,wnz)), clean, summed=summed
                clean  = reform(data(last_chan,last_id,wnz)) + clean
                
                wless = where( clean lt 0, nless)
                if total(summed) ne 0 or nless ge 1 and nchan ne 6 and j ne (ndet-1) and $
                fcheck(spex_over_test) then begin 
                    ;retry using closest rate of cleaned rates instead of last cleaned!
                    ;try this comparison only for non-discla data!
                    big_test = 3e4
                    start:
                    ;find the most comparable rate when flux is getting ng intense
                    wbig = where( clean gt big_test, nbig)
                    if nbig ge 1 then wbig=wbig(0) else begin
                        big_test =big_test - 1000.
                        if big_test lt 1000. then goto, giveup
                        goto, start
                        endelse
                    candidate_ids = det_sorted(j+1:ndet-1)
                    test = min( abs( clean(wbig)-data(last_chan,candidate_ids,wbig)), min_script)	
                    ;Min_script is the index of the corrected rate closest to the current
                    is_clean = reform(data(last_chan, candidate_ids(min_script), wnz))
                    ;scale the IS_CLEAN rate as closely as possible to the rate to clean
                    is_clean = clean(wbig)/is_clean(wbig) * is_clean
                    jumper, clean-is_clean, clean, summed=summed
                    clean = clean +is_clean		  
                    endif
                
                giveup:
                if total(summed) ne 0 then begin
                    if nchan eq 4 then begin
                        printx, 'WARNING - Possible problem with overflow ' +$
                        'correction.'
                        endif else begin
                        jumper2, reform(clean-data(last_chan,last_id,wnz)), $
                        clean, summed=summed
                        clean  = reform(data(last_chan,last_id,wnz)) + clean
                        endelse
                    endif
                ;stop
                endif	
            data(ichan,det_id,wnz) = clean(*)
            endif;
        ENDFOR
    ENDFOR
if nchan eq 4 then $	;add the higher channel data to channel 0, expected by calling routine
data(0,*,*) = data(0,*,*) + data(1,*,*)


getout:
if ndet eq 64 then data=data/256L

END
