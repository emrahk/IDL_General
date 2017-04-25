function goes_class2value, goes_class

sclass=string(goes_class)
mant=strtrim(str2number(sclass),2)
eclass=strmid(goes_class,0,1)

gcl=str2arr('A,B,C,M,X')
expcl=str2arr('8,7,6,5,4')

expon=reverse(intarr(n_elements(gcl)) + 8)
retval=mant
for c=0,n_elements(gcl)-1 do begin 
  ssc=where(eclass eq gcl(c),sscnt)
  if sscnt gt 0 then begin
     retval(ssc)=mant(ssc)+'e-0' + expcl(c) 
  endif else box_message,'No flares of class ' +gcl(c)
endfor

return, retval
end


  
