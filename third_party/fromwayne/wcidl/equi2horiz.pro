pro equi2horiz, hrang, dec, lat, azim, alt

hrang_rad = double(hrang)*!DPI/180.d
lat_rad   = double(lat)*!DPI/180.d
dec_rad   = double(dec)*!DPI/180.d

alt  = asin(sin(dec_rad)*sin(lat_rad) + $
            cos(dec_rad)*cos(lat_rad)*cos(hrang_rad))

azim = atan(-cos(dec_rad)*cos(lat_rad)*sin(hrang_rad), $
             sin(dec_rad)-sin(lat_rad)*sin(alt))

alt  = alt*180.d/!DPI
azim = azim*180.d/!DPI

return
end
