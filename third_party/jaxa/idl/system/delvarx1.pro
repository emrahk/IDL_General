;+
; Project     : VSO
;
; Name        : DELVARX1
;
; Purpose     : Destroy variables and free all memory associated with
;               them
;
; Example     : IDL> delvarx1,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
;
; Inputs      : Up to 10 arguments - p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
;
; Outputs     : None
;
; History     : 16-June-2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

 pro delvarx1,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,_extra=extra

;-- Construct variable name 'p0', 'p1', etc
;-- Extract variable value using scope_varfetch

 for i=0,n_params()-1 do begin
  var_name='p'+strtrim(string(i),2)
  destroy,scope_varfetch(var_name,level=0)
 endfor
 return & end


