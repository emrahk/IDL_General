PRO mkplotenergy,data,ccd,scale=scale,noscale=noscale,zoom=zoom,nowin=nowin
   IF (NOT keyword_set(zoom)) THEN zoom=1.
   IF (NOT keyword_set(nowin)) THEN loadct,13   

   
   numdata=n_elements(data)   
;   data=data(2:numdata-1)
   
   IF keyword_set(scale) THEN data.energy=fix(data.energy/1.1)+300
   
   energyimg=mkdata2en(data)

   data=reform(energyimg(ccd,*,*))
   xsize=n_elements(data(*,0))
   ysize=n_elements(data(0,*))
   
   xwin=xsize*zoom
   ywin=ysize*zoom
   IF (NOT keyword_set(nowin)) THEN window,1,xsize=xwin+2,ysize=ywin+2

   data=rebin(data,xwin,ywin,/SAMPLE)
   
   IF keyword_set(noscale) THEN BEGIN
       tv,data
   ENDIF ELSE tvscl,data
   
END
