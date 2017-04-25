;+
; $Id: oneau.pro,v 1.1 2006/09/11 21:10:44 nathan Exp $
;
; PURPOSE:
;  gives the conversion factor from AU to Rsun
;
; CATEGORY:
;  geometry, mathematics, calibration
; 
; INPUTS:
;  strunits : string containing the requested output units
;             KM : kilometer
;             RSUN : Rsun  [default]
; 
; OUTPUTS:
;  units : a string containing the units of the output value
;  return : the value of one a.u. in the requested units
;
;-             

function oneau,strunits,units=units

if n_elements(strunits) ne 0 then begin
    strunits=strupcase(strunits)
    case strunits of
        'KM' : begin
            d= 149597870D
            units='Km'
        end
        'RSUN' : begin
            d=149597870D / 696000D
            units='Rsun'
        end
        else : begin
            d=149597870D / 696000D
            units='Rsun'
        end
    endcase
endif else begin
    d=149597870D / 696000D      ; 1 AU in Rsun
    units='Rsun'
endelse

return,d
end
