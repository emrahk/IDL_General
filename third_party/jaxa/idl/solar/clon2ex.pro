                
;  16-Aug-92
function clon2ex, clon_arr, rad=rad, rotnum=rotnum
;+
;Name:
;	clon2ex
;Purpose:
;	Calculate times corresponding to input 'Carrington'
;	longitudes.
;Input:
;	CLON_ARR - A 2xN array with rotation number in the first index
;		   and longitude in degrees in the second index,
;				OR
;		   An N vector containing decimal rotation numbers.
;Output:
;	TIME_ARR
;History:
;	Written 16-Aug-92 by G. Slater
;-

clon_ref = [1850d,1864d]
time_ref = [4725.84d,5107.72d]
m = (time_ref(1)-time_ref(0))/(clon_ref(1)-clon_ref(0))
b = -m*clon_ref(0) + time_ref(0)

dclon_arr = double(clon_arr)
siz_clon = size(dclon_arr)
if siz_clon(0) eq 2 then $
  c_rot = reform(dclon_arr(0,*)) + reform(dclon_arr(1,*)/360d) else $
  c_rot = dclon_arr

time_arr = m*c_rot + b

return, dd792ex(time_arr)

end

