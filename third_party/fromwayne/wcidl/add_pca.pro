pro add_pha,files_add,file_out,comments=comments,$
            add_live=add_live,backfile=backfile,$
             rmfile=rmfile,arfile=arfile
;***************************************************
; Program combines .pha files for spectral 
; fitting purposes with XSPEC. Variables are:
;   files_add........string array of filenames
;    comments........comments for header
;    file_out........output filename
;    add_live........boolean for adding livetimes
;    backfile........background file name
; Needs /home/hexte/idl/phagen.pro and the 
; assorted library fits programs.
; First print usage:
;***************************************************
if (n_elements(files_add) eq 0)then begin
   print,'USAGE: add_pha,filelist,' + $
         'output_filename,[comments=],' + $
          '[add_live=(no)],[backfile=(string)]' + $
           ',[rmfile=(string)],[arfile=(string)]'
   return
endif
;***************************************************
; Get some initial variables
;***************************************************
time_sum = 0.
counts_sum = 0
n = n_elements(files_add)
if (n eq 1)then begin
   print,'Only one filename entered!!'
   return
endif
if (n_elements(file_out) eq 0)then $
file_out = 'summed_pha.pha'
;***************************************************
; Begin loop to add together counts and 
; livetimes. Read the counts array and 
; read the livetime and detector name. 
; Add the livetimes and counts to the 
; previous total.
;***************************************************
nfac = 0.
for i = 0,n-1 do begin
 hdr = headfits(files_add(i))
 fxbopen,unit,files_add(i),1,hdr
 fxbread,unit,counts,2
 time = fxpar(hdr,'EXPOSURE')
 detnam = fxpar(hdr,'DETNAM') 
 if (i eq 0)then begin
    rs = fxpar(hdr,'RESPFILE')
    ar = fxpar(hdr,'ANCRFILE')
 endif
 fxbclose,unit
 time_sum = time_sum + time
 counts_sum = counts_sum + counts
 nfac = nfac + 1.
endfor
if (n_elements(add_live) ne 0)then nfac = 1.
;***************************************************
; Form the necessary arrays for writing to 
; the new fits file.
;***************************************************
chans = indgen(n_elements(counts_sum))
q = 0*chans
comments_new = strarr(n+1)
comments_new(0) = 'FILES ADDED:'
comments_new(1:n) = files_add
if (n_elements(comments) ne 0)then $
comments = [comments,comments_new] $
else comments = comments_new
if (n_elements(rmfile) eq 0)then rmfile = rs
if (n_elements(arfile) eq 0)then arfile = ar
;***************************************************
; Write the new fits file containing the summed
; counts and livetimes.
;***************************************************
detnam = strcompress(detnam,/remove_all)
phagen,chans,counts_sum,q,comments,de=detnam,$
       ex=time_sum/nfac,fi=file_out,ba=backfile,$
        rm=rmfile,ar=arfile
print,'Summed spectral file ',$
strcompress(file_out,/remove_all),' created.'
;***************************************************
; Thats all ffolks.
;***************************************************
return
end
