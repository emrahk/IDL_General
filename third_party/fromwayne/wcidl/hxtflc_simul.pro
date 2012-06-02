PRO foo, fudge, nbins=nbins, w=w, gti=gti
   
   pmulti=!p.multi & !p.multi=[0,1,5]
   
   IF (keyword_set(nbins) EQ 0) THEN BEGIN
       nbins=64.d
   ENDIF
   
   time=dindgen(2d5)*!DPI/1d3
   cnts=1.0*sin(time) + $
     1.15*sin(time+1.37*!DPI)^2.d + $
     1.69*sin(time+0.69*!DPI)^3.d + $
     4.d
   
   cntmean=mean(cnts)
   period=2.d*!DPI
   gti=time
   err=cnts
   gti(*)=0
   
   FOR i=0,99 DO BEGIN
       q=where(time GE i*period AND time LT (i+1)*period)
       err(q)=cnts(q) + 0.5*randomn(seed)*cntmean
   endfor

   q=where(err le 0, flag)
   IF (flag NE 0) THEN begin
       err(q)=0.1
   ENDIF
   
   for i=long(0),long(2d5-1) DO BEGIN
       err(i)=randomn(seed,poisson=err(i))
   endfor
   
   plot,time/period,err,xrange=[0,3], $
     yrange=[0,16],title='Input Light Curve'

   x=period/(2.d*fudge)
   for i=0,2*max(time)*fudge/period+1,2 do begin 
       w=where(time ge x*i and time lt x*(i+1),flag)
       IF (flag NE 0) THEN BEGIN
           gti(w)=1.
       endif
   ENDFOR   
   w=where(gti eq 1)
   
   plot,time(w)/period,err(w),xrange=[0,3], $
     title='LC after filtering through gti file'
   
   fold_time_arr,time(w),err(w),period,flc,np=nbins
   plot,[flc,flc], title='Folded Counts'
   
   fold_time_arr,time(w),gti(w),period,bkg,np=nbins
   plot,[bkg,bkg], title='Folded Exposure'
   
   x=(flc/bkg)/mean(flc/bkg)
   plot,[x,x],title='FLC',yrange=[0.6,1.4]
   
   fold_time_arr,time,cnts,period,flc,np=nbins
   x=(flc/bkg)/mean(flc/bkg)
   oplot,[x,x],line=1,thick=3,psym=0
   
  
   
   !p.multi=pmulti
   
   return
END

   
