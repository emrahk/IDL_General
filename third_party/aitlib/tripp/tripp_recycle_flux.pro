PRO TRIPP_RECYCLE_FLUX, fluxfile, $
                        trans_fluxs, trans_fluxsauto, trans_fluxb, $
                        trans_areas, trans_areasauto, trans_areab,$
                        trans_flag, trans_time, trans_files, trans_exptime,$
                        framenumbers, start
;+
; NAME:               
;                       TRIPP_RECYCLE_FLUX
;
;
; PURPOSE:
;                       partly fill predefined arrays with entries from
;                       an existing fluxfile that can have fewer entries
;                       than the arrays to be filled 
;
;
; CATEGORY:             
;                       subroutine for TRIPP, more specifically for
;                       TRIPP_EXTRACT_FLUX
;
;
; CALLING SEQUENCE:
;                       TRIPP_RECYCLE_FLUX, fluxfile, 
;                       trans_fluxs, trans_fluxsauto, trans_fluxb,
;                       trans_areas, trans_areasauto, trans_areab,
;                       trans_flag, trans_time, trans_files, trans_exptime,
;                       framenumbers, start
;
;
;
; INPUTS:             
;                       fluxfile, 
;                       trans_fluxs, trans_fluxsauto, trans_fluxb,
;                       trans_areas, trans_areasauto, trans_areab,
;                       trans_flag, trans_time, trans_files, trans_exptime
;                       framenumbers
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;                       start,
;                       trans_fluxs, trans_fluxsauto, trans_fluxb,
;                       trans_areas, trans_areasauto, trans_areab,
;                       trans_flag, trans_time, trans_files, trans_exptime
;
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;                       2001/05,  Author: Sonja L. Schuh
;                       2001/06,  also transfer auto 
;
;-
  
  restore,fluxfile
  
  old   = n_elements(files[*])
  trans = n_elements(trans_files[*])
  
  start = FIX(  MIN([old,trans]) )

    FOR i=0,start-1 DO BEGIN
      trans_files[i]     = files[i]
      FOR j=0,framenumbers-1 DO BEGIN
        trans_fluxs[*,i*framenumbers+j,*] = fluxs[*,i*framenumbers+j,*] 
        trans_fluxsauto[*,i*framenumbers+j]   = fluxsauto[*,i*framenumbers+j] 
        trans_fluxb[*,i*framenumbers+j]   = fluxb[*,i*framenumbers+j] 
        trans_areas[*,i*framenumbers+j,*] = areas[*,i*framenumbers+j,*]
        trans_areasauto[*,i*framenumbers+j]   = areasauto[*,i*framenumbers+j] 
        trans_areab[*,i*framenumbers+j]   = areab[*,i*framenumbers+j] 
        trans_flag [*,i*framenumbers+j]   = flag [*,i*framenumbers+j]
        trans_time   [i*framenumbers+j]   = time   [i*framenumbers+j]
        trans_exptime[i*framenumbers+j]   = exptime[i*framenumbers+j]
      ENDFOR
    ENDFOR

end









