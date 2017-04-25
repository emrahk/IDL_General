function tim2clon, time_arr, deg=deg
;+
;Name:
;	tim2clon  (** OBSOLETE ** See TIM2CAR instead)
;Purpose:
;	Calculate the 'Carrington' or heliographic longitude of the
;	central point of the solar disk corresponding to input time(s).
;Input:
;	time_arr - A structure array with the
;		fields .TIME and .DAY
;			(OR)
;		A 2xN array with the MSOD variable first, and the DS79
;		variable second (see example).  It
;		is assumed that they are the same length
;			(OR)
;		A 7xN array which hold the 7-element external 
;		representation of time.
;			(OR)
;		String array of times.
;Output:
;	returns a single array of longitudes.
;History:
;	Written by G.Slater Dec-92
;	19-May-97 (MDM) - Gutted and made to call TIM2CAR
;-
;

return, tim2carr(time_arr, dc=1-keyword_set(deg))
end

