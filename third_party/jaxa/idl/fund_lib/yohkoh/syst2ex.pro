function syst2ex
;
;+
;   Name: syst2ex
;
;   Purpose: return current time in yohkoh db terms
;
;   slf, 6-mar-92 from existing routines 
;
;-
systarr=str2arr(strcompress(systime()),' ')
date=strcompress(systarr(2) + '-' + systarr(1) + '-' + $
	strmid(systarr(4),2,2),/remove)
time=systarr(3)
systtex=anytim2ex(date + ' ' + time)
return,systtex
end
