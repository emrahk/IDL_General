PRO getcountinfo,data,counter=counter,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,mcm=mcm,$
                 messcount=messcount,chatty=chatty
;+
; NAME:           getcountinfo
;
;
;
; PURPOSE:
;                 Extract count info data out of a rawdata stream
;
;
; CATEGORY:
;                 Data-I/O
;
;
; CALLING SEQUENCE:
;                 getcountinfo,data,athr=athr,fifr=fifr,epdh=epdh,dslin=dslin,mcm=mcm,$
;                              messcount=messcount,chatty=chatty
;
; 
; INPUTS: 
;                 data     :    one dimensional array of rawdata returned by 
;                               readrawdata.pro
;
;
;
; OPTIONAL INPUTS: 
;                 none
;
;      
; KEYWORD PARAMETERS:
;                 chatty   :    Give more information on whats going
;                               on 
;
;
; OUTPUTS:
;                 none
;
;
; OPTIONAL OUTPUTS:
;                 athr     :    values of the above threshold counter
;                 fifr     :    valeus of the fifo read counter
;                 epdh     :    values of the epdh counter
;                 dslin    :    values of the discarded line counter
;                 mcm      :    values of the mean common mode
;                 messcount:    number of events in data stream
;
; COMMON BLOCKS:
;                 none
;
;
; SIDE EFFECTS: 
;                 none
;
;
;
; RESTRICTIONS:
;                 none
;
;
; PROCEDURE:
;                 see code
;
;
; EXAMPLE:
;                 getcountinfo,rawdata1,athr=athr1,fifr=fifr1,epdh=epdh1,dslin=dslin1,$
;                              messcount=mess0,mcm=mcm0,/chatty
;
;
; MODIFICATION HISTORY:
; V1.0 27.11.98 M. Kuster
; V1.1 07.11.98 M. Kuster changed dataformat to a structure instead of 
;                         simple variables; PLEASE USE THIS STRUCTURE
;                         NOT THE VARIABLES !!!!!!!!!!
;-   
   IF (keyword_set(chatty)) THEN BEGIN
       chatty=1
   END ELSE BEGIN
       chatty=0
   END
   
   cz=n_elements(data)-1
   enbit=byte(ishft(data,-30))
   count=where(enbit eq 1,co)
   
   
   IF co GT 3 THEN BEGIN 
       WHILE count(co-1) EQ cz DO BEGIN
           count=count(0:co-2)
           data=data(0:cz-1)
           enbit=enbit(0:cz-1)
           co=co-1
           cz=cz-1
       ENDWHILE
       WHILE count(0) EQ 0 AND co GT 1 DO BEGIN 
           count=count(1:*)-1
           data=data(1:*)
           enbit=enbit(1:*)
           co=co-1
       ENDWHILE 
       counter={countinfo,athr:long(0),fifr:long(0),epdh:double(0),dslin:long(0),$
                mcm:long(0),messcount:long(0)}       
       
       co=co/3
       coid=lindgen(co)*3
       athr=long(data(count(coid)) AND '0000ffff'xl)
       fifr=long(ishft(data(count(coid+1)),-16) AND '00003fff'xl)
       epdh=long(data(count(coid+1)) AND '0000ffff'xl)
       dslin=long(ishft(data(count(coid+2)),-16) AND '00003fff'xl)
       mcm=long(data(count(coid+2)) AND '0000ffff'xl)
       
       counter=replicate(counter,n_elements(athr))
       
       counter.athr=athr
       counter.fifr=fifr
       counter.epdh=epdh
       counter.dslin=dslin
       counter.mcm=mcm
       
       id=bytarr(n_elements(data))+1
       id(count)=0
       evid=where(id)
       data=data(evid)    ; nur noch Zeit- und Energieworte !!! (keine Counter)
       
       id(where(enbit ge 2))=0
       messcount=lonarr(co)
       messcount(0)=epdh(0)
       FOR k=long(1),co-1l DO BEGIN
           IF count(coid(k-1))+3 LE count(coid(k))-1 THEN $
             a=where(id(count(coid(k-1))+3:count(coid(k))-1),enct) ELSE enct=0
           messcount(k)=enct
       ENDFOR 
       counter.messcount=messcount
   ENDIF ELSE BEGIN 
       IF (chatty EQ 1) THEN BEGIN 
           print,'% GETCOUNTINFO: Warning No count-info data found !!!!'
           athr=-1
           fifr=-1
           epdh=-1
           dslin=-1
           mcm=-1
           messcount=-1
       END 
   ENDELSE      
END










