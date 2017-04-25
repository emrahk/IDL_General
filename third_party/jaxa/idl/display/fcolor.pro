;+
; PROJECT:
;       SDAC
; 	
; NAME:
;	FCOLOR
; PURPOSE: 
;	This function is used with LINECOLORS.PRO for defaults if the device does
;	not support colors.
;	
; CALLING SEQUENCE
; 	color = fcolor(icolor)
;
; EXAMPLES:
;	oplot, archive_sec, yy, psym=10, color=fcolor(5)
;	xyouts, nx1lab, ylab, 'N', /normal, chars = ch_scale(.8,/xy), col=fcolor(9)
; CALLS:
;	none.
;	
; INPUTS:	
;	icolor - the linecolor index, i.e. 5 is yellow
;
; COMMON BLOCKS:
; 	common fcolor_ps, pscolor - used to communicate ps color state
;		    with ps.pro
; HISTORY:
;       Written by:	RAS, ~1991.
;       Modified 15 August 2011, Zarro - protect against negative icolor
; CONTACT:
;	richard.schwartz@gsfc.nasa.gov
;
;-

function fcolor, icolor
common fcolor_ps, pscolor

checkvar, icolor, !p.color

case !d.name of
        'X': color=indgen(16)
        'REGIS': color=indgen(16)
        'TEK': color=[0,intarr(15)+1]
        'PS' : color=indgen(16)
	else:  color=indgen(16)
endcase 


if !d.name ne 'PS' then begin
  if icolor gt 16 then result=icolor else result = color[0> icolor<15] 
  result =min([result, !p.color])
endif else result=icolor*fcheck(pscolor,0)

return, result
end
