; Bestimmt die Kompressionsrate des Delta-E-Algorithmus
; Version 1.0
; Author  Eckart
; Date    11.10.1999
;
; kompressions-feld:
komp=dblarr(256)

; output of kompression measurement:
openw,1,"kompression.txt"

s=round(systime(1))
mean_val=20
num=10000

for i=1,255 do begin

  kompression=0
  for j=1,num do begin
   r1=randomn(s,poisson = i)
   r2 = randomn(s,poisson = i)
   if (abs(r1-r2) LT 8.0) then begin
     kompression = kompression + 0.5 
     ;  print,i,r1,r2,0.5,abs(r1-r2) 
    endif else begin  
     kompression = kompression + 1.5
    ;  print,i,r1,r2,1.5,abs(r1-r2) 
    endelse  
  endfor ; j
  komp[i] = kompression/num
endfor ; mean_val
printf,1, "Kompressionsrate (Delta-E):"
printf,1, "Mittelwert    Kompressionsfaktor"
FOR i=1,255 DO printf,1,i,komp[i]


print, "Kompressionsrate (Delta-E) fuer ",mean_val,":", komp[mean_val]
plot, bindgen(255),komp,XTITLE='Mean value',YTITLE='Compression rate', TITLE = 'Delta-E Algorithmus'


for i=1,255 do begin
  kompression=0
  for j=1,num do begin
   r1=randomn(s,poisson = i)
   if (r1 LT 15.0) then begin
     kompression = kompression + 0.5 
     ;print,i,r1,r2,0.5,r1
    endif else begin  
     kompression = kompression + 1.5
     ;print,i,r1,r2,1.5,r1
    endelse  
  endfor ; j
  komp[i] = kompression/num
endfor ; mean_val
printf,1, "Kompressionsrate (Flag--Methode):"
printf,1, "Mittelwert    Kompressionsfaktor"
FOR i=1,255 DO printf,1,i,komp[i]

print, "Kompressionsrate bei ",mean_val,"(Flag-Algorithmus):", komp[mean_val]
oplot, bindgen(255),komp
end
