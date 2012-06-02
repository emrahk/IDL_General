function cosd, angd
;
;  calculate the cosine of angd which is given in degrees
;
degtorad = acos(-1.)/180.
cosine = cos(degtorad * angd)
return, cosine
end
