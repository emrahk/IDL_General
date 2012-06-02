FUNCTION getint,ti,p
   
   
   ;; Intelligent padding for values that aren't known
   ;; ...not so fast but safe
   ndx=where(p EQ 255,num)
   IF (num NE 0) THEN BEGIN 
       start=0
       IF (ndx[0] EQ 0) THEN BEGIN 
           p[0]=p[min(where(p NE 255))]
           start=1
       END 
       FOR i=start,num-1 DO BEGIN 
           p[ndx[i]]=p[ndx[i]-1]
       END 
   END 
   
   p1=shift(p,-1)
   p1[n_elements(p1)-1]=p1[n_elements(p1)-2]
   
   ;; Where det switches on
   an=where( (p EQ 0) AND (p1 EQ 1) )
   ;; where the det turns off
   en=where( (p EQ 1) AND (p1 EQ 0) )
   
   ;; special case that detector does nothing or turns on/off exactly
   ;; once
   IF (an[0] EQ -1 OR en[0] EQ -1) THEN BEGIN 
       pp=dblarr(2,1)
       ;; nothing happens
       IF (an[0] EQ -1 AND en[0] EQ -1) THEN BEGIN 
           ;; always off?
           pp[0,0]=ti[0] & pp[1,0]=ti[0]
           ;; no! always on!
           IF (p[0] EQ 1) THEN pp[1,0]=ti[n_elements(ti)-1]
           return,pp
       ENDIF 
       IF (an[0] EQ -1) THEN BEGIN 
           ;; only a switch off observed
           pp[0,0]=ti[0] & pp[1,0]=ti[en[0]]
           return,pp
       END 
       
       ;; last case: only switch on seen
       pp[0,0]=ti[an[0]] & pp[1,0]=ti[n_elements(ti)-1]
       return,pp
   ENDIF 
   
   ;;
   ;; General case of multiple on/off events
   an=an+1 ;; add one since we start in the next bin
   
   ;; take care of det being on at beginning or end
   IF (an(0) GT en(0)) THEN an=[0,an]
   IF (n_elements(an) GT n_elements(en)) THEN en=[en,n_elements(p)-1]
   
   ;; and return the values
   pp=dblarr(2,n_elements(an))
   pp(0,*)=ti(an)
   pp(1,*)=ti(en)

   return,pp
END 

PRO readxfl,file,pcu0,pcu1,pcu2,pcu3,pcu4,electron,mjd=mjd,nopcu0=nopcu0

;+
; NAME:
;             readxfl
;
;
; PURPOSE:
;             reads the .xfl file
;
;
; CATEGORY:
;             RXTE data analysis
;
;
; CALLING SEQUENCE:
;
; 
; INPUTS:
;
;
; OPTIONAL INPUTS:
;
;      
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
;
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
;       CVS Version 1.5, 2002/08/19, Thomas Gleissner, IAA Tuebingen
;          check whether all finite values of el0 are zero; 
;          if so, el0 cannot be used because the detector does not
;          work 
;       CVS Version 1.6, 2002/10/14, Thomas Gleissner, IAA Tuebingen
;          Variable EL0_DETECTOR was checked in a way that caused
;          problems if  keyword 'nopcu0' was set. I changed it..
;       CVS Version 1.7, 2002/10/14, Thomas Gleissner, IAA Tuebingen
;          I thought I had changed it ... but I had missed to delete
;          some parentheses. Now it works :)
;
;-

   maxint=500
   pc0=dblarr(2,maxint) & pcu0cnt=0
   pc1=dblarr(2,maxint) & pcu1cnt=0
   pc2=dblarr(2,maxint) & pcu2cnt=0
   pc3=dblarr(2,maxint) & pcu3cnt=0
   pc4=dblarr(2,maxint) & pcu4cnt=0

   FOR i=0,n_elements(file)-1 DO BEGIN 
       tab=readfits(file(i),h,/exten)
       tti=tbget(h,tab,'TIME')
       IF (keyword_set(mjd)) THEN BEGIN 
           mjdrefi=0.d0
           mjdreff=0.d0
           getpar,h,'MJDREFI',mjdrefi
           getpar,h,'MJDREFF',mjdreff
           tti=(tti/86400D0+mjdreff)+mjdrefi
       ENDIF 

       pp0=tbget(h,tab,'PCU0_ON')
       pp1=tbget(h,tab,'PCU1_ON')
       pp2=tbget(h,tab,'PCU2_ON')
       pp3=tbget(h,tab,'PCU3_ON')
       pp4=tbget(h,tab,'PCU4_ON')
       
       IF (NOT keyword_set(nopcu0)) THEN BEGIN 
           ;; do not use PCU0 to gauge background since
           ;; the Xenon layer is damaged
           el0=tbget(h,tab,'ELECTRON0')
           ;; we check whether all finite el0 values are 0;
           ;; if so, el0 cannot be used because the detector does not
           ;; work 
           el0_finite = where(finite(el0) EQ 1)
         IF (total(el0(el0_finite)) EQ 0) THEN el0_detector=0 $
           ELSE el0_detector=1
       ENDIF        

       ;; read the electron ratios. 
       el1=tbget(h,tab,'ELECTRON1')
       el2=tbget(h,tab,'ELECTRON2')
       el3=tbget(h,tab,'ELECTRON3')
       el4=tbget(h,tab,'ELECTRON4')
       
       ;; Number of valid measurements in each bin
       nu=finite(el1)+finite(el2)+finite(el3)+finite(el4)
       IF (NOT keyword_set(nopcu0)) THEN BEGIN
         IF (el0_detector EQ 1) THEN nu=nu+finite(el0)
       ENDIF   

       ;; Where the ratio is not defined
       ;; (e.g. detector is switched off), set the value to 0.
       ;; this way the averaging procedure isn't screwed up.
       IF (NOT keyword_set(nopcu0)) THEN BEGIN 
           ndx=where(finite(el0) EQ 0)
           IF (ndx[0] NE -1) THEN el0[ndx]=0.
       ENDIF 

       ndx=where(finite(el1) EQ 0)
       IF (ndx[0] NE -1) THEN el1[ndx]=0.
       
       ndx=where(finite(el2) EQ 0)
       IF (ndx[0] NE -1) THEN el2[ndx]=0.
       
       ndx=where(finite(el3) EQ 0)
       IF (ndx[0] NE -1) THEN el3[ndx]=0.

       ndx=where(finite(el4) EQ 0)
       IF (ndx[0] NE -1) THEN el4[ndx]=0.
       
       ;; Average electron ratio
       el=el1+el2+el3+el4
       IF (NOT keyword_set(nopcu0)) THEN BEGIN 
         IF (el0_detector EQ 1) THEN el=el+el0
       ENDIF 

       ndx=where(nu NE 0)
       el[ndx]=el[ndx]/nu[ndx] ;; el is 0 where it hasn't been measured
       
       IF (n_elements(ele) EQ 0) THEN BEGIN 
           ele=el
           tim=tti
       END ELSE BEGIN 
           ele=[temporary(ele),el]
           tim=[temporary(tim),tti]
       END 
       
       pp=getint(tti,pp0)
       pc0(0,pcu0cnt:pcu0cnt+n_elements(pp(0,*))-1)=pp(0,*)
       pc0(1,pcu0cnt:pcu0cnt+n_elements(pp(1,*))-1)=pp(1,*)
       pcu0cnt=pcu0cnt+n_elements(pp(0,*))

       pp=getint(tti,pp1)
       pc1(0,pcu1cnt:pcu1cnt+n_elements(pp(0,*))-1)=pp(0,*)
       pc1(1,pcu1cnt:pcu1cnt+n_elements(pp(1,*))-1)=pp(1,*)
       pcu1cnt=pcu1cnt+n_elements(pp(0,*))

       pp=getint(tti,pp2)
       pc2(0,pcu2cnt:pcu2cnt+n_elements(pp(0,*))-1)=pp(0,*)
       pc2(1,pcu2cnt:pcu2cnt+n_elements(pp(1,*))-1)=pp(1,*)
       pcu2cnt=pcu2cnt+n_elements(pp(0,*))

       pp=getint(tti,pp3)
       pc3(0,pcu3cnt:pcu3cnt+n_elements(pp(0,*))-1)=pp(0,*)
       pc3(1,pcu3cnt:pcu3cnt+n_elements(pp(1,*))-1)=pp(1,*)
       pcu3cnt=pcu3cnt+n_elements(pp(0,*))

       pp=getint(tti,pp4)
       pc4(0,pcu4cnt:pcu4cnt+n_elements(pp(0,*))-1)=pp(0,*)
       pc4(1,pcu4cnt:pcu4cnt+n_elements(pp(1,*))-1)=pp(1,*)
       pcu4cnt=pcu4cnt+n_elements(pp(0,*))
   END 

   pcu0=dblarr(2,pcu0cnt)
   pcu0(0,*)=pc0(0,0:pcu0cnt-1)
   pcu0(1,*)=pc0(1,0:pcu0cnt-1)

   pcu1=dblarr(2,pcu1cnt)
   pcu1(0,*)=pc1(0,0:pcu1cnt-1)
   pcu1(1,*)=pc1(1,0:pcu1cnt-1)

   pcu2=dblarr(2,pcu2cnt)
   pcu2(0,*)=pc2(0,0:pcu2cnt-1)
   pcu2(1,*)=pc2(1,0:pcu2cnt-1)

   pcu3=dblarr(2,pcu3cnt)
   pcu3(0,*)=pc3(0,0:pcu3cnt-1)
   pcu3(1,*)=pc3(1,0:pcu3cnt-1)

   pcu4=dblarr(2,pcu4cnt)
   pcu4(0,*)=pc4(0,0:pcu4cnt-1)
   pcu4(1,*)=pc4(1,0:pcu4cnt-1)
   
   
   electron=dblarr(2,n_elements(ele))
   ndx=sort(tim)
   electron[0,*]=tim[ndx]
   electron[1,*]=ele[ndx]
END 
