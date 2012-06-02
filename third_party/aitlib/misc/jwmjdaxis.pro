PRO jwmjdaxis,upper=upper,nolabel=nolabel,mjd=mjd,zeropoint=zeropoint, $
              stretch=stretch,labeloffset=laboff,charsize=charsize, $
              skip=sskip,fontscale=fontscale, _EXTRA=extra
;
;              skip: number of labels to omit between plotted labels
;
;              Version 1.2: 2000/07/12, JW: added _extra keyword
;              Version 1.3: 2000/09/29, JW: added skip keyword
   
   IF (n_elements(stretch) EQ 0) THEN stretch=1.
   IF (n_elements(laboff) EQ 0) THEN laboff=0.
   IF (n_elements(sskip) EQ 0) THEN sskip=0
   skip=sskip
   IF (skip LT 0) THEN skip=0
   
   skip=skip+1 ;; and now the modulo trick works
   
   IF (laboff-long(laboff) NE 0) THEN BEGIN 
       print,'WARNING: LABELOFFSETS with non-zero day-fractions'
       print,'   result in WRONG labels'
   END 

   ;; Lengths for the labels
   ;; SHOULD AGREE WITH THOSE OF jwdateaxis!
   speclen=[0.01,0.02]*stretch
   IF (keyword_set(upper)) THEN speclen=-speclen
   
   IF (n_elements(charsize) EQ 0) THEN BEGIN 
       charsize=1.
       IF (!p.charsize NE 0.) THEN charsize=!p.charsize
   ENDIF 

   IF (n_elements(fontscale) NE 2) THEN BEGIN 
       fontsc=[1.,1.4]
   ENDIF ELSE BEGIN 
       fontsc=fontscale
   ENDELSE 
       
   clip=!p.clip
   ranges=convert_coord([clip(0),clip(2)],[clip(1),clip(3)],/device,/to_data)
   rannor=convert_coord([clip(0),clip(2)],[clip(1),clip(3)],/device,/to_normal)

   jd0=0.D0
   IF (keyword_set(mjd)) THEN jd0=2400000.5D0
   IF (n_elements(zeropoint) NE 0) THEN jd0=jd0+zeropoint

   jdmin=ranges(0,0)+jd0
   jdmax=ranges(0,1)+jd0
   dt=ranges(0,1)-ranges(0,0)
   ymin=ranges(1,0)
   ymax=ranges(1,1)

   ;;
   ;; Label for x-axis
   ;;
   xlabel='JD'
   IF (laboff NE 0) THEN xlabel='JD-'+strtrim(string(laboff),2)

   ;;
   ;; Draw lines for axis, determine text-positions
   ;;
   IF (keyword_set(upper)) THEN BEGIN 
       plots,[clip(0),clip(2)],[clip(3),clip(3)],/device,_extra=extra
       ypos=ymax
       po=convert_coord(0.-jd0,ypos,/data,/to_normal)
       IF (!D.name EQ 'PS') THEN BEGIN 
           po1=po(1)+0.015*stretch
           po2=po(1)+0.07*stretch
       END ELSE BEGIN 
           po1=po(1)+0.01*stretch
           po2=po(1)+0.045*stretch
       END
   END ELSE BEGIN 
       plots,[clip(0),clip(2)],[clip(1),clip(1)],/device,_extra=extra
       ypos=ymin
       po=convert_coord(0.-jd0,ypos,/data,/to_normal)
       IF (!d.name EQ 'PS') THEN BEGIN 
           po1=po(1)-0.05*stretch
           po2=po(1)-0.10*stretch
       END ELSE BEGIN 
           po1=po(1)-0.03*stretch
           po2=po(1)-0.06*stretch
       END 
   END

   ;;
   ;; Determine step-size
   ;;
   logstep=long(alog10(dt))
   step=10.^double(logstep)

   FOR i=1,3 DO BEGIN 
       IF (step GT dt/3.) THEN BEGIN 
           logstep=logstep-1
           step=step/10.
       ENDIF 
   END 
   num=fix(dt/step)+1
   
   IF (dt LE 1) THEN BEGIN 
       jdstart=long(jdmin)-1
       jdend=long(jdmax)+1
       num=fix((jdend-jdstart)/step)+1
   END ELSE BEGIN 
       jdstart=long(jdmin/step-1)*step
       jdend=long(jdmax/step+1)*step
       num=fix((jdend-jdstart)/step)+1
   END
   
   format='(I10)'
   IF (logstep LT 0.) THEN BEGIN 
       format='(F'+strtrim(string(format='(I5)',10+abs(logstep)),2)+'.'+ $
         strtrim(string(format='(I5)',abs(logstep)),2)+')'
   ENDIF 

   ;;
   ;; Plot the dashes
   ;;
   FOR i=0,num DO BEGIN 
       jd=jdstart+i*step
       IF (jd GE jdmin AND jd LE jdmax) THEN BEGIN 
           pos=convert_coord(jd-jd0,ypos,/data,/to_normal)

           plots,[pos(0,0),pos(0,0)],[pos(1,0),pos(1,0)+speclen(1)],/normal,_extra=extra
           IF (NOT keyword_set(nolabel)) THEN BEGIN 
               IF ((i MOD skip) EQ 0) THEN BEGIN 
                   xyouts,pos(0,0),po1,$
                     strtrim(string(format=format,jd-laboff),2),$
                     alignment=0.5,/normal,size=fontsc[0]*charsize,_extra=extra
               END 
           END 
       ENDIF 
       FOR j=1,4 DO BEGIN 
           jjd=jd+j*step/5.
           IF (jjd GE jdmin AND jjd LE jdmax) THEN BEGIN 
               pos=convert_coord(jjd-jd0,ypos,/data,/to_normal)
               plots,[pos(0,0),pos(0,0)],[pos(1,0),pos(1,0)+speclen(0)],/normal,_extra=extra
           ENDIF 
       ENDFOR 
   END 

   ;;
   ;; label at x-axis
   ;;
   IF (NOT keyword_set(nolabel)) THEN BEGIN
       xyouts,(rannor(0,0)+rannor(0,1))/2.,po2,xlabel,/normal,$
         size=fontsc[1]*charsize,alignment=0.5,_extra=extra
   ENDIF 
   
END 
