;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_EIT_SCALE()
;
; PURPOSE:
;       Rescale an image based on EIT image scaling algorithm
;
; CATEGORY:
;       Image, utility
;
; EXPLANATION:
;
; SYNTAX:
;       Result = itool_eit_scale(image)
; INPUTS:
;       IMAGE   - 2D image array; may be rescaled
;       HEADER  - String vector holding header of EIT FITS file
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
;       COLOR_ONLY - Set this keyword to just get EIT color table
;       NO_PREP    - Set to inhibit calling EIT_PREP
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       Environment variable SSW_EIT must be properly defined to get
;       EIT routines and color tables 
;
; SIDE EFFECTS:
;       Input IMAGE array is rescaled.
;
; HISTORY:
;       Version 1, March 8, 1996, Liyun Wang, NASA/GSFC. Written
;       Version 2, April 22, 1996, Liyun Wang, NASA/GSFC
;          Applied degridding algoritum before rescaling
;       Version 3, September 30, 1996, Liyun Wang, NASA/GSFC
;          Added COLOR_ONLY keyword
;       Version 4, October 23, 1997, Liyun Wang, NASA/GSFC
;          Calls EIT_DEGRID directly if SSW_EIT is defined
;	Version 5, 31-Oct-1997, William Thompson, GSFC
;	   Make sure that EIT_DEGRID is actually in the path.
;	Version 6, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;       Version 7, Zarro (SAC/GSFC) - saved check for EIT_DARK in common
;       Version 8, 1-Jun-98, Zarro (SAC/GSFC) - added call to DO_EIT_SCALING
;
; CONTACT: 
;       dzarro@solar.stanford.edu
;-
;

function itool_eit_scale, image, header, min_val=min_val, max_val=max_val, $
                      color_only=color_only,no_prep=no_prep,index=index
 
   if (1-keyword_set(color_only)) then begin
    image=do_eit_scaling(image,header=header,index=index,/no_copy,no_prep=no_prep)
    max_val = max(image,min=min_val)
    dprint,'max_val,min_val: ',max_val,min_val
    image=cscale(image,/no_copy,/log)
   endif
   max_val = max(image,min=min_val)
    dprint,'max_val,min_val: ',max_val,min_val

   load_eit_color, header
   return, image
   end

