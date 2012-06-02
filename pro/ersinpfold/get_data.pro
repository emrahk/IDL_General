; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;+
; NAME:
;
;	GET_DATA.PRO
;
; PURPOSE:
;
;	
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;	
;
; INPUTS:
;
;       
;
; KEYWORD PARAMETERS:
;
;
;       
; OUTPUTS:
;
;       
;
; COMMON BLOCKS:
;	NONE
;
; SIDE EFFECTS:
;      
;
; RESTRICTIONS:
;	
;
; DEPENDENCIES:
;       
;
; PROCEDURE:
;        
;
; EXAMPLES:
;       
;
;
; MODIFICATION HISTORY:
;
;	Written, Peter.Woods@msfc.nasa.gov
;		(205) 544-1803
;-
;*******************************************************************************


PRO  GET_DATA, files, xx, yy, ee, head1, label = label, time = time, tt = tt, $
	mid_times = mid_times, pcanorm=pcanorm


if not keyword_set(pcanorm) then pcanorm=0

num_files = N_ELEMENTS(files)

request_tt = N_ELEMENTS(time) NE 0

have_label = N_ELEMENTS(label) NE 0
IF have_label THEN BEGIN
   label = label
ENDIF ELSE BEGIN
   label = 'BARYTIME'
ENDELSE

want_mid_times = N_ELEMENTS(mid_times) NE 0




FOR i = 0, (num_files - 1) DO BEGIN

   have_file = FINDFILE( files[i] )
   IF (have_file[0] EQ '') THEN BEGIN
	PRINT, ' '
   	PRINT, ' * * * * GET_DATA.PRO * * * * '
	PRINT, ' '
	PRINT, ' Filename : ' + files[i] + ' not found'
	PRINT, ' '
	GOTO, skip_file
   ENDIF
   
   READ_CURVE, files[i], data, head, info
   
   tags = TAG_NAMES(data)
   lab_ind = WHERE(tags EQ label, find)
   
   IF (find NE 1) THEN BEGIN
	PRINT, ' '
   	PRINT, ' * * * * GET_DATA.PRO * * * * '
	PRINT, ' '
	PRINT, ' No tag label "' + label + '" found for the file ' 
	PRINT, ' 	' + files[i] 
	PRINT, ' '
	GOTO, skip_file
   ENDIF 
   
   IF request_tt THEN tt_ind = WHERE(tags EQ 'TIME')
   
   IF (i EQ 0) THEN BEGIN
   	head1 = head
	IF request_tt THEN BEGIN
	   IF want_mid_times THEN BEGIN
	   	tt = data.(tt_ind[0]) + (info.time_res/2.0)
	   ENDIF ELSE BEGIN
	   	tt = [TRANSPOSE(data.(tt_ind[0])), $
			TRANSPOSE(data.(tt_ind[0]) + info.time_res)]
	   ENDELSE
	ENDIF
	IF want_mid_times THEN BEGIN
	   xx = data.(lab_ind[0]) + (info.time_res/2.0)
	ENDIF ELSE BEGIN
	   xx = [TRANSPOSE(data.(lab_ind[0])), TRANSPOSE(data.(lab_ind[0]) + $
		info.time_res)]
	ENDELSE
	yy = data.rate
	ee = data.error

;PCA NORMALIZATION
;
        IF pcanorm THEN BEGIN
          mstring=files[i]
          op = strpos(mstring,'off')     
          IF op eq -1 THEN BEGIN
            yy = data.rate/5.
            ee = data.error/5.
          ENDIF ELSE BEGIN
            up =strpos(mstring,'_')
            WHILE op-up gt 5 DO up = strpos(mstring,'_',up+1)
            npcu = 5.-float(op-up-1.)
            yy = data.rate/npcu
            ee = data.error/npcu
        ENDELSE
    ENDIF
;
   ENDIF ELSE BEGIN
	IF request_tt THEN BEGIN
	   IF want_mid_times THEN BEGIN
	   	tt = [tt, data.(tt_ind[0]) + (info.time_res/2.0)]
	   ENDIF ELSE BEGIN
	   	tt = TRANSPOSE( [TRANSPOSE(tt), $
			TRANSPOSE( [TRANSPOSE(data.(tt_ind[0])), $
			TRANSPOSE(data.(tt_ind[0]) + info.time_res)] )] )
	   ENDELSE
	ENDIF
	IF want_mid_times THEN BEGIN
	   xx = [xx, data.(lab_ind[0]) + (info.time_res/2.0)]
	ENDIF ELSE BEGIN
   	   xx = TRANSPOSE( [TRANSPOSE(xx), $
	   	TRANSPOSE( [TRANSPOSE(data.(lab_ind[0])), $
		TRANSPOSE(data.(lab_ind[0]) + info.time_res)] )] )
	ENDELSE
;PCA NORMALIZATION
;
        IF pcanorm THEN BEGIN
          mstring=files[i]
          op = strpos(mstring,'off')     
          IF op eq -1 THEN BEGIN
            data.rate = data.rate/5.
            data.error = data.error/5.
          ENDIF ELSE BEGIN
            up =strpos(mstring,'_')
            WHILE op-up gt 5 DO up = strpos(mstring,'_',up+1)
            npcu = 5.-float(op-up-1.)
            data.rate = data.rate/npcu
            data.error = data.error/npcu
        ENDELSE
    ENDIF
;
	yy = [yy, data.rate]
	ee = [ee, data.error]
   ENDELSE
   
   
   skip_file:
   
   
   
ENDFOR


IF want_mid_times THEN BEGIN
   sort_ind = SORT(xx)
   xx = xx[sort_ind]
   IF request_tt THEN tt = tt[sort_ind]
ENDIF ELSE BEGIN
   sort_ind = SORT(xx[0,*])
   xx = xx[*,sort_ind]
   IF request_tt THEN tt = tt[*,sort_ind]
ENDELSE

yy = yy[sort_ind]
ee = ee[sort_ind]


END
