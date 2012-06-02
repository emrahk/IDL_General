PRO mkplotintens,data,ccd,zoom=zoom,nowin=nowin
   
   IF (NOT keyword_set(zoom)) THEN zoom=1.
   IF (NOT keyword_set(nowin)) THEN loadct,13   

   
   numdata=n_elements(data)   
;   data=data(2:numdata-1)
   
   intensimg=mkdata2img(data)
   
   data=reform(intensimg(ccd,*,*))
   xsize=n_elements(data(*,0))
   ysize=n_elements(data(0,*))
   
   xwin=xsize*zoom
   ywin=ysize*zoom
   IF (NOT keyword_set(nowin)) THEN window,0,xsize=xwin+2,ysize=ywin+2

   data=rebin(data,xwin,ywin,/SAMPLE)
   tvscl,data
END
