;+
; Project     : SOHO - CDS     
;                   
; Name        : EXT_RANGE()
;               
; Purpose     : Calculate extended range for plotting variables.
;               
; Explanation : In order to keep plotted values away from the axes of a plot
;               this function returns values of the axis limits to be used.
;               If max = min of data then range is set to [data-px%,data+px%]
;               if min=max=0 then [-1,1] is returned.
;               
; Use         : IDL> ax_lim = ext_range(x, px [,y, py, z, pz])
;    
; Inputs      : x  - 2-data vector containing data min,max values
;               px - percentage by which to extend range of variable
;               
; Opt. Inputs : y(z)  - same as x
;               py(z) - same as px
;               
; Outputs     : Function returns (2 x N) vector where N is the number of
;               input variables, giving the extended min,max axis values.
;               
; Opt. Outputs: None
;               
; Keywords    : POSITIVE - limit output values to positive.
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, display
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 23-Jun-94
;               
; Modified    : Add POSITIVE keyword.  CDP, 24-Nov-95
;
; Version     : Version 2, 24-Nov-95
;-            
function ext_range,ux,px,uy,py,uz,pz,positive=positive

;
;  check inputs
;
if n_params() lt 2 then begin
   print,'Use: ax_lim = ext_range(x,px [,y,py,z,pz])'
   return,0
endif

if (n_params() mod 2) ne 0 then begin
   print,'Must supply range extension percentage for each axis.'
   print,'Use: ax_lim = ext_range(x,px [,y,py,z,pz])'
   return,0
endif

out = fltarr(2,n_params()/2)


;
;  enlarge x range to keep 'em off axes
;
x = float(ux)
xr = max(x) - min(x)
if xr eq 0 then begin
   if min(x) eq 0 then begin
      out(*,0) = [-1,1]
   endif else begin
      if min(x) gt 0 then begin
         out(*,0) = [((100-px)/100.)*min(x), ((100+px)/100.)*min(x)]
      endif else begin
         out(*,0) = [((100+px)/100.)*min(x), ((100-px)/100.)*min(x)]
      endelse
   endelse
endif else begin
   mid = (max(x) + min(x))/2.0
   xr = ((100+px)/100.)*xr
   out(*,0) = [mid-xr/2.,mid+xr/2.]
endelse


;
;  enlarge y range to keep 'em off axes
;
if n_params() ge 4 then begin
   y = float(uy)
   yr = max(y) - min(y)
   if yr eq 0 then begin
      if min(y) eq 0 then begin
         out(*,1) = [-1,1]
      endif else begin
         if min(y) gt 0 then begin
            out(*,1) = [((100-py)/100.)*min(y), ((100+py)/100.)*min(y)]
         endif else begin
            out(*,1) = [((100+py)/100.)*min(y), ((100-py)/100.)*min(y)]
         endelse
      endelse
   endif else begin
      mid = (max(y) + min(y))/2.0
      yr = ((100+py)/100.)*yr
      out(*,1) = [mid-yr/2.,mid+yr/2.]
   endelse
endif


if n_params() ge 6 then begin
;
;  enlarge z range to keep 'em off axes
;
   z = float(uz)
   zr = max(z) - min(z)
   if zr eq 0 then begin
      if min(z) eq 0 then begin
         out(*,2) = [-1,1]
      endif else begin
         if min(z) gt 0 then begin
            out(*,2) = [((100-pz)/100.)*min(z), ((100+pz)/100.)*min(z)]
         endif else begin
            out(*,2) = [((100+pz)/100.)*min(z), ((100-pz)/100.)*min(z)]
         endelse
      endelse
   endif else begin
      mid = (max(z) + min(z))/2.0
      zr = ((100+pz)/100.)*zr
      out(*,2) = [mid-zr/2.,mid+zr/2.]
   endelse
endif

;
;  was positive set?
;
if keyword_set(positive) then out = out > 0

return, out

end
