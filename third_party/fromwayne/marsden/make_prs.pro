pro make_prs,del=del,manual=manual,newfile=newfile
;*************************************************************
; Program packages latest idf events list data arrays
; into phase-resoved spectra_l arrays. Variables are:
;          typ...............'EVTs' --> 'HSTs'
;          del...............time offset
;        burst...............burst list mode data
;      del_low...............min time from previous IDF
;     del_high...............max   "    "     "      "
;           t0...............Barycenter dynamical time init.
;       manual...............UTCF Correction
;      newfile...............First IDF of new file (Boolean) 
;        num.................Number of good events array
; Requires the programs get_evt.pro, hexte_bary.pro, and
;                       removeorb.pro
; First define the common blocks:
;*************************************************************
common evt_parms,prms,prms_save,burst
common nai,arr,nai_only
common bary,ra,dec,asini,porb,t90,ecc,omega_d,p0
common hist_block,idf_hdr,idf,date,spectra,livetime,typ
common previous,t0,phase_shift
common save_block,spec_save,idf_save,wait,num
;*************************************************************
; Set some variables
;*************************************************************
if (ks(spectra) eq 0)then return
typ = 'HSTs'
if (ks(nai_only) eq 0)then nai_only = 0
if (ks(del) eq 0)then del = 0d
if (ks(t0) eq 0 and prms(4) eq 0d)then begin
   print,'USING T0 = IDF ',strcompress(idf)
   t0 = double(idf)
endif
if (prms(4) gt 0d)then t0 = prms(4)
npha = 256
freq = double(prms(0))
period = 1d/freq
fdot = double(prms(1))
ffdot = double(prms(2))
nbins = prms(3)
if (ks(phase_shift) eq 0)then phase_shift = 0d
;*************************************************************
; Correct the livetime array for the bum detector if 
; cluster 2 data after IDF 4295577.
;*************************************************************
clstr = strcompress(idf_hdr.clstr_id)
live = reform(livetime)
num = fltarr(4)
if (clstr eq 'CEU II' and idf ge 4295577l) then begin
   live(2) = 0.
   avg_live = total(live)/3.
endif else avg_live = total(live)/4.
;*************************************************************
; Alter the science header
;*************************************************************
idf_hdr.Na = prms(0)
idf_hdr.Nb = npha
idf_hdr.Nc = 1
;*************************************************************
; Form latest idf array. First get the events.
;*************************************************************
get_evt,spectra,pha,evt_time,j1,det_id,mfc4,agc,psa,bu=burst
;******************************************************************
; If cluster II data and after IDF 4295576, filter out the 
; data from PHA #3 (out of 4)
;******************************************************************
if (idf ge 4295576l and clstr eq 'CEU II')then begin
   in = where(det_id ne 2)
   pha = pha(in)
   evt_time = temporary(evt_time(in))
endif 
for i = 0,3 do begin
 in = where(det_id eq i,n)
 if (n ne 1)then num(i) = float(n)
endfor
evt_time_save = evt_time
;stop
;******************************************************************
; Convert to barycentric time if ra and dec are defined. First the
; intial idf edge is done, and then the arrival times are done.
; Also correct times for binary motion, if parameters are defined:
;******************************************************************
if (ks(ra) ne 0)then begin
   idf_time = idf + (evt_time)/16d
;stop
   hexte_bary,idf,ra,dec,bct0,man=manual
   if (t0 eq double(idf))then t0 = bct0(0)
   hexte_bary,idf+1d,ra,dec,bct1,man=manual
   hexte_bary,idf_time,ra,dec,bctime,man=manual
;stop
   if (asini ne 0.)then begin
      bctime_new = removeorb(bctime,asini,porb,t90,ecc,omega_d)
      bctime = bctime_new
      bct0_new = removeorb(bct0(0),asini,porb,t90,ecc,omega_d)
      bct0 = bct0_new
      bct1_new = removeorb(bct1(0),asini,porb,t90,ecc,omega_d)
      bct1 = bct1_new   
   endif
;stop
   evt_time = (bctime - t0)*86400d
;stop
endif else begin
   evt_time = 16d*(double(idf) + evt_time/16d - t0) 
   bct1 = 16d*(double(idf) - t0)
   bct2 = bct1 + 16d
endelse
dd = bct1 - bct0  
;*************************************************************
; Filter for good events. 
;*************************************************************
spec = lonarr(1,nbins,npha)
if (nai_only eq 1)then begin
   a = reform(arr(0,*,*))
   nai_arr = a(psa,pha) 
endif else nai_arr = 1
;*************************************************************
; Form the spectral array. 
;*************************************************************
for j = 0,npha-1 do begin
 in = where(pha eq j,n)
 if (in(0) ne -1)then begin
    time = evt_time(in)
    IF (prms(4) GE 0d)THEN BEGIN
;stop
       fold_evt_arr,time,period,nbins,tarr,fd=fdot,ff=ffdot,$
                    ph=p0
    endif else fold_evt_arr,time,period,nbins,tarr,fd=fdot,$
                            ff=ffdot,ph=p0
    spec(0,*,j) = tarr(0:nbins-1)
 endif
endfor
spectra = spec
;*************************************************************
; Form the livetime array. Find the phase of the starting 
; and ending integration times, and distribute the available 
; livetime uniformly throughout, according to which phase 
; bins are represented in the lightcurve.
;*************************************************************
time = fltarr(nbins,1)
evt_time = evt_time_save
time_arr = dindgen(10000)/9999d
tcounts = dblarr(10000)
aa = min(evt_time) lt 2d
bb = max(evt_time) gt 14d
if (aa eq 1 and bb eq 1) then time_arr = 16d*time_arr 
if (aa eq 0 and bb eq 0)then time_arr = 2d + 12d*time_arr
if (aa eq 0 and bb eq 1)then time_arr = 2d + 14d*time_arr
if (aa eq 1 and bb eq 0)then time_arr = 14d*time_arr
if (ks(ra) ne 0)then time_arr = 86400d*(bct0(0) - t0) + $
      time_arr else time_arr = bct0(0) + time_arr - t0
tcounts(*) = double(avg_live)/10000d
fold_time_arr,time_arr,tcounts,period,flc,np=nbins,fd=fdot,$
              ff=ffdot,ph=p0
time(*,0) = flc
;time(*,0) = replicate(avg_live/float(nbins),nbins)
livetime = time
;in = where(livetime lt 0.)
;if (in(0) ne -1)then stop
;*************************************************************
; That's all ffolks
;*************************************************************
return
end
      
   
