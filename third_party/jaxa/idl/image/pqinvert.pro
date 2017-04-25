;+

pro pqinvert,pin,qin,pout,qout,x,y,degree=degree

;NAME:
;     PQINVERT
;PURPOSE:
;     Invert a set of p,q arrays (see poly_2d) so that the
;     transformation goes the other direction
;CATEGORY:
;CALLING SEQUENCE:
;     pqinvert,pin,qin,pout,qout,x,y
;INPUTS:
;     p,q = input transformation
;     x,y = the x,y coordinates for which the transformation is to be
;           computed.
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS
;OUTPUTS:
;     pout,qout = inverted transformation
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;PROCEDURE:
;     Straighforward use of polywarp.
;MODIFICATION HISTORY:
;     T. Metcalf  2001-Oct-09
;-

   ndegree = long(sqrt(n_elements(pin))+0.5) - 1L
   if ndegree LE 0 then message,'Degree must be at least 1.'
   if ndegree NE long(sqrt(n_elements(qin))+0.5)-1L then $
      message,'Error: pin and qin do not have the same degree'
   if n_elements(pin) NE (ndegree+1)^2 or $
      n_elements(qin) NE (ndegree+1)^2 then $
      message,'Error: pin and qin in must have (N+1)^2 elements'

   p = double(reform(pin,long(sqrt(n_elements(pin))+0.5), $
                         long(sqrt(n_elements(pin))+0.5)))
   q = double(reform(qin,long(sqrt(n_elements(qin))+0.5), $
                         long(sqrt(n_elements(qin))+0.5)))

   if keyword_set(degree) then begin
      if degree LT ndegree then begin
         p = p[0:long(degree),0:long(degree)]
         q = q[0:long(degree),0:long(degree)]
         ndegree = long(degree)
         message,/info, 'Restricting to degree '+string(long(degree))
      endif else message,'Not enough elements for degree '+string(long(degree))
   endif

   if n_elements(x) LE 0 OR n_elements(y) LE 0 then $
      message,'Error: you must specify x and y'

   pq2xy,x,y,p,q,xprime,yprime
   polywarp,x,y,xprime,yprime,ndegree,pout,qout

   pout = reform(pout,n_elements(pout))
   qout = reform(qout,n_elements(qout))

end
