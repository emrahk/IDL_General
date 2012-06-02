pro make_ph,typ,spectra,idf_hdr
;*************************************************************
; Program packages latest idf events list data arrays
; into phapsa spectral arrays. Variables are:
;      spectra...............spectral array
;          typ...............'EVTs' --> 'PHSs'
;      idf_hdr...............idf header
;          arr...............array of good NaI events loc.
; Requires the program get_evt.pro
; 7/11/95 Screens good events only
; 11/1/95 Rebins phapsa array correctly
; First define the common block:
;*************************************************************
common evt_parms,prms,prms_save,burst
common nai,arr,nai_only
common save_block,spec_save,idf_save,wait,num
;*************************************************************
; Set some variables. Make sure that the binsizes are integer
; dividends (?) of 256.
;*************************************************************
p1 = [256,128,64,32,16,8,4,2,1]
p2 = p1(2:8)
del = abs(p1 - prms(0))
prms(0) = p1(where(del eq min(del)))
del = abs(p2 - prms(1))
prms(1) = p2(where(del eq min(del)))
typ = 'PHSs'
npha = 256/prms(0)
npsa = 64/prms(1)
spec = lonarr(4,npsa,npha)
temp = fltarr(64,256)
num = fltarr(4)
;*************************************************************
; Form latest idf phapsa array
;*************************************************************
get_evt,spectra,pha,j1,j2,det_id,j3,j4,psa,j5,psuld
for i = 0,3 do begin
 in = where(det_id eq i,zz)
 num(i) = float(zz)
 if (in(0) ne -1)then begin
    max_pha = max(pha(in))
    max_psa = max(psa(in))
    temp(0:max_psa,0:max_pha) = $
    float(hist_2d(psa(in),pha(in)))
    spec(i,*,*) = $
    long(.5 + 16384.*rebin(temp,npsa,npha)/(npha*npsa))
 endif
endfor
if (ks(nai_only) ne 0)then begin
;*************************************************************
; Multiply by good event array
;*************************************************************
   if (ks(arr) eq 0)then get_nai,arr
   spec = arr*spec
endif
;*************************************************************
; Set the ouput variables
;*************************************************************
idf_hdr.nd = 0
spectra = spec
;*************************************************************
; Thats all ffolks
;*************************************************************
return
end
