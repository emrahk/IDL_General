pro get_data,fil,typ,idf,date,spectra,livetime,lost_events,idf_hdr,$
             acc,err=err
;**********************************************************************
; The following reads the instrument and spectral data and makes 
; idl arrays for further analysis. The data is passed in idl form
; as a long integer array of (256 + 32768) integer*4 elements 
; The structure variables are (G.H 8/24/93):
; The data file with the idldat array:
;        fil.....................filename string
; Initial data structure:
;     idldat.....................long array
; Header arrays:
;        syn.....................synch pattern "fGSE'
;        typ.....................type code
;        idf.....................instrument data frame
;        tct.....................timer count 
;        dit.....................dimensions of livetime arrays
;        dil.....................     "      " lost event arrays
;        dis.....................     "      " spectral data arrays
;        sch.....................science header data string (long)
;    idf_hdr.....................    "     "      "   (bit arrays)
;   livetime.....................livetime array
;lost_events.....................lost events array
;        err.....................error signal
; Spectra:
;    spectra.....................packed spectral data
; 6/10/94 Current version
; 8/22/94 Remove print statements
; 1/4/95 Shows arguments
; First do common block
;***************************************************************************
common file_pos,bytes_read
;***************************************************************************
; Show argument list
;***************************************************************************
if (n_params() eq 0)then begin
   print,'USAGE:GET_DATA,FILE,TYP,IDF,DATE,SPECTRA,LIVETIME,' + $
         'LOST_EVENTS,IDF_HDR,ACC'
   return
endif
;***************************************************************************
; Set up the needed arrays for data extraction 
;***************************************************************************
on_ioerror, dumb
if (ks(bytes_read) eq 0)then bytes_read = long(0)
if (ks(acc) eq 0)then bytes_read = long(0)
long_nums = 2.^(dindgen(32))
byte_nums = long_nums(0:7)
dbyte_nums = long_nums(0:15)
hbyte_nums = long_nums(0:3)
idldat = lonarr(256)
;***************************************************************************
; Point the file pointer and open the file. 
;***************************************************************************
get_lun,unit
openr,unit,fil
temp = fstat(unit)
if (bytes_read ge temp.size)then begin
   acc = 'done'
   free_lun,unit
   print,'END OF FILE REACHED'
   return
endif 
point_lun,unit,bytes_read
;***************************************************************************
; Read the 256 longword header
;***************************************************************************
readu,unit,idldat
;***************************************************************************
; Idldat(0): Extract the synch pattern
;***************************************************************************
num_read,32,idldat(0),long_bits
syn = ''
for i = 3,0,-1 do begin
 syn = temporary(syn) + string(byte(total(long_bits(8*i:8*i+7)*byte_nums)))
endfor
syn = strcompress(temporary(syn),/remove_all)
;****************************************************************************
; Idldata(1): Get the type string of the data
;****************************************************************************
num_read,32,idldat(1),long_bits
typ = ''
for i = 3,0,-1 do begin
 typ = temporary(typ) +  string(byte(total(long_bits(8*i:8*i+7)*byte_nums)))
endfor
typ = strcompress(temporary(typ),/remove_all)
;****************************************************************************
; Idldat(2): Get the idf # and the timer count. The timer count 
; is defined as the 1/8 second Universal Time mark of the data 
; since Jan 1, 1992 at 00:00:00.000. Conver timer count to 
; data string (9/2/93)
;****************************************************************************
idf = idldat(2) & tct = idldat(3)
tct_time,tct,date
;****************************************************************************
; Get the dimension of the livetime data
; Get the dimension of the lost event event arrays. Dil(0) = 0 means
; there are no lost events. Get the dimension of the spectral arrays
;****************************************************************************
dit = idldat(4:7)
dil = idldat(8:11)
dis = idldat(12:15)          
;****************************************************************************
; Get the science data header array, this is processed 
; separately because the arrays are in byte form and must 
; be cut explicitely from the idldat array. This process has
; many similarities to extracting wisdom teeth. The extracted
; science data header idf_hdr contains the arrays as specified 
; in design memo 30061-710-009,rev d or thereabouts.
; If archive histogram type, set the science header data flag.
;****************************************************************************
sch = idldat(16:27)
if (strcompress(typ,/remove_all) eq 'ARCh')then arch = 1
get_sci_hdr,sch,idf_hdr,arch=arch
;****************************************************************************
; Now get the livetime (actually deadtime) arrays. The pointers are
; designated by 'ptr'. Loop through arrays with the pointer.
; Convert from clock pulses to fraction by dividing by max_live*524000
; where max_live is the maximum possible livetime. Convert to livetime by 
; subtracting from maximum livetime/integration. If dit(0) = 0,
; that means callibration histogram and we set default 16 second
; livetime for 4 detectors.
; 5/19/94 Reading deadtime bassackwards.OOPS! Corrected
;****************************************************************************
if (dit(0) ne 0)then begin
   deadtime = dblarr(dit(2),dit(1),dit(0))
   num = dit(2)*dit(1)*dit(0)
   rec = idldat(28:28 + num-1)
   dt_tran = fltarr(dit(0),dit(1),dit(2))
   dtran = reform(rec,dit(0),dit(1),dit(2))
   for i = 0,dit(2)-1 do begin
    dtran_ref = reform(dtran(*,*,i),dit(0),dit(1))
    deadtime(i,*,*) = transpose(dtran_ref)
   endfor
   dit = dit - 1
   max_live = 16./(float(dit(2)) + 1.)
   deadtime_frac = deadtime/(522938.*max_live)   ; seconds
   livetime = max_live*(1. - deadtime_frac)
   lt0 = where(livetime lt 0.)
   if (lt0(0) ne -1)then livetime(lt0) = 0.
endif else begin
    livetime = fltarr(1,4) & livetime(0,*) = 16.0
endelse
;****************************************************************************
; Get the lost events array. Format is the same as the livetime array. If 
; no lost events set nelv = 1
;****************************************************************************
if (dil(0) ne 0) then begin
   ptr = dil(0)*dil(1)*dil(2)
   rec = idldat(92:92 + ptr-1)
   lost_events = lonarr(dil(2),dil(1),dil(0))
   lev_tran = lonarr(dil(0),dil(1),dil(2))
   ltran = reform(rec,dil(0),dil(1),dil(2))
   for i = 0,dil(2)-1 do begin
    ltran_ref = 0
    ltran_ref = reform(ltran(*,*,i),dil(0),dil(1))
    lost_events(i,*,*) = transpose(ltran_ref)
   endfor
endif else begin
   lost_events = 0 
endelse     
;****************************************************************************
; Get the spectral data. It starts at 256 because of the 100 spares
;****************************************************************************
d = float(dis)
rec = lonarr(d(2)*d(1)*d(0))
readu,unit,rec
spec_tran = lonarr(dis(0),dis(1),dis(2))
stran = reform(rec,dis(0),dis(1),dis(2))
spectra = lonarr(dis(2),dis(1),dis(0))
for i = 0,dis(2)-1 do begin
 stran_ref = 0
 stran_ref = reform(stran(*,*,i),dis(0),dis(1))
 spectra(i,*,*) = transpose(stran_ref)
 nz = where(spectra(i,*,*) ne 0)
 if (nz(0) eq -1)then livetime(*,i) = 0.
endfor
free_lun,unit
bytes_read = temporary(bytes_read) + long(4*(256 + dis(0)*dis(1)*dis(2)))
;****************************************************************************
; Thats all folks I
;****************************************************************************
return
;****************************************************************************
; Error : Thats all ffolks II
;****************************************************************************
dumb : if (ks(unit) ne 0)then free_lun,unit else begin
   print,'File I/O Error!'
   err = 1
endelse
return
end
      
