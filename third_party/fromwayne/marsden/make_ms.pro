pro make_ms,typ,spectra,idf_hdr,manual=manual,evts=evts,$
            idf=idf,li=livetime,te=tedgs
;***************************************************************
; Program packages latest idf events list data arrays
; into multiscalar spectral arrays. Variables are:
;      spectra...............spectral array
;          typ...............'EVTs' --> 'MSCs'
;      idf_hdr...............idf header
;        burst...............keyword for burst data dump
;       ra,dec...............Ra & Dec for barycentering
;          idf...............IDF # (long) of data
;        times...............Event times
;      phasave...............pha values
;       manual...............UTCF correction (s)
;         evts...............Accumulate on-source events
;                            and pha if defined
;     livetime...............Instrumental livetime
;        tedgs...............Array of time edges
; Requires the program get_evt.pro, hexte_bary.pro, and 
;                      and remove_orb
; First define the common blocks:
;***************************************************************
common evt_parms,prms,prms_save,burst
common nai,arr,nai_only
common bary,ra,dec,asini,porb,t90,ecc,omega_d,p0
common events,idf0,times,phasave
common save_block,spec_save,idf_save,wait,num
;***************************************************************
; Set some variables
;***************************************************************
if (ks(idf) eq 0)then idf = 0d else idf = double(idf)
if (ks(idf0) eq 0)then idf0 = idf
if (ks(nai_only) eq 0)then nai_only = 0
nprms = n_elements(prms)
typ = 'MSCs'
if (prms(2) ne 1)then begin
   pha_edgs = prms(3:nprms-1)
   pha_edgs = temporary(pha_edgs(sort(pha_edgs)))
   pha_edgs = temporary(pha_edgs)-1
endif else pha_edgs = 4*indgen(65)
npha = n_elements(pha_edgs) - 1
if (prms(1) eq 0)then ndets = 1 else ndets = 4
tres = double(prms(0))
if (n_elements(evts) eq 0)then evts = 0 else $
evts = 1
num = fltarr(4)
;********************************************************************
; Alter the science header
;********************************************************************
idf_hdr.Na = prms(0)
idf_hdr.Nb = npha
idf_hdr.Nc = prms(1)
if (n_elements(pha_edgs) le 9)then idf_hdr.Nh = fix(pha_edgs)
;********************************************************************
; Form latest idf array.
;********************************************************************
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
evt_time_save = evt_time
;********************************************************************
; Figure out the blanking fraction of the IDF from the event 
; times:
;********************************************************************
if (min(evt_time) lt 2d and max(evt_time) gt 14d)then blank = 1d
if (min(evt_time) lt 2d and max(evt_time) le 14d)then blank = 14d/16d
if (max(evt_time) gt 14d and min(evt_time) ge 2d)then blank = 14d/16d
if (max(evt_time) le 14d and min(evt_time) ge 2d)then blank = 12d/16d
;********************************************************************
; Convert to barycentric time if ra and dec are defined. First the
; intial idf edge is done, and then the arrival times are done.
; If on-source idf, save the event times. Also correct times for 
; binary motion, if parameters are defined:
;********************************************************************
if (ks(ra) ne 0)then begin
   hexte_bary,idf,ra,dec,bctime0,man=manual
   idf_time = idf + evt_time/16d
   hexte_bary,idf_time,ra,dec,bctime,man=manual
   if (asini ne 0.)then begin
      bctime_new = removeorb(bctime,asini,porb,t90,ecc,omega_d)
      bctime = bctime_new
      bct0_new = removeorb(bctime0,asini,porb,t90,ecc,omega_d)
      bctime0 = bct0_new
   endif
   if (min(evt_time) lt 2d and max(evt_time) gt 14d and evts) $
   then begin
       if (ks(times) eq 0)then times = bctime else $
          times = [temporary(times),bctime]
       if (ks(phasave) eq 0)then phasave = pha else $
          phasave = [temporary(phasave),pha]
   endif 
   evt_time = bctime 
endif else begin
    if (min(evt_time) lt 2d and max(evt_time) gt 14d and evts) $
    then begin
       if (ks(times) eq 0)then times = evt_time else $
       times = [temporary(times),16d*(idf - idf0) + evt_time]
       if (ks(phasave) eq 0)then phasave = pha else $
          phasave = [temporary(phasave),pha]       
    endif 
endelse
;********************************************************************
; Now form the rest of the arrays
;********************************************************************      
if (ks(burst) eq 0)then tmax = double(16) else $
tmax = double(long(max(evt_time)))
spec = lonarr(ndets,npha,tmax/tres + 1d/2d)
;********************************************************************
; Get the time edge array for each bin. If barycenter correcting, 
; translate each time bin to TDB:
;********************************************************************
q = n_elements(spec(0,0,*))
tedgs = dblarr(2,q)
dt = 16d/q
tedgs(0,*) = dindgen(q)*dt
tedgs(1,*) = tedgs(0,*) + dt
del = reform(tedgs(1,*) - tedgs(0,*))
temp = where(del ne max(del))
arr = dblarr(2*q)
uniform = 1
if (ks(ra) ne 0)then BEGIN
    uniform = 0
   arr(*) = tedgs
   hexte_bary,double(idf)+arr/16d,ra,dec,edgs_tdb,man=manual
   if (asini ne 0.)then begin
      edgs_new = removeorb(edgs_tdb,asini,porb,t90,ecc,omega_d)
      edgs_tdb = edgs_new
   endif
   tedgs(*,*) = edgs_tdb
endif
;********************************************************************
; Loop through detectors, energy ranges, and time bins (if 
; non-uniform):
;********************************************************************
if (ks(ra))then tfac = 86400d else tfac = 1d
if (nai_only eq 1)then begin
   a = reform(arr(0,*,*))
   nai_arr = a(psa,pha) 
endif else nai_arr = evt_time ge 0d 
for i = 0,ndets-1 do begin
 if (ndets ne 1)then begin
    in_det = where(det_id eq i and nai_arr gt 0,n) 
    num(i) = float(n)
 endif else begin
    in_det = where(det_id lt 4 and nai_arr gt 0,n)
    num(*) = float(n)/4.
 endelse
 if (in_det(0) ne -1)then begin
    dt = evt_time(in_det)
    tt = tfac*(dt-min(tedgs))
    ttmax = tfac*(max(tedgs) - min(tedgs))
    dpha = pha(in_det)
    for j = 0,npha-1 do begin
     in2 = where(dpha ge pha_edgs(j) and dpha lt pha_edgs(j+1))
     if (in2(0) ne -1)then begin
        if (uniform) then BEGIN
           tt = tfac*(dt-min(tedgs))
           temp = histogram(tt(in2),mi=0d,ma=ttmax,bi=tres) 
        endif else BEGIN
           temp = lonarr(q)
           for k = 0,q-1 do begin
            tlow = tedgs(0,k) & thigh = tedgs(1,k)
            inq = where(dt(in2) gt tlow and dt(in2) lt thigh,nq)
            temp(k) = long(nq)
           endfor
        endelse
        spec(i,j,*) = temp(0:q-1)
     endif
    endfor
  endif 
endfor
spectra = long(spec)
ty = 'MSCs'
spe = spectra
;********************************************************************
; Convert the livetime array to an array of livetimes/time bin
;********************************************************************
livetime_save = reform(livetime)
frac = reform(del/total(del))
livetime = fltarr(ndets,tmax/tres + 1d/2d)
for i = 0,ndets-1 do livetime(i,*) = livetime_save(i)*frac/blank
sz = size(livetime)
if (sz(0) eq 1)then livetime = reform(livetime,sz(1),1)
if (ks(ra) eq 0)then tedgs = tedgs/16d + double(idf)
;********************************************************************
; That's all ffolks
;********************************************************************
return
end
      
   
