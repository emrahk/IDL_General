pro get_data,fil,typ,idf,date,spectra,livetime,lost_events,idf_hdr,acc
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
; bytes_read.....................bytes read previously
;        acc.....................if defined then set pointer
; Spectra:
;    spectra.....................packed spectral data
; 5/22/94 Common block for previous bytes read and pointer positioning
;    "    Read errors exit routine + message
; 5/25/94 Zeroes livetime for no events 
;***************************************************************************
; Set up the needed arrays for data extraction 
;***************************************************************************
common file_pos,bytes_read
on_ioerror, dumb
if (ks(bytes_read) eq 0)then bytes_read = long(0)
if (ks(acc) eq 0)then bytes_read = long(0)
long_nums = 2.^(dindgen(32))
byte_nums = long_nums(0:7)
dbyte_nums = long_nums(0:15)
hbyte_nums = long_nums(0:3)
;***************************************************************************
; Position pointer
; Read the 256 longword header.
;***************************************************************************
idldat = lonarr(256)
get_lun,unit
openr,unit,fil
print,'POINTER SET TO BYTE ',bytes_read
point_lun,unit,bytes_read
readu,unit,idldat
;***************************************************************************
; Idldat(0): Extract the synch pattern
;***************************************************************************
num_read,32,idldat(0),long_bits
syn = ''
for i = 3,0,-1 do begin
 syn = syn + string(byte(total(long_bits(8*i:8*i+7)*byte_nums)))
endfor
syn = strcompress(syn,/remove_all)
;****************************************************************************
; Idldata(1): Get the type string of the data
;****************************************************************************
num_read,32,idldat(1),long_bits
typ = ''
for i = 3,0,-1 do begin
 typ = typ +  string(byte(total(long_bits(8*i:8*i+7)*byte_nums)))
endfor
typ = strcompress(typ,/remove_all)
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
;****************************************************************************
sch = idldat(16:27)
get_sci_hdr,sch,idf_hdr
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
   num_livetimes = dit(1)*dit(2)*dit(0)
   ptr = 0
   num_livetimes = dit(1)*dit(2)*dit(0)
   deadtime = dblarr(dit(2),dit(1),dit(0))
   dit = dit-1
   for num_time = 0,dit(0) do begin
    for num_accum = 0,dit(2) do begin
     for num_det = 0,dit(1) do begin
      deadtime(num_accum,num_det,num_time) = idldat(28 + ptr)
      ptr = ptr + 1
     endfor
    endfor
   endfor
   max_live = 16./(float(dit(2)) + 1.)
   deadtime_frac = deadtime/(524000.*max_live)
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
   ptr = 0
   lost_events = fltarr(dil(2),dil(1),dil(0))
   dil = dil-1
   for num_det = 0,dil(1) do begin
    for num_accum = 0,dil(2) do begin
     for num_time = 0,dil(0) do begin
      lost_events(num_accum,num_det,num_time) = idldat(92 + ptr)
      ptr = ptr + 1
     endfor
    endfor
   endfor
   dil = dil + 1
endif else begin
   lost_events = 0 
endelse     
;****************************************************************************
; Get the spectral data. It starts at 256 because of the 100 spares
;****************************************************************************
ptr = 0
word = lonarr(1)
dis = fix(dis)
spectra = lonarr(dis(2),dis(1),dis(0))
dis = dis - 1
;print,'GETTING SPECTRA ARRAY'
for num_det = 0,dis(2) do begin
 for num_spec = 0,dis(1) do begin
   for num_chn = 0,dis(0) do begin
   word(0) = long(0)
   readu,unit,word
   spectra(num_det,num_spec,num_chn) = word(0)
   ptr = ptr + 1
  endfor
 endfor
endfor
close,unit
free_lun,unit
bytes_read = bytes_read + long(4*(256 + ptr))
print,'BYTES_READ = ',bytes_read
;****************************************************************************
; Zero livetime if no events
;****************************************************************************
for i = 0,dis(2) do begin
 nz = where(spectra(i,*,*) ne 0)
 if (nz(0) eq -1) then livetime(*,i) = 0.
endfor 
;****************************************************************************
; Thats all folks I
;****************************************************************************
return
;****************************************************************************
; Error : Thats all ffolks II
;****************************************************************************
dumb : print,'READ PAST END OF FILE'
a = fstat(unit)
print,'POINTER START = ',bytes_read
print,'LENGTH OF FILE = ',a.size,' LONG WORDS'
acc = 'done'
return
end
       
