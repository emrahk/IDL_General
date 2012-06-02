pro get_ulds,fil,idfarr,xulds,ulds,arms,trigs,$
             vetos,silnt=silnt
;**********************************************
; Program reads a file and forms arrays 
; of HEXTE XULD and ULD rates versus idf.
; Also, gets additional parameters for the 
; Freddie correction. Variables are:
;      fil........fasthk file of ULDs, XULDs
;   idfarr........array of idfs
;    xulds........array of xuld versus idf
;     ulds........array of ulds versus idf
;      arm........arm rate array
;     trig........trigger rate array
;     veto........h/w veto counter array
;    silnt........no printouts(boolean)?
; The fasthk file must be formed using the 
; n-selection criterion fasthk .. -n IDF 
; R5 R6 R7 R8 R9 R10 R11 R12 R33 R34 R35 R36 
; R37 R38 R39 R40 R21 R22 R23 R24 -Ffilename
; First do usage:
;**********************************************
common oldulds,xulds_old,ulds_old,idfarr_old,$
               arms_old,trigs_old,vetos_old,$
               alpha,beta
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
ulds = [0l,0l,0l,0l] & xulds = ulds
arms = xulds & vetos = xulds & trigs = xulds
;**********************************************
; Open and read the 'slough' off the file:
;**********************************************
if (ks(silnt) eq 0)then $
print,'READING FASTHK FILE ',fil
get_lun,unit
temp = ''
openr,unit,fil
;**********************************************
; Start reading the data. Read the time/date
; and discard first:
;**********************************************
while not eof(unit) do begin
   readf,unit,temp
   temp = strcompress(temp)
;**********************************************
; Concatenate the ULD, XULD, arm, trig, and 
; veto arrays for the given IDF to the existing 
; output arrays:
;**********************************************
   temp_arr = $
   strcompress(str_sep(temp,' '),/remove_all)
   skip = where(temp_arr eq 'NoData')
   len = n_elements(temp_arr)
   if (len ge 15)then newcor = 1 $
                 else newcor = 0
   if (skip(0) eq -1 and newcor eq 1)then begin
      temp_arr = long(temp_arr(1:21))
      idfarr = [idfarr,temp_arr(0)]
      ulds = transpose([transpose(ulds),$
               transpose(temp_arr(1:4))])
      xulds = transpose([transpose(xulds),$
              transpose(temp_arr(5:8))])      
      arms = transpose([transpose(arms),$
              transpose(temp_arr(9:12))])
      trigs = transpose([transpose(trigs),$
              transpose(temp_arr(13:16))])
      vetos = transpose([transpose(vetos),$
              transpose(temp_arr(17:20))])
   endif
   if (skip(0) eq -1 and newcor eq 0)then begin
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
if (newcor eq 1)then begin
   arms = arms(*,1:len-1)
   trigs = trigs(*,1:len-1)
   vetos = vetos(*,1:len-1)
endif
;**********************************************
; Save arrays to old arrays:
;**********************************************
if (ks(xulds_old) eq 0)then xulds_old = 0
if (total(xulds_old) eq 0)then begin
   xulds_old = xulds
   ulds_old = ulds
   idfarr_old = idfarr
   arms_old = arms
   trigs_old = trigs
   vetos_old = vetos
endif
;**********************************************
; Close the file and return:
;**********************************************
free_lun,unit
return
end 
