function sind, angd
;
;  calculate the sine of angd which is given in degrees
;
degtorad = acos(-1.)/180.
sine = sin(degtorad * angd)
return, sine
end
