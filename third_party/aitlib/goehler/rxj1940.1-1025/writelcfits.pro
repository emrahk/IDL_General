;; writelcfits - write out lightcurve fits data
;; save rxj1940 data in fits file. 
;; format: time in days (mjd-reftime),
;;         rate in counts, add bary center column, 
;;         use header taken from original fits file to copy as much
;;         info as possible.
;;         TSTART/END is taken from data set directly.
;;         
;; $Log: writelcfits.pro,v $
;; Revision 1.3  2003/04/03 07:57:43  goehler
;; update for header reading
;;
;; Revision 1.2  2003/03/31 17:10:44  goehler
;; beta version (without bary center corrected data!) taking header information.
;;
;; Revision 1.1  2003/03/31 09:21:41  goehler
;; added write lightcurve function
;;
PRO writelcfits,file,time,rate,error, reftime=reftime, header=header, barytime=barytime
    
    ;; look for header keywords, applicable to writelc:
    IF n_elements(header) NE 0 THEN BEGIN 
        entry=sxpar(header,'ORIGIN',count=count)
        IF count EQ 1 THEN origin=entry
        
        entry=sxpar(header,'TELESCOP',count=count)
        IF count EQ 1 THEN telescope=entry

        entry=sxpar(header,'INSTRUME',count=count)
        IF count EQ 1 THEN instrument=entry

        entry=sxpar(header,'FILTER', count=count)
        IF count EQ 1 THEN filter=entry
        
        entry=sxpar(header,'OBJECT',count=count)
        IF count EQ 1 THEN object=entry

        entry=sxpar(header,'EQUINOX',count=count)
        IF count EQ 1 THEN equinox=entry

        entry=sxpar(header,'RADECSYS',count=count)
        IF count EQ 1 THEN radecsys=entry

        entry=sxpar(header,'RA',count=count)
        IF count EQ 1 THEN pos_ra=entry

        entry=sxpar(header,'DEC',count=count)
        IF count EQ 1 THEN pos_dec=entry

    ENDIF 


    ;; uaaaahhhhhh -> writelc is too smart!!!!
    IF n_elements(error) NE 0 THEN BEGIN 
        filename = file
    ENDIF ELSE BEGIN ;; no error given -> error parameter becomes filename!!
        error=file
    ENDELSE 
        
    
    
    ;; actually write the lightcurve:
    writelc,time,rate,error,filename, $
      origin=origin,              $
      telescope=telescope,        $
      instrument=instrument,      $
      filter=filter,              $
      object=object,              $
      pos_ra=pos_ra,              $
      pos_dec=pos_dec,            $
      equinox=equinox,            $
      radecsys=radecsys,          $
      jdobs=(time[0] + reftime + 2400000.5D0), $ ;; convert to mjd -> jd
      jdend=(time[n_elements(time)-1] + reftime + 2400000.5D0),$ ;; convert mjd -> jd
      counts=0,                   $
      /day,                       $
      mjdrefi=reftime,            $
      mjdreff=0.D0,               $
      tstart0=time[0],            $
      tstopi=time[n_elements(time)-1],$
      tstopf=0.D0,              $
      /sysmjd,                    $
      ontime=ontime,              $
      /backsub,                   $
      deadcorr=0,                 $
      timezero=0.D0,              $
      barytime=barytime

END

