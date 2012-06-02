pro make_ms,manual=manual,special=special
;*************************************************************
; Program packages latest idf events list data arrays
; into multiscalar spectral arrays. Variables are:
;      spectra...............spectral array
;          typ...............'EVTs' --> 'MSCs'
;      idf_hdr...............idf header
;        burst...............keyword for burst data dump
;       ra,dec...............Ra & DEc for barycentering
;          idf...............IDF # (long) of data
;        times...............Event times
;      phasave...............pha values
;       manual...............UTCF correction (s)
;      special...............Accumulate on-source events
;                            and pha if defined
; Requires the program get_evt.pro
; First define the common blocks:
;*************************************************************
common evt_parms,prms,prms_save,burst
common msclr_block,idf_hdr,idf,date,spectra,livetime,typ
common nai,arr,nai_only
common bary,ra,dec
common events,idf0,times,phasave
;*************************************************************
; Set some variables
;*************************************************************
if (ks(spectra) eq 0)then return
if (ks(idf) eq 0)then idf = 0d else idf = double(idf)
if (ks(idf0) eq 0)then idf0 = idf
if (ks(nai_only) eq 0)then nai_only = 0
nprms = n_elements(prms)
if (prms(2) ne 1)then begin
   pha_edgs = prms(3:nprms-1)
   pha_edgs = temporary(pha_edgs(sort(pha_edgs)))
   pha_edgs = temporary(pha_edgs)-1
endif else pha_edgs = 4*indgen(65)
npha = n_elements(pha_edgs) - 1
if (prms(1) eq 0)then ndets = 1 else ndets = 4
tres = double(prms(0))
if (n_elements(special) eq 0)then special = 0 else $
special = 1
;******************************************************************
; Alter the science header
;******************************************************************
idf_hdr.Na = prms(0)
idf_hdr.Nb = npha
idf_hdr.Nc = prms(1)
if (npha ne 64)then idf_hdr.Nh = fix(pha_edgs)
;******************************************************************
; Form latest idf array.
;******************************************************************
sz = size(spectra)
if (ks(burst) eq 0)then begin
   tmax = double(16)
   spec = lonarr(ndets,npha,tmax/tres + 1d/2d)
   if (sz(0) ne 3 or sz(3) ne 2 or sz(1) ne 1)then begin
      spectra = spec
      livetime = livetime*0.
      return
   endif else get_evt,spectra,pha,evt_time,j1,det_id,mfc4,agc,psa
endif else get_evt,spectra,pha,evt_time,j1,det_id,mfc4,agc,psa,$
                   bu=burst
;******************************************************************
; Convert to barycentric time if ra and dec are defined. First the
; intial idf edge is done, and then the arrival times are done.
; If on-source idf, save the event times.
;******************************************************************
if (ks(ra) ne 0)then begin
    hexte_bary,idf,ra,dec,bctime0,man=manual
    idf_time = idf + evt_time/16d
    hexte_bary,idf_time,ra,dec,bctime,man=manual
    if (min(evt_time) lt 2d and max(evt_time) gt 14d and special) $
    then begin
       if (ks(times) eq 0)then times = bctime else $
          times = [temporary(times),bctime]
       if (ks(phasave) eq 0)then phasave = pha else $
          phasave = [temporary(phasave),pha]
    endif 
    evt_time = (bctime - bctime0(0))*86400d
endif else begin
    if (min(evt_time) lt 2d and max(evt_time) gt 14d and special) $
    then begin
       if (ks(times) eq 0)then times = evt_time else $
       times = [temporary(times),16d*(idf - idf0) + evt_time]
    endif 
endelse
;******************************************************************
; Now form the rest of the arrays
;******************************************************************      
if (ks(burst) eq 0)then tmax = double(16) else $
tmax = double(long(max(evt_time)))
spec = lonarr(ndets,npha,tmax/tres + 1d/2d)
q = n_elements(spec(0,0,*))
if (nai_only eq 1)then begin
   a = reform(arr(0,*,*))
   nai_arr = a(psa,pha) 
endif else nai_arr = evt_time ge 0d 
for i = 0,ndets-1 do begin
 if (ndets ne 1)then in_det = where(det_id eq i and nai_arr gt 0) $
 else in_det = where(det_id lt 4 and nai_arr gt 0)
 if (in_det(0) ne -1)then begin
    dt = evt_time(in_det)
    dpha = pha(in_det)
    for j = 0,npha-1 do begin
     if (j ne npha-1)then in2 = $
     where(dpha ge pha_edgs(j) and dpha lt pha_edgs(j+1)) else $
     in2 = where(dpha ge pha_edgs(j)) 
     if (in2(0) ne -1)then begin
        temp = histogram(dt(in2),mi=0d,ma=tmax,bi=tres)
        spec(i,j,*) = temp(0:q-1)
     endif
    endfor
  endif 
endfor
spectra = long(spec)
;******************************************************************
; That's all ffolks
;******************************************************************
return
end
      
   
