PRO mkfitgain,data,gain,emin=emin,emax=emax,ccdid=ccdid,bg=bg,$
              intagral=integral,calcfail=calcfail,chatty=chatty,cte=cte
   IF (keyword_set(chatty)) THEN chatty=1 ELSE chatty=0
   IF (NOT keyword_set(emin)) THEN emin=0
   IF (NOT keyword_set(emax)) THEN emax=4095
   IF (keyword_set(cte)) THEN ctecor=1 ELSE ctecor=0
   
   vgain=fltarr(64)
   calcfail=bytearr(64)
   intagral=longarr(64)
   
   FOR col = 0, 63 DO BEGIN
       ptitle='Column No. '+STRTRIM(FIX(col),1)
       
       ;; extract column 'j'
       cdata=data(where((cdata.column EQ col))
       IF (n_elements(cdata) LE 10) THEN BEGIN
           print,'% mkfitgain: WARNING No Data available for Column: '+$
             STRING(FORMAT='(F2.0)',col)
           calcfail(j) = 1    
           PLOT, INDGEN(10), TITLE = ptitle, XSTYLE = 4, YSTYLE = 4, $
             CHARSIZE = 1.5, /NODATA
           XYOUTS, 5.1, 5, 'not enough', CHARSIZE = 1.5, /DATA, COLOR = 150, $
             CHARTHICK=2, ALIGNMENT = .5
           XYOUTS, 5.1, 0, 'data', CHARSIZE = 1.5, /DATA, COLOR = 150, $
             CHARTHICK=2, ALIGNMENT = .5
       ENDIF ELSE BEGIN 
           IF (ctecor) THEN BEGIN 
               mkspectrum,cdata,minimum=emin,maximum=emax,spectrum=calcspek,$
                 xxx=xx,ccdid=ccd,bg=bg,/cte
           ENDIF ELSE BEGIN 
               mkspectrum,cdata,minimum=emin,maximum=emax,spectrum=calcspek,$
                 xxx=xx,ccdid=ccd,bg=bg
           ENDELSE
           
           calcfail(col) = 0   
;               calcspek = HISTOGRAM(calcspek, MIN = emin, MAX = emax, BINSIZE = bg)
;           xx = INDGEN(N_ELEMENTS(calcspek))*bg+emin
           gauss = gaussfit(xx, calcspek, f)
           ;; calculate gain of column 'j'
           vgain(j) = f(1)
           integral(j) = LONG(f(0)*f(2)*SQRT(2*!PI)/bg+.5)
           PLOT, xx, calcspek, TITLE = ptitle, XSTYLE = 4, YSTYLE = 4, $
             CHARSIZE = 1.5, PSYM = 10
           OPLOT, xx, gauss, COLOR = 42, THICK = 2
       ENDELSE     
   ENDFOR 
   ;; check for failed fits
   cfs = WHERE(calcfail EQ 1, cfn)
   IF cfn GT 0 THEN BEGIN 
       ;; Set the gain value of failed fits to NaN
       vgain(cfs) = !vales.f_nan
       igrl(cfs) = !vales.f_nan
   ENDIF 
   
;   gainede = vgain
   vgainmean = TOTAL(vgain)/(64.d0-cfn)
   
   ;; if fit fails, set gainvalue equal to the mean gainvalue
   IF cfn GT 0 THEN vgain(cfs) = vgm
   ;; relative gain 
   vgain = vgainmean/vgain
   gain=vgain
END
