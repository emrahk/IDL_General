;+
; NAME:
;      GT_BSC_BINCAL
; PURPOSE:
;       to get BCS crystal bin calibration data from CALFILEs 
;       (wavelength dispersion, sensitivity, etc)
; CALLING SEQUENCE:
;       BINCAL=GT_BSC_BINCAL(CHAN_STRUCT,MODEID)
; INPUTS:
;       CHAN_STRUCT   - BCS channels (as vector or in index)
; OPTIONAL INPUT
;       MODEID        - Mode ID for channel grouping plan
; OUTPUTS:
;       BINCAL        - structure with fields:
;       .CHAN         - channel #
;       .NBINS        - number of bins per channel
;       .WAVE         - wavelength array (start edges)
;       .PHYSPOS      - physical positions of right hand edges
;                       of grouped bins
;       .MODEID       - modeid 
;       .SENSIT       - mean sensitivity of grouped bins
;       .W0           - start wavelength of detector
;       .DW           - dispersion (A/bin)
;       .BINARC       - angle to bin conversion (bin/arcmin)
;       .ROCKW        - rocking width (A)
;       .GAUSSW       - guassian detector width (A)
;       .EFAREA       - effective area (cm^2)
;       .NSTART       - first valid bin
;       .NEND         - last valid bin
;       .VERSION      - version number of CAL file used
; OPTIONAL KEYWORDS:
;        NOVALID      - do not extract valid channels
;        SMM          - if set, extract SMM BCS calibration info
; PROCEDURE:
;       Reads crystal curvature sensitivity and wavelength info.
;       Applies grouping plan to ungrouped CALFIL measurements
;       Group sensitivities by weighting them wrt to physical separation
;       of bins, e.g. (for double binning):
;
;   Sgroup = (S1+S2)/(B1+B2) where S1, S2 are individual sensitivities
;   which are equivalent to the counts produced by a flatfield normalized
;   to an average unit bin, and B1,B2 are the physical bin widths.
;
; HISTORY:
;       Written Nov. 1992 by D. Zarro (Applied Research Corp).
;       Modified Aug'93 (D. Zarro) -- speeded up using common block
;       Modified Sep'93 (D. Zarro) -- to extract valid wavelengths
;       Modified May'94 (DMZ) -- fixed potential bug in NSTART, NEND usage
;                             -- added FORCE keyword to force re-read of CAL files
;-
 
function gt_bsc_bincal,chan_struct,modeid,novalid=novalid,smm=smm,force=force

common bsc_bincal,s_bincal

on_error,1

if (n_elements(chan_struct) eq 0) then begin
 message,'usage --> BINCAL=GT_BSC_BINCAL(CHAN_STRUCT,MODEID)
endif

if keyword_set(smm) then message,'SMM-BCS not yet implemented',/info

;-- get channel and mode info

chans=gt_bsc_chan(chan_struct)
nchans=n_elements(chans)
if bsc_check(chan_struct) then begin
 modeid=chan_struct.bsc.modeid
 tags=tag_names(chan_struct.bsc)
 vtags=where(tags eq 'VALID_ANS',count)
 if count ne 0 then valid_ans=chan_struct.bsc.valid_ans else valid_ans=(not keyword_set(novalid))
endif else begin
 if n_elements(modeid) eq 0 then modeid=1
 valid_ans=(not keyword_set(novalid))
endelse

if n_elements(modeid) ne n_elements(chans) then $
 modeid=replicate(modeid(0),nchans)
if n_elements(valid_ans) ne n_elements(chans) then $
 valid_ans=replicate(valid_ans(0),nchans)

if keyword_set(force) then force=1 else force=0

maxb=256
gaussw=0.
for i=0,nchans-1 do begin
 chan=chans(i)
 mode=modeid(i)
 clook=where(chan eq [1,2,3,4],count)
 if count eq 0 then begin
  message,'invalid channel '+string(chan),/contin
  valid=0
 endif else begin

;-- check if this channel and modeid already treated

  found=0 & valid=1
  if n_elements(s_bincal) ne 0 then begin
   chk=where((chan eq s_bincal.chan) and (mode eq s_bincal.modeid),count)
   if count gt 0 then begin
    temp=s_bincal(chk(0)) & found=1
   endif
  endif

  if (not found) or force then begin
   rd_bcscal,chan,w0=w0,edges=edges,$
    sens=sens,disp=dw,efarea=efarea,binarc=binarc,$
    rockw=rockw,gaussw=gaussw,bstart=nstart,bend=nend,version=version

;-- get channel grouping 

   bcs_grp_plan, mode, nGroup, groups, nSampPChan, qdefined
   chan_group=groups(*,chan-1)  
   find=where(chan_group ne 0,count)
   if count eq 0 then begin
    message,'channel '+string(chan,'(i1)')+' not grouped',/continue
    physpos=edges & sensit=sens & nbins=maxb
    binarr=fltarr(nbins) & binarr(nstart:nend)=1
   endif else begin

;
;-- Even elements of grouping plan
;   contain the number of adjacent subgroups. Odd elements of grouping 
;   plan contain number of combined bins per subgroup.

    maxg=(size(groups))(1)
    even=2*findgen(maxg/2) & odd=even+1
    ngroups=count/2
    n_subgroups=chan_group(even)              ;-- # subgroups
    n_bins_subgroup=chan_group(odd)           ;-- # grouped bins per subgroup
    nbins=total(n_subgroups)

;-- output arrays

    sensit=fltarr(maxb) &  physpos=sensit
    binarr=fltarr(maxb) & binpos=binarr & binpos(nstart:nend)=1.

;
;-- Unfortunately have to use DO loops since grouping plan
;   can be arbitrary
   
    icount=-1 & bend=-1
    for j=0,ngroups-1 do begin
     nsubgrps=n_subgroups(j)
     nsbins=n_bins_subgroup(j)
     if (nsbins ne 0) and (nsubgrps ne 0) then begin
      for m=0,nsubgrps-1 do begin
       icount=icount+1
       bstart=bend+1
       bend=bstart+nsbins-1
       if (bend gt maxb-1) or (bstart gt maxb-1) or (icount gt maxb-1) then begin
        message,'strange grouping plan for modeid '+string(mode,'(i2)'),/cont
        goto,quit
       endif
       sensit(icount)=total(sens(bstart:bend))
       physpos(icount)=edges(bend)
       binarr(icount)=total(binpos(bstart:bend))/(bend-bstart+1.)
      endfor
     endif
    endfor
   endelse 

;
;-- dump output into BINCAL structure (arrays if more than one channel)
;

quit:

   find=where(binarr gt 0,count)

;-- knock off first two and last edge bins

   nstart=find(2)
   nend=find(count-2)
   wave=w0+physpos*dw

;-- Compute factors to convert from count/s/bin to photons/s/cm-2/A
;   fluxfac = (detector bin width)/ (effective area * wavelength bin width)

   dbin=[physpos(1:*)-physpos]
   ndbin=n_elements(dbin)
   dbin=[dbin,dbin(ndbin-1)]
   dbin(nend)=dbin(nend-1)
   fflag=where(dbin le 0.,bad)
   good=where(dbin gt 0)
   if bad gt 0 then dbin(fflag)=dbin(good(0))
   angwids=dw*dbin
   fluxfac=abs(dbin/angwids/efarea)

   temp  = {bincal           ,$
           chan:fix(chan)    ,$
           nbins:fix(nbins)  ,$
           modeid:fix(mode)  ,$
           wave:wave         ,$
           sensit:sensit     ,$
           fluxfac:fluxfac   ,$
           physpos:physpos   ,$
           dbin:dbin         ,$
           w0:w0             ,$
           dw:dw             ,$
           efarea:efarea     ,$
           binarc:binarc     ,$
           rockw:rockw       ,$
           gaussw:gaussw     ,$
           nstart:nstart     ,$
           nend:nend         ,$
           version:version    }
  endif

;-- save this into common

  if not found then begin
   if n_elements(s_bincal) ne 0 then $
    s_bincal=[s_bincal,temp] else s_bincal=temp
  endif
 
 endelse

 if valid then begin

;-- extract valid wavelength bins?

  if (valid_ans(i)) then begin
   n1=temp.nstart & n2=temp.nend
   zbuff=fltarr(maxb-(n2-n1+1)) 
   temp.dbin=[(temp.dbin)(n1:n2),zbuff]
   temp.wave=[(temp.wave)(n1:n2),zbuff]
   temp.physpos=[(temp.physpos)(n1:n2),zbuff]
   temp.sensit=[(temp.sensit)(n1:n2),zbuff]
   temp.fluxfac=[(temp.fluxfac)(n1:n2),zbuff]
   temp.nbins=(n2-n1+1)
  endif

  if i eq 0 then bincal=temp else bincal=[bincal,temp]
 endif
endfor

if n_elements(bincal) eq 0 then bincal=0

return,bincal & end


