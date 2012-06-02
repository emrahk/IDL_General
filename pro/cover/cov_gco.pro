pro cov_gco,lo,la,an
map_set,lo,la,an,/ortho,/isotropic,/grid,/label,/noerase

;top detector

lap=findgen(26)+0.01
print,lap
lont=90-atan(tan(25*!pi/180.)/tan(lap*!pi/180.))*180./!pi
print,lont
lant=atan(tan(65*!pi/180)*cos(lont*!pi/180))*180/!pi

print,lant
;lant2=reverse(lant)
;lont2=lont+45
;lant3=lant
;lant5=lant
;lant7=lant
;lant4=lant2
;lant6=lant2
;lant8=lant2
;lont3=lont2+45
;lont4=lont3+45
;lont5=lont4+45
;lont6=lont5+45
;lont7=lont6+45
;lont8=lont7+45

;print,lant,lont

plots,lont,lant
plots,-lont,lant
plots,lont+180,lant
plots,-lont+180,lant
plots,lont+90,lant
plots,-lont+90,lant
plots,lont+270,lant
plots,-lont+270,lant
;plots,lont2,lant2
;plots,lont3,lant3
;plots,lont4,lant4
;plots,lont5,lant5
;plots,lont6,lant6
;plots,lont7,lant7
;plots,lont8,lant8

;x=cos(lant*!pi/180)*cos(lont*!pi/180)
;y=cos(lant*!pi/180)*sin(lont*!pi/180)
;z=sin(lant*!pi/180)


;an=25*!pi/180

;xp=x
;yp=y*cos(an)-z*sin(an)
;zp=x*sin(an)+z*cos(an)

;lantp=asin(zp)*180/!pi
;lontp=atan(yp/xp)*180/!pi

;for i=0,24 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
;plots,lontp,lantp
;print,lantp,lontp
;plots,-lontp,lantp


end
