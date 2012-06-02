PRO mkcalcgain,data,emin=emin,emax=emax,bg=bg,chatty=chatty
   IF (keyword_set(chatty)) THEN chatty=1 ELSE chatty=0
   IF (NOT keyword_set(emin)) THEN emin=0
   IF (NOT keyword_set(emax)) THEN emax=4095
   
   FOR ccd = 0,11 DO BEGIN 
       FOR j = 0, 63 DO BEGIN
           ptitle='Column No. '+STRTRIM(FIX(j),1)
           ;; set column ranges
           cdata=data(where((data.column EQ j))
           IF (n_elements(cdata) GT 0 THEN mkspectrum,cdata,spectrum=calcspek,ccdid=ccd $
               ELSE calcspek = 0
           dn = WHERE(calcspek GE emin AND calcspek LE emax, decn)
           IF decn GT 10 THEN BEGIN
               calcfail(j) = 0   
               calcspek = HISTOGRAM(calcspek, MIN = emin, MAX = emax, BINSIZE = bg)
               xx = INDGEN(N_ELEMENTS(calcspek))*bg+emin
               gauss = gaussfit(xx, calcspek, f)
               
               ;; calculate gain of column 'j'
               vgain(j) = f(1)
               igrl(j) = LONG(f(0)*f(2)*SQRT(2*!PI)/bg+.5)
               PLOT, xx, calcspek, TITLE = ptitle, XSTYLE = 4, YSTYLE = 4, $
                 CHARSIZE = 1.5, PSYM = 10
               OPLOT, xx, gauss, COLOR = 42, THICK = 2
           ENDIF ELSE BEGIN
               calcfail(j) = 1    
               PLOT, INDGEN(10), TITLE = ptitle, XSTYLE = 4, YSTYLE = 4, $
                 CHARSIZE = 1.5, /NODATA
               XYOUTS, 5.1, 5, 'not enough', CHARSIZE = 1.5, /DATA, COLOR = 150, $
                 CHARTHICK=2, ALIGNMENT = .5
               XYOUTS, 5.1, 0, 'data', CHARSIZE = 1.5, /DATA, COLOR = 150, $
                 CHARTHICK=2, ALIGNMENT = .5
           ENDELSE
       ENDFOR
   ENDFOR 
END
