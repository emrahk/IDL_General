PRO mkfplotintens,file,intensmap=intensmap,min=min,max=max,hist=hist,ps=ps,$
                  ghost=ghost,comment=comment
   
   IF (NOT keyword_set(comment)) THEN comment=''
   
   FOR i=0, 3 DO BEGIN 
       mkreadquad,file,i,data=temp,/chatty
       IF ((i EQ 0) AND (n_elements(temp) GE 2)) THEN BEGIN 
           rawdata=temp 
       ENDIF ELSE BEGIN
           IF (temp(0) NE -1) THEN BEGIN 
               rawdata=[rawdata,temp]
           ENDIF 
       ENDELSE 
   ENDFOR 
   numdata=n_elements(rawdata)
   rawdata=rawdata(2:numdata-1)
   
   intensimg=mkdata2img(rawdata,/chatty)

   IF (keyword_set(ps)) THEN BEGIN 
       IF (keyword_set(ghost)) THEN BEGIN
          dispccd,intensimg,max=max,min=min,plotfile='intens.ps',title='Intensity-Map',$
             comment=comment,/data,/ps,/ghost
       ENDIF ELSE BEGIN 
           dispccd,intensimg,max=max,min=min,plotfile='intens.ps',title='Intensity-Map',$
             comment=comment,/data,/ps           
       END
   ENDIF ELSE BEGIN 
       dispccd,intensimg,max=max,min=min,/offset
   ENDELSE 
END






