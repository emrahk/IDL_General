function ldfits,fl,name,ext=extension,key=key
   
   IF (keyword_set(extension) EQ 0) THEN extension=1
   
   hd=headfits(fl)
   tab=readfits(fl,hd,ext=extension)
   
   IF (keyword_set(key)) THEN BEGIN
       ;Getting A Keyword Parameter
;       print,'Getting Parameter '+name
       data=fxpar(hd,name)
   ENDIF ELSE BEGIN
       IF (n_elements(tab) NE 1) THEN begin
;           print,'Getting Column '+name
           data=fits_get(hd,tab,name)
       ENDIF ELSE BEGIN
           data=[0]
       endelse
   endelse
   
   return,data
END



