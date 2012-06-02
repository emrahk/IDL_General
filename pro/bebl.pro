pro bebl,m,zi,zm,en,i,a

;m=mass in MeV
;zi = charge of incoming
;zm=charge of material,
;en = kinetic energy of incoming
;i = correction factor

;first obtain beta

x=en/m
beta=sqrt((x^2+2*x)/(1+x^2+2*x))
fb=alog(1.022e6*beta*beta/(1-beta*beta))-beta*beta
print,beta,fb
bs=beta*beta

bb=(0.30708/bs)*zi^2*(zm/a)*(fb-alog(i*zm))
print,bb
end



