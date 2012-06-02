pro specfits, fl, channel, counts, syserr, quality 

hd=headfits(fl)
tab=readfits(fl,hd,ext=1)
channel=fits_get(hd,tab,1)
counts=fits_get(hd,tab,2)
syserr=fits_get(hd,tab,3)
quality=fits_get(hd,tab,4)

return
end


