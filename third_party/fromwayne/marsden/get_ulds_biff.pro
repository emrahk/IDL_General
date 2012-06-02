pro get_ulds,fil,idfarr,xulds,ulds,silnt=silnt
;**********************************************
; Program reads a file and forms arrays 
; of HEXTE XULD and ULD rates versus idf.
; Variables are:
;      fil........fasthk file of ULDs, XULDs
;   idfarr........array of idfs
;    xulds........array of xuld versus idf
;     ulds........array of ulds versus idf
;    silnt........no printouts(boolean)?
; The fasthk file must be formed using the 
; n-selection criterion fasthk .. -n IDF 
; R5 R6 R7 R8 R9 R10 R11 R12 -Ffilename
; First do usage:
;**********************************************
common oldulds,xulds_old,ulds_old,idfarr_old
if (n_elements(fil) eq 0)then begin
   print,'USAGE: get_ulds,filename,idfarr,' + $
         'xuld_array,uld_array,' + $
         '[silent=(boolean)]'
   return
endif
;**********************************************
; Create the initial output arrays:
;**********************************************
idfarr = 0l
xulds = [0l,0l,0l,0l]
ulds = [0l,0l,0l,0l]
;**********************************************
; Open and read the 'slough' off the file:
;**********************************************
if (ks(silnt) eq 0)then $
print,'Reading fasthk file ',fil
get_lun,unit
temp = ''
openr,unit,fil
for i = 0,2 do readf,unit,temp
;**********************************************
; Start reading the data. Read the time/date
; and discard first:
;**********************************************
while not eof(unit) do begin
   readf,unit,temp
stop
   temp = strcompress(temp)
;**********************************************
; Concatenate the ULD, and XULD for the given 
; IDF to the existing output arrays:
;**********************************************
   temp_arr = $
   strcompress(str_sep(temp,' '),/remove_all)
   skip = where(temp_arr eq 'NoData')
   if (skip(0) eq -1)then begin
      temp_arr = long(temp_arr(1:9))
      idfarr = [idfarr,temp_arr(0)]
      ulds = transpose([transpose(ulds),$
               transpose(temp_arr(1:4))])
      xulds = transpose([transpose(xulds),$
              transpose(temp_arr(5:8))])
   endif
endwhile
;**********************************************
; Trim off the initial zeros:
;**********************************************
len = n_elements(idfarr)
idfarr = idfarr(1:len-1)
xulds = xulds(*,1:len-1)
ulds = ulds(*,1:len-1)
;**********************************************
; Save arrays to old arrays:
;**********************************************
if (ks(xulds_old) eq 0)then xulds_old = 0
if (total(xulds_old) eq 0)then begin
   print,'Filling Common Block "Oldulds"'
   xulds_old = xulds
   ulds_old = ulds
   idfarr_old = idfarr
endif
;**********************************************
; Close the file and return:
;**********************************************
free_lun,unit
return
end 
