;Given an average count rate and an uncertainty per bin, determine
;the probablility that a moldulation is fit above a given threshold.

pro modprob

;23 July 2002
;ave=277.016
;dave=28.7234
;thresh=18.5396

;28 October 2003
;ave=685.154
;dave=41.6603
;thresh=23.7317

;28 October 2003
ave=138.
dave=16.
thresh=28.

cnt=fltarr(6)
dcnt=cnt
wcnt=cnt
x=60.*findgen(6)+30.

afit=fltarr(3)
afit=[1.,1.4,1.]
sigfit=afit
chifit=0.
yfit=fltarr(6)

iseed=536464
trig=0
for i=0,9999 do begin
  cnt(*)=ave+dave*randomn(iseed,24)
  dcnt(*)=dave


  wcnt=(1./dcnt^2)
  yfit=curvefit(x*(!pi/180.),cnt,wcnt,afit,sigfit,CHISQ=chifit,FUNCTION_NAME='polfunc')

  if (abs(afit(0)) ge thresh) then begin
    trig=trig+1
;    !x.range=[0.,360.]
;    !x.style=1
;    !y.range=[0.9*min(cnt),1.1*max(cnt)]
;    plot,!x.range,!y.range,/nodata
;    errplot,x,cnt-dcnt,cnt+dcnt
;    oplot,x,yfit
;    wait,1.
  endif
endfor

print,'Number of triggers: ',trig

return
end

pro polfunc,x,a,f,pder
;n=12
pder=fltarr(24,3)
f=a(2)-a(0)*cos(2.*(x-a(1)))
pder(*,0)=(-1.)*cos(2.*(x-a(1)))
pder(*,1)=(-2.)*a(0)*sin(2.*(x-a(1)))
pder(*,2)=1.0
return
end