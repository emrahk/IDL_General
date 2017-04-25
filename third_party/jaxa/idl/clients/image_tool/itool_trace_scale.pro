;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       ITOOL_TRACE_SCALE
;
; PURPOSE:
;       Rescale TRACE image
;
; CATEGORY:
;       Image, utility
;
; EXPLANATION:
;
; SYNTAX:
;       Result = itool_trace_scale(image)
;
; INPUTS:
;       IMAGE   - 2D image array; may be rescaled
;       HEADER  - String vector holding header of TRACE FITS file
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT  - Rescaled image array
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       MIN_VAL    - Named output variable, new miminum value in IMAGE
;       MAX_VAL    - Named output variable, new maxinum value in IMAGE
;       COLOR_ONLY - Set this keyword to just get color table
;       LOG_SCALED - 1/0 if returned image is log scaled or not
;       NO_PREP    - set to not call TRACESCALE
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       Use in SSW environment for optimum results
;
; SIDE EFFECTS:
;       Input IMAGE array is rescaled.
;
; HISTORY:
;       Version 1, June 20, 1998, Zarro (SAC/GSFC), Written
;
; CONTACT: 
;       dzarro@solar.stanford.edu
;-
;

function itool_trace_scale,image,header,min_val=min_val,max_val=max_val,$
                  log_scaled=log_scaled,color_only=color_only,no_prep=no_prep

log_scaled=0

;-- check if required TRACE routines are in !path

have_tracescale=have_proc('tracescale2')
color_only=keyword_set(color_only)
do_prep=1-keyword_set(no_prep)

;-- apply color scaling if requested

do_prep=0
if (1-color_only) then begin
 if have_tracescale then begin
  if do_prep then $
   image=call_function('tracescale2',temporary(image),/byte,/full)
 endif else begin
  image=cscale(image,/log,/no_copy)
  log_scaled=1
 endelse
endif
max_val = max(image,min=min_val)

if have_proc('trace_colors') then begin
 index=fitshead2struct(header)
 trace_colors,index 
endif else loadct,3,/silent

return,image & end

