;;
;; Function to plot labels in number - form
;;
;; e.g. plot,..,xtickformat='numlabel'
;; J.W.
;;
FUNCTION numlabel,axis,index,value
   str=strtrim(string(value),2)
   WHILE (strmid(str,strlen(str)-1,1) EQ '0') DO BEGIN 
       str=strmid(str,0,strlen(str)-1)
   END 
   IF (strmid(str,strlen(str)-1,1) EQ '.') THEN str=strmid(str,0,strlen(str)-1)
   return,str
END 
