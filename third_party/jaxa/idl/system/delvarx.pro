;+
; Project     : VSO
;
; Name        : DELVARX
;
; Purpose     : Destroy variables and free all memory associated with
;               them
;
; Example     : IDL> delvarx,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
;
; Inputs      : Up to 10 arguments - p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
;
; Outputs     : None
;
; History     : 16-June-2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

pro delvarx,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,_extra=extra,old=old


case 1 of
 keyword_set(old): delvarx0,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,_extra=extra
 since_version('7.1'): delvarx2,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
 since_version('6.1'): delvarx1,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
 else: delvarx0,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,_extra=extra
endcase

return & end
