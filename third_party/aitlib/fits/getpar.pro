;;
;; getpar.pro
;; Read header keyword if a variable is set
;; J.W., 1996
;;
PRO getpar,header,keyword,variable
   IF (n_elements(variable) NE 0) THEN BEGIN 
       variable=fxpar(header,keyword)
   ENDIF 
END 
