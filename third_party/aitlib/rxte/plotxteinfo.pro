PRO plotxteinfo,position=position,tmin=tmin,tmax=tmax,obs=obs,dirs=dirs, $
                slew=slew,occult=occult,saa=saa,good=good,pcu0=pcu0, $
                pcu1=pcu1,pcu2=pcu2,pcu3=pcu3,pcu4=pcu4,time0=time0, $
                noxaxis=noxaxis,gti=gti,stretch=stretch
   ;;
   ;; Make overview-plot of events
   ;;
   IF (n_elements(time0) EQ 0) THEN time0=0.
   IF (n_elements(stretch) EQ 0) THEN stretch=1.
   IF (n_elements(position) EQ 0) THEN position=[0.05,0.05,0.95,0.95]

   nblock=0.75
   IF (n_elements(obs) NE 0) THEN nblock=nblock+1.5
   IF (n_elements(slew) NE 0) THEN nblock=nblock+1.
   IF (n_elements(occult) NE 0) THEN nblock=nblock+1.
   IF (n_elements(saa) NE 0) THEN nblock=nblock+1.
   IF (n_elements(good) NE 0) THEN nblock=nblock+1.
   IF (n_elements(gti) NE 0) THEN nblock=nblock+1.
   IF (n_elements(pcu0) NE 0) THEN nblock=nblock+1.
   IF (n_elements(pcu1) NE 0) THEN nblock=nblock+1.
   IF (n_elements(pcu2) NE 0) THEN nblock=nblock+1.
   IF (n_elements(pcu3) NE 0) THEN nblock=nblock+1.
   IF (n_elements(pcu4) NE 0) THEN nblock=nblock+1.


   plot,[tmin,tmax],[0.,-nblock],/nodata, $
     position=position,/noerase,ystyle=5, $
     xstyle=5
   IF (NOT keyword_set(noxaxis)) THEN BEGIN 
       jwdateaxis,zeropoint=time0,/mjd,stretch=stretch
       jwdateaxis,zeropoint=time0,/mjd,/upper,/nolabel,stretch=stretch
   ENDIF 
   loc=-1.

   plots,[0.10,0.10],[0.1,0.5],/normal
   plots,[0.95,0.95],[0.1,0.5],/normal

   IF (n_elements(obs) NE 0) THEN BEGIN 
       IF (n_elements(obs) GT 2) THEN BEGIN 
           plotinter,obs-time0,loc,dloc=-0.5,what=dirs
           pos=convert_coord(0.,loc-0.25,/data,/to_normal)
           xyouts,0.09,pos(1,0),'Obsid',/normal,alignment=1.
           loc=loc-1.5
       END ELSE BEGIN 
           plotinter,obs-time0,loc,what=dirs
           pos=convert_coord(0.,loc-0.2,/data,/to_normal)
           xyouts,0.09,pos(1,0),'Obsid',/normal,alignment=1.
           loc=loc-1.
       END 
   ENDIF 

   IF (n_elements(slew) NE 0) THEN BEGIN 
       plotinter,slew-time0,loc,/ignore0
       pos=convert_coord(0.,loc-0.2,/data,/to_normal)
       xyouts,0.09,pos(1,0),'Slew',/normal,alignment=1.
       loc=loc-1.
   ENDIF 

   IF (n_elements(occult) NE 0) THEN BEGIN 
       plotinter,occult-time0,loc,/ignore0
       pos=convert_coord(0.,loc-0.2,/data,/to_normal)
       xyouts,0.09,pos(1,0),'Occult',/normal,alignment=1.
       loc=loc-1.
   ENDIF 

   IF (n_elements(saa) NE 0) THEN BEGIN 
       plotinter,saa-time0,loc,/ignore0
       pos=convert_coord(0.,loc-0.2,/data,/to_normal)
       xyouts,0.09,pos(1,0),'SAA',/normal,alignment=1.
       loc=loc-1.
   ENDIF 

   IF (n_elements(good) NE 0) THEN BEGIN 
       plotinter,good-time0,loc,/ignore0
       pos=convert_coord(0.,loc-0.2,/data,/to_normal)
       xyouts,0.09,pos(1,0),'Good',/normal,alignment=1.
       loc=loc-1.
   ENDIF 
   
   IF (n_elements(gti) NE 0) THEN BEGIN 
       plotinter,gti-time0,loc,/ignore0
       pos=convert_coord(0.,loc-0.2,/data,/to_normal)
       xyouts,0.09,pos(1,0),'GTI',/normal,alignment=1.
       loc=loc-1.
   ENDIF 

   IF (n_elements(pcu0) NE 0) THEN BEGIN 
       plotinter,pcu0-time0,loc,/ignore0
       pos=convert_coord(0.,loc-0.2,/data,/to_normal)
       xyouts,0.09,pos(1,0),'PCU0',/normal,alignment=1.
       loc=loc-1.
   ENDIF 
   
   IF (n_elements(pcu1) NE 0) THEN BEGIN 
       plotinter,pcu1-time0,loc,/ignore0
       pos=convert_coord(0.,loc-0.2,/data,/to_normal)
       xyouts,0.09,pos(1,0),'PCU1',/normal,alignment=1.
       loc=loc-1.
   ENDIF 
   
   IF (n_elements(pcu2) NE 0) THEN BEGIN 
       plotinter,pcu2-time0,loc,/ignore0
       pos=convert_coord(0.,loc-0.2,/data,/to_normal)
       xyouts,0.09,pos(1,0),'PCU2',/normal,alignment=1.
       loc=loc-1.
   ENDIF 

   IF (n_elements(pcu3) NE 0) THEN BEGIN 
       plotinter,pcu3-time0,loc,/ignore0
       pos=convert_coord(0.,loc-0.2,/data,/to_normal)
       xyouts,0.09,pos(1,0),'PCU3',/normal,alignment=1.
       loc=loc-1.
   ENDIF 

   IF (n_elements(pcu4) NE 0) THEN BEGIN 
       plotinter,pcu4-time0,loc,/ignore0
       pos=convert_coord(0.,loc-0.2,/data,/to_normal)
       xyouts,0.09,pos(1,0),'PCU4',/normal,alignment=1.
       loc=loc-1.
   ENDIF 
END 
