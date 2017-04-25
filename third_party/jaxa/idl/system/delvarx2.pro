;+
; Project     : VSO
;
; Name        : DELVARX2
;
; Purpose     : Destroy variables and free all memory associated with
;               them
;
; Example     : IDL> delvarx2,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
;
; Inputs      : Up to 10 arguments - p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
;
; Outputs     : None
;
; History     : 16-June-2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

PRO delvarx2, p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,_extra=extra

   destroy,p0
   destroy,p1
   destroy,p2
   destroy,p3
   destroy,p4
   destroy,p5
   destroy,p6
   destroy,p7
   destroy,p8
   destroy,p9

   return
   end
