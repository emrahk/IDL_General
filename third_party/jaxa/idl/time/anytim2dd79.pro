
;  18-Aug-92
function anytim2dd79, time_arr
;+
;Name:
;	anytim2dd79
;Purpose:
;	Convert time in any standard format to decimal d79,
;Input:
;	TIME_ARR - The usual suspects
;Output:
;	N vector of dd79's
;History:
;-

ex_time = anytim2ex(time_arr)
ex2int,ex_time,msod,d79
dd79 = d79 + msod/86400000d

return, dd79

end

