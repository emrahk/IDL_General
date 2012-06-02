PRO rddata, file, ncol, data, nskip=nskip
;
IF (n_params() ne 3) THEN  BEGIN 
   print,' '
   print,'Usage: rddata, file, ncol, data [,nskip=nskip]'
   print,'	file = filename string'
   print,'	ncol = number of columns of data in the file'
   print,'	data = name of output data array'
   print,'      nskip = number of rows of input to skip'
   print,' '
   print,'rddata reads in a file of columnar data into a float array'
   print,' '
   return
ENDIF 
;
getwc = 'wc ' + file + "| gawk '{print $1}'"
spawn, getwc, wc 
wc = long(wc(0))
;print, wc
;
openr, u, file, /get_lun
IF keyword_set(nskip) THEN BEGIN
    wc = wc - nskip
    foo = 'bar'
    FOR i = 0,nskip-1 DO BEGIN
;        print, 'skipping line ', i+1
        readf,u,foo
;        print, foo
    ENDFOR
ENDIF
;
data = fltarr(ncol,wc)
readf,u,data
free_lun,u
END 


