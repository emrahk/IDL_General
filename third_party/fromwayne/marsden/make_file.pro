pro make_file,idfs,idfe,dt,a_counts,a_lvtme,fname,typ,ltime
;********************************************************************
; Program writes the accumulated count rates into an ASCII 
; output file.
; Input variables:
;	idfs,idfe..................start,stop IDF#s
;              dt..................array of start,stop dates,times
;        a_counts..................array of accumulated counts
;         a_lvtme..................  "    "       "     livetime
;           fname..................filename
;             typ..................data type
; 6/10/94 Current version
; 8/26/94 Print Statements 
; First open file
;********************************************************************
if (not(ks(typ)))then begin
   typ = ''
endif else begin
   if (n_elements(string(typ)) ne 1)then begin
       pha_edgs = typ
       typ = 'MSCs'
   endif
endelse
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
if (typ eq 'PHSs')then begin
   num_dets = n_elements(a_counts(0,*,0,0))
   num_psa = n_elements(a_counts(0,0,*,0))
   num_pha = n_elements(a_counts(0,0,0,*))
endif else begin
   if (typ eq 'MSCs')then begin
      num_chns = n_elements(pha_edgs) - 1
      num_dets = n_elements(a_counts(0,*,0,0))
      num_tm_bns = n_elements(a_counts(0,0,0,*))
   endif else begin
      num_dets = n_elements(a_counts(0,*,0))
      num_chns = n_elements(a_counts(0,0,*))
   endelse
endelse
idf = [idfs,idfe] & idf = string(idf)
st = ['START :','END :']
cp_str = [' OFF(+)',' OFF(-)',' ON SOURCE']
;********************************************************************
; Write the Header information
;********************************************************************
s = '***********************HEADER INFORMATION***********************'
printf,unit,s
for i = 0,1 do begin
 s = st(i) + dt(i,0) + ',' + dt(i,1) + ',' + 'IDF# =' + idf(i)
 printf,unit,strcompress(s)
endfor
s = '# DETECTORS =' + string(num_dets) + ', ' + 'NUMBER PHA CHANNELS = '
if (typ eq 'PHSs')then begin
   s = s + string(num_pha) + ', NUMBER PSA CHANNELS = ' + string(num_psa)
endif else begin
   s = s + string(num_chns)
endelse
printf,unit,strcompress(s)
s = '*************************COUNTS ARRAYS**************************' 
printf,unit,s
;********************************************************************
; Write the counts and livetime to file. Loop over cluster position
; first, and then detector
;********************************************************************
for i = 0,2 do begin
 printf,unit,strcompress('CLUSTER POSITION :' + cp_str(i)) 
 for j = 0,num_dets - 1 do begin
  s = 'DETECTOR = ' + string(j+1) + ', LIVETIME = '
  s = s + string(a_lvtme(i,j)) + ' SEC' 
  printf,unit,strcompress(s)
  if (typ eq 'PHSs')then begin
     for k = 0,num_psa-1 do begin
      printf,unit,'PSA CHANNEL = ',k+1
      printf,unit,format='(15I7)',a_counts(i,j,k,*)
     endfor
  endif else begin
     if (typ eq 'MSCs')then begin
        for k = 0,num_chns-147 do begin
         str = strcompress('PHA EDGES ' + string(pha_edgs(k)) + $
         ' TO ' + string(pha_edgs(k+1)))
         printf,unit,str
         nz = where(a_counts(i,j,k,*) ne 0.)
         if (nz(0) ne -1)then begin
            for l = 0,num_tm_bns-1 do begin
             st = 'TIME = '+ string(l*ltime) +', COUNTS = ' + $
             string(a_counts(i,j,k,l))
             printf,unit,strcompress(st)
            endfor
         endif else begin
            printf,unit,'NO COUNTS!'
         endelse
        endfor
     endif else begin
        printf,unit,format='(15I7)',a_counts(i,j,*)
     endelse
  endelse
 endfor
endfor
;********************************************************************
; Display rates NET ON and NET OFF
;           rates1.........NET ON rates
;           rates2.........NET OFF rates 
;********************************************************************
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
