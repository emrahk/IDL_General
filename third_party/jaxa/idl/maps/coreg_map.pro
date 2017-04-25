;+
; Project     : SOHO-CDS
;
; Name        : COREG_MAP
;
; Purpose     : coregister input maps to a reference map
;
; Category    : imaging
;
; Syntax      : omap=coreg_map(imap,rmap)
;
; Inputs      : IMAP = input map to coregister
;               RMAP = reference map against which to coregister
;
; Outputs     : OMAP = output map coregistered to same roll and view angles 
;
; Keywords    : DROTATE = correct for differential solar rotation
;                         if IMAP and RMAP times are different
;               RESCALE = rescale pixel resolution spacing and
;                         dimensions of IMAP to RMAP
;               NO_PROJECT = do not reproject view angles              
; 
;               SAME_CENTER = re-center input to same FOV as rmap
;
; History     : Written 20 Aug 2001, Zarro (EITI/GSFC)
;               17 September 2008, Zarro (ADNET)
;                - added _EXTRA
;               14 November 2014, Zarro (ADNET)
;                - added /RESCALE
;               26 November 2104, Zarro (ADNET)
;                - added /NO_PROJECT
;                (not recommended as it defeats the purpose of coregistration)
;                15 January 2016, Zarro (ADNET)
;                - added call to GET_MAP_ANGLES
;                - made /KEEP_LIMB the default
;
; Contact     : dzarro@solar.stanford.edu
;-

function coreg_map,imap,rmap,drotate=drotate,rescale=rescale,$
                   _ref_extra=extra,err=err

err=''
if ~valid_map(imap) || ~valid_map(rmap) then begin
 err='Need two valid input maps.'
 pr_syntax,'omap=coreg_map(imap,rmap,[/drotate,/rescale,/no_project])'
 return,-1
endif

if (n_elements(rmap) ne 1) then begin
 err='Reference map cannot be array.'
 mprint,err
 return,-1
endif

if color_map(imap,true_index=index) then begin
 if index gt 0 then begin
  err='Cannot handle TrueColor maps yet.'
  mprint,err
  return,-1
 endif
endif
 
rcenter=rmap.roll_center
roll=rmap.roll_angle
center=get_map_center(rmap)
angles=get_map_angles(rmap,_extra=extra)
rsun=angles.rsun
l0=angles.l0
b0=angles.b0

if keyword_set(rescale) then begin
 resolution=get_map_space(rmap)
 outsize=get_map_size(rmap)
endif

if keyword_set(drotate) then rtime=get_map_time(rmap)

return,drot_map(imap,time=rtime,outsize=outsize,resolution=resolution,rsun=rsun,roll=roll,$
              center=center,rcenter=rcenter,_extra=extra,l0=l0,b0=b0,$
              /keep_limb,err=err)

end
