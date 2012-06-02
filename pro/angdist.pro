pro angdist,ra1,dec1,ra2,dec2,out

ra1r=double(ra1)*!PI/180.
ra2r=double(ra2)*!PI/180.
dec1r=double(dec1)*!PI/180.
dec2r=double(dec2)*!PI/180.

out=(180./!PI)*acos(cos(dec1r)*cos(dec2r)*cos(ra1r-ra2r)+sin(dec1r)*sin(dec2r))

end
