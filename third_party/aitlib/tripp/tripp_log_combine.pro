FUNCTION TRIPP_LOG_COMBINE, log1, log2

;+
; NAME:
;           TRIPP_LOG_COMBINE
;
;
; PURPOSE:
;           Combine the result of both TRIPP_LOG_GUI (TRIPP_LOG_GUI/TRIPP_LOG_GUI2)
;           in one structure (type: TRIPP_LOG_TYPE). 
;           Additionally calculate the number of images, offset etc.
;
;
; INPUTS:
;           log1, log2: structures containing the result of TRIPP_LOG_GUI/TRIPP_LOG_GUI2
;
;
; RESTRICTIONS:
;           structure: TAG NAMES in log1 and log2 must correspond to those
;                      defined in tripp_log_type.
;
; OUTPUT:
;           result: Structure - combination of both substructures (log1,log2)
;
;
; MODIFICATION HISTORY:
;   
;           Version 1.0, 1999/05/07, Jochen Deetjen 
;           Version 1.1, 2001/01   , SLS, modify the selection radius in
;                                    case it doesn't match the
;                                    available radii
;                        2001/02   , SLS, comparison needs to be for
;                                    floats, not double            
;                        2001/02   , SLS, adapt to smaller gui 
;                        2001/05   , SLS, new nr_pos for BUSCA 
;                                    SLS, selection radius is the larger
;                                    one, not the TWO nearest  when the
;                                    initial choice is exactly in the middle
;                                   
;-
   
  on_error,2                    ;Return to caller if an error occurs
  
  ;; ---------------------------------------------------------
  ;; --- DEFINITION OF RESULT TYPE ---
  ;;
   result = tripp_log_type()
   
   
   ;; ---------------------------------------------------------
   ;; --- CUTTING OF THE LAST WIDGET TAG (the OK tag) ---
   ;;

   ;; --- first gui - several definitions have been truncated
   FOR I = 0, 10                DO BEGIN
       result.(I) = log1.(I)
   ENDFOR
   FOR I = 11, N_TAGS(log1) - 2 DO BEGIN
     result.(I+10) = log1.(I)
   ENDFOR
   
   ;; --- second gui
   FOR I = 0, N_TAGS(log2) - 2 DO BEGIN
       result.relflx_ref(I) = log2.(I)
   ENDFOR
   
   
   ;; ---------------------------------------------------------
   ;; --- EXTRACT FIRST AND LAST IMAGE NUMBER ---
   ;;
   fpos           = STRPOS( result.first, '.fits' )
   result.nr_pos  = fpos - 4
   IF result.instrument EQ "BUSCA" THEN result.nr_pos = fpos - 5

   fnumber        = STRMID( result.first, result.nr_pos, 4)
   result.offset  = fnumber - 1

   lnumber        = STRMID( result.last, result.nr_pos, 4)
   result.nr      = lnumber - result.offset
   IF result.nr LT 1 THEN BEGIN
     print,"                     "
     print,"% TRIPP_LOG_COMBINE: Warning: The total number of images is less than 1," 
     print,"                     maybe the filenames have a structure that TRIPP can't handle."
     print,"                     Please think up something or TRIPP_REDUCTION will fail to work."
    ENDIF

   ;; ---------------------------------------------------------
   ;; --- CREATE FILENAME EXTENSIONS AUTOMATICALLY ---
   ;;

   ;; --- always create them now according to block.pos!

     result.pos    = result.block + '.pos'
     result.mask   = result.block + '.aps'
     result.flux   = result.block + '.flx'
     result.relflx = result.block + '.rms'
     result.stat   = result.block + '.stt'
     result.ft     = result.block + '_ft.ps'
     result.lc     = result.block + '_lc.ps'
     result.data   = result.block + '.dat'
   
   ;; ---------------------------------------------------------
   ;; --- CALCULATE NEAREST SELECTION RADIUS
   ;;
   
   rad    = DOUBLE( result.extr_minr ) + $
     DINDGEN( result.extr_nrr ) / DOUBLE( result.extr_nrr ) * $
     (DOUBLE( result.extr_maxr ) - DOUBLE( result.extr_minr ))
   
   ind=where(abs(rad-result.relflx_sr) EQ min(abs(rad-result.relflx_sr)))
   
   result.relflx_sr=DOUBLE(result.relflx_sr)
   sel_rad=result.relflx_sr
   compare=min(abs(float(rad)-float(result.relflx_sr)))
   IF compare NE 0. THEN BEGIN
     result.relflx_sr=rad(ind[n_elements(ind)-1])
     PRINT,'% TRIPP_WRITE_IMAGE_LOG: WARNING: Selection radius has been changed to ',result.relflx_sr
   ENDIF
   
   RETURN, result
   
;; ---------------------------------------------------------
;;
END

;; ----------------------------------------


