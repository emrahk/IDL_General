function loadevts, fl, src, rt=rawtime, bary=bary

;restore,file='orbit_params.idl'
if (src eq '0115') then begin
   t90=49100.894340D
   porb=24.317037d
   asini=140.13d
   ecc=0.3402d
   omega=47.66d
endif

if (src eq 'herx1') then begin
   t90=48799.61235d
   porb=1.700167412d
   asini=13.1853D
   ecc=0.0d
   omega=0.0d
endif

sz=size(fl)
numfiles=sz(1)-1
tt=dblarr(1)

for i=0,numfiles do begin
   hd=headfits(fl(i))
   tab=readfits(fl(i),hd,ext=1)
   if (keyword_set(bary)) then begin
      var=fits_get(hd,tab,'BARYTIME')
   endif else begin
      var=fits_get(hd,tab,'Time')
   endelse
   tt=[tt,var]
endfor

timezero=fxpar(hd,'TIMEZERO')
mjdrefi=fxpar(hd,'MJDREFI')
mjdreff=fxpar(hd,'MJDREFF')
mjdref=double(mjdrefi)+double(mjdreff)

sz=size(tt)
ed=sz(1)-1

rawtime=tt(1:ed)

temptime=(rawtime+timezero)/86400.00d + mjdref
goodtime=removeorb(temptime,asini,porb,t90,ecc,omega)
goodtime=goodtime*86400.00d
goodtime=goodtime-(max(goodtime)+min(goodtime))/2.0d 

return,goodtime
end

