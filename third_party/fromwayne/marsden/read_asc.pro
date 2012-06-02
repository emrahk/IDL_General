pro read_asc,fil,idf_time,on=on
;***********************************************
; Program reads the event times from an ASCII
; file that has been output from eventspb.
; The variables are:
;       fil..........ASCII eventspb file
;  idf_time..........Time array (IDF)
;        on..........on source data only (Bool.)
; First do usage: 
;***********************************************
if (n_elements(fil) eq 0)then begin
   print,'USAGE: read_asc,filename,idf_time' + $
        ',[on=(Boolean)]'
   return
endif
;***********************************************
; Set some variables
;***********************************************
num = 0
go = '1'
s = ''
csec = 2d^17
idf_sec = 16d
lastidf = 1l
skipidf = 1l
if (n_elements(on) eq 0)then on = 0 else on = 1
;***********************************************
; Open the file
;***********************************************
on_ioerror, dumb
get_lun,unit
openr,unit,fil
print,'Reading ASCII file ',fil
while (go eq '1')do begin
;***********************************************
; Start reading the file: read the 1st record
; Proceed only if not skipped idf
;***********************************************
   readf,unit,s
   idfii = long(strmid(s,0,9))
   if (idfii ne skipidf)then begin
;***********************************************
; If on source only proceed only if the fisrt
; mfc value is less than 2
;***********************************************
      mfc = strmid(s,24,3)
      first = idfii ne lastidf 
      if (on and mfc ge 2 and first)then begin
         skipidf = idfii
         lastidf = idfii
      endif else begin
         tt = double(strmid(s,13,7))
         time = double(idfii-1l) + $
                (double(mfc) + tt/csec)/idf_sec
         if (num eq 0)then begin
            idf_time = time 
            num = 1
         endif else idf_time = [idf_time,time]
         lastidf = idfii
      endelse
   endif else lastidf = idfii
endwhile
free_lun,unit
return
;***********************************************
; Error : Thats all ffolks II
;************************************************
dumb : if (ks(unit) ne 0)then begin
   free_lun,unit
   if (num eq 0l)then print,'File I/O Error!'
endif
return
end
