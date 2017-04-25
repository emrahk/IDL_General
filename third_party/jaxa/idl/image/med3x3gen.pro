
;+
; NAME:
;        med3x3gen
; PURPOSE:
;        Generalized 3x3 median filter for image processing.
;        The generalization allows one to pick intensities other
;        than the median, or fifth brightest in each 3x3 environment.
;        For example, pick=1 returns the maximum, pick=9 the minimum,
;        and pick=6 the 3rd faintest of each 3x3 pixel neighborhood.
;        Edges and corners receive special treatment (same as in the
;        "amedian" function):
;        1 2 3    1 2 3			1 2 o    1 2 1
;        4 5 6 -> 4 5 6			3 4 o -> 3 4 3
;        o o o    1 2 3			o o o    1 2 1
; CATEGORY:
; CALLING SEQUENCE:
;        out = med3x3gen(in,pick=6)
;        out = med3x3gen(in,pick=5) = med3x3gen(in) = amedian(in,3)
; INPUTS:
;        in = input image
; KEYWORDS (INPUT):
;        pick = return the "pick"-brightest pixel of each 3x3 neighborhood.
;               default: pick=5 (regular median).
; OUTPUTS:
;        out = filtered output image
; KEYWORDS (OUTPUT):
; COMMON BLOCKS:
;        None.
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; MODIFICATION HISTORY:
;        JPW, 28-apr-98
;-

function med3x3gen,d,pick=p ;,slow=slow

;if n_elements(slow) eq 1 then print,systime()

if n_elements(p) ne 1 then p = 5L else p = long(p<9L) > 1L
sd = size(d)
if sd(0) ne 2 then begin
   print,'Error in sort_3x3: Image is not 2-D'
   return,0
endif

; create an interim array with an added 1 pixel wide border all around
b = make_array(size=sd+[0,2,2,0,0])		; interim array with borders
b(1,1) = d
; 4 edges, reflect pixels one in from the border
b(1,0) = d(*,1)
b(1,sd(2)+1) = d(*,sd(2)-2)
b(0,1) = d(1,*)
b(sd(1)+1,1) = d(sd(1)-2,*)
; 4 corners, note that the corners of b are not the corners of d!
b(0,0) = d(1,1)
b(sd(1)+1,0) = d(sd(1)-2,1)
b(0,sd(2)+1) = d(1,sd(2)-2)
b(sd(1)+1,sd(2)+1) = d(sd(1)-2,sd(2)-2)

; median of input image (identical to amedian(d,3))
b5 = median(b,3)
b5 = b5(1:sd(1),1:sd(2))

; if pick=5 then we're done
if p eq 5 then return,b5

; otherwise we have to sort the intensity values.
; The code below looks rather complicated, in an attempt to
; speed up the process and make maximum use of vectorization.
; (the same thing could be done with the following few statements:
;if keyword_set(slow) then begin
; for i=0,sd(1)-1 do begin
;   for j=0,sd(2)-1 do begin
;      bb = reform(b(i:i+2,j:j+2),9)
;      bb = bb(sort(bb))
;      b5(i,j) = bb(9-p)
;   endfor
; endfor
; return,b5
;endif
; )

; create an auxiliary array(*,*,4), initialize with median
o = make_array(size=[3,sd(1:2),4,sd(3:4)])
for i=0,3 do o(0,0,i) = b5

;fill in o with below median (p gt 5) or above median values (p lt 5)
nn = lonarr(sd(1),sd(2))	; counter array to keep track of filling
for j=0,2 do begin
   for i=0,2 do begin
      bb = b(i:i+sd(1)-1,j:j+sd(2)-1)
      if p gt 5 then ww = where(bb lt b5,nww) $
                else ww = where(bb gt b5,nww)
      if nww gt 0 then begin
         o(sd(1)*sd(2)*nn(ww)+ww) = bb(ww)
         nn(ww) = nn(ww)+1L
      endif
   endfor
endfor
if p gt 5 then pp=p-6 else pp=p-1	; adjust pick variable

; move lowest/highest value down,
; depending on whether pp ge 2
for i=3,1,-1 do begin
   if pp ge 2 then ww = where(o(*,*,i) lt o(*,*,i-1),nww) $
              else ww = where(o(*,*,i) gt o(*,*,i-1),nww)
   if nww gt 0 then begin
      b = o(sd(1)*sd(2)*(i-1)+ww)
      o(sd(1)*sd(2)*(i-1)+ww) = o(sd(1)*sd(2)*i+ww)
      o(sd(1)*sd(2)*i+ww) = b
   endif
endfor

; if we need either the maximum or minimum of the 4 sorted values
; (pp eq 0 or pp eq 3) then we're done.
if (pp eq 0 or pp eq 3) then begin
   b5 = o(*,*,0)
endif else begin
; otherwise we have to move down the minimum/maximum of the remaining
; three values
  for i=3,2,-1 do begin
    if pp ge 2 then ww = where(o(*,*,i) lt o(*,*,i-1),nww) $
               else ww = where(o(*,*,i) gt o(*,*,i-1),nww)
    if nww gt 0 then begin
      b = o(sd(1)*sd(2)*(i-1)+ww)
      o(sd(1)*sd(2)*(i-1)+ww) = o(sd(1)*sd(2)*i+ww)
      o(sd(1)*sd(2)*i+ww) = b
    endif
  endfor
  b5 = o(*,*,1)
endelse

;if n_elements(slow) eq 1 then print,systime()

return,b5

end
