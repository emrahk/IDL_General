function esegment,x
;+
; Name: esegment
;
; PURPOSE: to transform image <x> into a form in which loop-like
;   (one-dimensional) structures can be detected more easily,
;   regardless of the loop contrast amplitude or large-scale
;   background variation.  The *bright loop detection image* is
;   defined as ESEGMENT(x) GE 2.
;
; Input Parameters:
;    x - a 2D image array
;
; Output:
;    function returns map (same dimen as input) containing count
;    of nearest neighbors which exceed assocciated pixel
;
; ALGORITHM: count the number of directions (0 - 4) in which the
;   current pixel's value exceeds the values of both immediate
;   neighbors in that direction (N-S, E-W, NE-SW, NW-SE).
;
; Calling Sequence:
;    segimg=esegment(image)
;
; AUTHOR: Louis H. Strous, Lockheed Martin Solar & Astrophysics Lab,
;   Palo Alto, CA.
;
; JOURNAL PUBLICATION: by L.H. Strous, in "Solar Physics", forthcoming
;   special volume dedicated to the "Physics of the Solar Corona and
;   Transition Region" workshop, held in Monterey, California, on 24 -
;   27 August 1999.
;
; OTHER PLATFORMS: dynamic run-time loading module for IDL, written in
;   C.  http://ana.lmsal.com/anaidl.
;
; Category:
;    image processing, 2D, solarx
;
; HISTORY: IDL script version 1.0, 2 September 1999.
;           2-September-1999 - L.H.Strous - C->IDL port
;          14-September-1999 - S.L.Freeland - minor doc, -> SSW
;-
if data_chk(x,/nimage) ne 1 then begin 
   box_message,['2d Image input required...', $ 
                'IDL> segmap=esegment(image)']
   return,-1
endif
                   
 s = x gt shift(x,1,0) and x gt shift(x,-1,0)
 s = s + (x gt shift(x,0,1) and x gt shift(x,0,-1))
 s = s + (x gt shift(x,1,1) and x gt shift(x,-1,-1))
 s = s + (x gt shift(x,1,-1) and x gt shift(x,-1,1))
 return,s
end
