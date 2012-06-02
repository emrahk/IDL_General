pro make_phfile,idfs,idfe,dt,det,det_str,opt,rate,livetime,fname
;********************************************************************
; Program writes the count rates for the displayed data to 
; an ascii file. Variables are:
;      idfs,idfe...............start,stop idf#s
;            det...............detector display option
;        det_str...............detector string
;           rate...............rates to write to file
;       livetime...............livetime for rates
;          fname...............filename for data
;            opt...............accumulation option
; First open file:
;********************************************************************
fname = strcompress(fname)
get_lun,unit
openw,unit,fname,error = err
if (err ne 0)then begin
   print,'ERROR : BAD FILENAME'
   fname = 'error'
   return
endif
;********************************************************************
; Get info from array sizes and define labels
;********************************************************************
num = n_elements(rate)
idf = [idfs,idfe] & idf = string(idf)
st = ['START :','END :']
case opt of
   1 : opt_str = ' NET ON'
   2 : opt_str = ' NET OFF'
   3 : opt_str = ' OFF+'
   4 : opt_str = ' OFF-'
   5 : opt_str = ' ON SRC'
   6 : opt_str = ' ANY'
endcase
;********************************************************************
; Write the Header information
;********************************************************************
s = '***********************HEADER INFORMATION***********************'
printf,unit,s
for i = 0,1 do begin
 s = st(i) + dt(i,0) + ',' + dt(i,1) + ',' + 'IDF# =' + idf(i)
 printf,unit,strcompress(s)
endfor
if (det ne 0)then s1 = strcompress(det_str(det-1)) else s1 = '?'
s = 'ACCUMULATION OPTION : ' + opt_str
printf,unit,strcompress(s)
s = 'DETECTOR : ' + s1
printf,unit,strcompress(s)
s = '# CHANNELS : ' + string(num)
printf,unit,strcompress(s)

s = 'LIVETIME : ' + string(livetime)
printf,unit,strcompress(s)
;********************************************************************
; Write rates
;********************************************************************
s = '*************************COUNTS RATES**************************'
printf,unit,s
printf,unit,format='(10F10.5)',rate
s = '****************************************************************' 
printf,unit,s
;********************************************************************
; Close file and free unit #
;********************************************************************
close,unit
free_lun,unit
;********************************************************************
; Thats all ffolks
;********************************************************************
return
end


