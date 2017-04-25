
;+

pro pq2xy,x,y,pin,qin,xprime,yprime

;NAME:
;   PQ2XY
;PURPOSE:
;   Takes a poly_2d transformation and uses it to convert an
;   x,y vector into the xprime,yprime coordinates after the 
;   transformation.
;CATEGORY:
;CALLING SEQUENCE:
;   pq2xy,x,y,p,q,xprime,yprime
;INPUTS:
;   x,y = input coordinates
;   p,q = the poly_2d transformation
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS
;OUTPUTS:
;   xprime,yprime = the transformed coordinates
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;PROCEDURE:
;MODIFICATION HISTORY:
;     T. Metcalf 2001-Oct-09
;-

   ndegree = long(sqrt(n_elements(pin))+0.5) - 1L
   if ndegree NE long(sqrt(n_elements(qin))+0.5)-1L then $
      message,'Error: p and q do not have the same degree'
   if n_elements(pin) NE (ndegree+1)^2 or $
      n_elements(qin) NE (ndegree+1)^2 then $
      message,'Error: p and q in must have (N+1)^2 elements'

   xprime = make_array(size=size([x]))
   yprime = make_array(size=size([y]))

   p = double(reform(pin,long(sqrt(n_elements(pin))+0.5), $
                         long(sqrt(n_elements(pin))+0.5)))
   q = double(reform(qin,long(sqrt(n_elements(qin))+0.5), $
                         long(sqrt(n_elements(qin))+0.5)))

   for i=0,ndegree do begin
      for j=0,ndegree do begin
         xprime = xprime + p[i,j]*(x^j)*(y^i)
         yprime = yprime + q[i,j]*(x^j)*(y^i)
      endfor
   endfor

end
