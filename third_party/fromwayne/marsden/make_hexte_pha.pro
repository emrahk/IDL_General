pro make_hexte_pha,a_cts,lvtm,fname=fname,bkg=bkg,$
                   cluster=cluster,prs=prs,ioc=ioc,iarr=iarr
;***************************************************************
; Program converts the accumulated counts array to a 
; series of FITS files for background and source+
; background readable by XSPEC. Uses program phagen.pro (PRB)
; and IDL AUL constituents. Variables are:
;        a_cts.........accumulated counts array
;         lvtm.........accumulated livetime
;        fname.........output file name root
;          bkg.........Backgound choice (0(+),1(-),2(both))
;      cluster.........Cluster 1 or 2
;          prs.........Phase resolved spectroscopy
;          ioc.........Pre CII, pw2 crapout
;         iarr.........Array of IDFs used in analysis
; First do usage:
;***************************************************************
common met,iarr_common
if (n_params(0) eq 0) then begin
   print,'USAGE:MAKE_HEXTE_PHA,CNTS,LVTME,' + $
         '[FNAME="ROOT"],[BKG=+1(+),-1(-),OR 0(BOTH)],' + $
         '[CLUSTER=],[PRS=],[IOC=(boolean)],[IARR=IDF array]'
   retall
end
;***************************************************************
; Set some variables.
;***************************************************************
a_counts = reform(a_cts)
lvtme = reform(lvtm)
if (ks(prs) eq 0)then begin
   nchan = n_elements(a_counts(0,0,*))
   ndets = n_elements(a_counts(0,*,0))
   nphz = 1
endif else begin
   ndets = 1
   nchan = n_elements(a_counts(0,0,*))
   nphz = n_elements(lvtme(0,*))
endelse
nspec = 1
chans = indgen(nchan) 
if (n_elements(iarr_common) ne 0)then iarr = iarr_common
if (n_elements(fname) eq 0)then fname = 'hexte_accum'
if (n_elements(bkg) eq 0)then bkg = 0
if (n_elements(cluster) eq 0)then cluster = 1
if (cluster eq 1)then dname = 'pwa' else dname = 'pwb'
if (n_elements(ioc) eq 0)then ioc = 0 else ioc = 1
qual = intarr(nchan)
if (cluster eq 2 and ioc eq 0)then $
print,'IGNORING C2/P2 IN TOTAL .PHA FILE!'
c2filt = [0,1,3]
if (n_elements(iarr) ne 0)then begin
;***************************************************************
; Create start and stop MET arrays:
;***************************************************************
   if (n_elements(iarr) eq 1)then begin
      metstarts = 16.*iarr
      metstops = 16.*(iarr+1l)
   endif else begin
      ia = iarr(where(iarr ne 0))
      in = where(ia - shift(ia,1) ne 1,n)
      if (n eq 1)then begin
         metstarts = 16.*min(ia)
         metstops = 16.*(max(ia) + 1l)
      endif else begin
         metstarts = fltarr(n) & metstops = metstarts
         metstarts(0) = 16.*ia(0)
         metstops(0) = 16.*(ia(in(1)-1)+1l)
         for i = 1,n-1 do begin
          metstarts(i) = 16.*ia(in(i))
          if (i ne n-1)then $
          metstops(i) = 16.*(ia(in(i+1)-1)+1l) $
          else metstops(i) = 16.*(max(ia)+1l)
         endfor
      endelse
   endelse
endif
;***************************************************************
; Loop through detectors for source and background .pha files.
; First calculate the rates and sigmas. Note that the livetime
; array for prs mode has already been averaged over the cluster.
;***************************************************************
if (ks(prs) eq 1)then begin
   i0 = ndets
   print,'ASSUMING PHASE RESOLVED FORMAT!' 
endif else begin
   i0 = 0
   print,'ASSUMING HISTOGRAM MODE!'
endelse
for k = 0,nphz-1 do begin
 for i = i0,ndets do begin
  cnts = lonarr(nchan)
  if (i lt ndets)then begin
     det = strcompress(dname+string(i),/remove_all)
     back = det 
     if (ks(prs) ne 0)then tm = lvtme(2,k) else tm = lvtme(2,i)
  endif else begin
     if (cluster eq 1 or ioc eq 1)then begin
        det = dname & back = dname
        if (ks(prs) eq 0)then $
        tm = total(lvtme(2,*))/4. else tm = lvtme(2,k)
     endif else begin
        det = 'pwb013' & back = 'pwb'
        if (ks(prs) eq 0)then $
        tm = total(lvtme(2,c2filt))/3. $
        else tm = lvtme(2,k)
     endelse 
  endelse
  if (tm ne 0.)then begin
     if (i lt ndets)then cnts(*) = a_counts(2,i,*) $
     else begin
         if (cluster eq 1 or ioc eq 1) then begin
            if (ks(prs) eq 0) then $
            cnts = reform(total(a_counts(2,*,*),2)) $
            else cnts = reform(a_counts(2,k,*))           
         endif else begin
            if (ks(prs) eq 0)then $
            cnts = reform(total(a_counts(2,c2filt,*),2)) $
            else cnts = reform(a_counts(2,k,*))
         endelse
     endelse
  endif 
;***************************************************************
; Write the on-source .pha file. If P.R.S. mode, only write
; summed file.
;***************************************************************
  if (ks(prs) ne 0)then sfil = fname + '_' + $
         strcompress(k,/remove_all) + det + '.pha' else $
  sfil = fname + '_' + det + '.pha'
  sfil = strcompress(sfil,/remove_all)
  if (det ne 'sum')then detname = strcompress(det,/remove_all) $
  else detname = strcompress(dname,/remove_all)
  if (ks(prs) eq 0)then begin
     phagen,chans,cnts,qual,fi=sfil,de=detname,ex=tm,$
            metstarts=metstarts,metstops=metstops,ba=back
  endif else begin
     if (i eq ndets)then phagen,chans,cnts,qual,fi=sfil,$
                         de=detname,ex=tm,metstarts=metstarts,$
                         metstops=metstops,ba=back
  endelse
;***************************************************************
; Now do the background files
;***************************************************************
  if (ks(prs) ne 0)then bkfil = fname + '_' + $
  strcompress(k,/remove_all) + det + '.bak' else $
  bkfil = fname + '_' + det + '.bak'
  bkfil = strcompress(bkfil,/remove_all)
  cnts = lonarr(nchan)
  if (bkg ne 0)then begin
     if (bkg eq -1)then begin
        bk = 1
        print,'USING - BACKGROUND!'
     endif else begin
        bk = 0
        print,'USING + BACKGROUND!'
     endelse
     if (i lt ndets)then begin
        if (ks(prs) eq 0)then begin
           tm = lvtme(bk,i) 
           if (tm ne 0.) then cnts = reform(a_counts(bk,i,*))
        endif else begin
           tm = lvtme(bk,k)
           if (tm ne 0.)then cnts = reform(a_counts(bk,k,*))
        endelse
     endif else begin
        if (ks(prs) eq 0)then begin
           if (cluster eq 1 or ioc eq 1)then begin
              tm = total(lvtme(bk,*))/4.
              if (tm ne 0.)then $
              cnts = reform(total(a_counts(bk,*,*),2))
           endif else begin
              tm = total(lvtme(bk,c2filt))/3.
              if (tm ne 0.)then $
              cnts = reform(total(a_counts(bk,c2filt,*),2))
           endelse
        endif else begin
           tm = lvtme(bk,k)
           if (tm ne 0.)then cnts = reform(a_counts(bk,k,*))
        endelse         
     endelse
  endif else begin
     print,'USING + AND - BACKGROUNDS!'
     if (i lt ndets)then begin
        if (ks(prs) eq 0)then begin
           tm = total(lvtme(0:1,i))
           if (tm ne 0.)then cnts = reform(total(a_counts(0:1,i,*),1)) 
        endif else begin
           tm = total(lvtme(0:1,k))
           if (tm ne 0.)then cnts = reform(total(a_counts(0:1,k,*),1))
        endelse
     endif else begin
        if (ks(prs) eq 0)then begin
           if (cluster eq 1 or ioc eq 1)then begin
              tm = total(lvtme(0:1,*))/4.
              if (tm ne 0.)then $
              cnts = total(total(a_counts(0:1,*,*),1),1)
           endif else begin
              tm = total(lvtme(0:1,c2filt))/3.
              if (tm ne 0.)then $
              cnts =total(total(a_counts(0:1,c2filt,*),1),1)
           endelse
        endif else begin
           tm = total(lvtme(0:1,k))
           if (tm ne 0.)then $
           cnts = reform(total(a_counts(0:1,k,*),1))
        endelse
     endelse
  endelse   
;***************************************************************
; Write the background .bak file. If P.R.S. mode only write 
; summed file.
;***************************************************************
  if (ks(prs) eq 0)then begin
     phagen,chans,cnts,qual,fi=bkfil,de=detname,ex=tm,ba=1,$
            metstarts=metstarts,metstops=metstops
  endif else begin
     if (i eq ndets)then phagen,chans,cnts,qual,fi=bkfil,$
                         de=detname,ex=tm,ba=1,$
                         metstarts=metstarts,metstops=metstops
  endelse
 endfor
endfor
;***************************************************************
; Thats all ffolks
;***************************************************************
return
end                
