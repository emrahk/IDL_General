pro cutsan, datain, dataout, datankc, anout, histout, annkc, histnkc, enc=enc, in=in, out=out, disp=disp  

if (NOT keyword_set(enc)) then enc=[20.,140.,700.] ; 20 keV for ISGRI, 140 keV for PICSIT
if (NOT keyword_set(tol)) then tol=.15 ; tolerance for kinematic cut
if (NOT keyword_set(disp)) then disp=[5.,100.] ; displacement cut

datamul=datain

print,'total num=',n_elements(datamul)

;displacement cuts

positions=sqrt((datamul.pos(0,1)-datamul.pos(0,0))^2.+(datamul.pos(1,1)-datamul.pos(1,0))^2.)

xdisp=where((positions ge disp[0]) and (positions le disp[1]))
datamul=datamul[xdisp]

print,'after disp. cut',n_elements(datamul)


 ;apply energy cut 

;picsit first
xpic=where(datamul.dete[0] ge 8)
tote=datamul[xpic].en[0]+datamul[xpic].en[1]
epic=where((datamul[xpic].en[0] ge enc[1]) and (datamul[xpic].en[1] ge enc[0])$
           and (tote lt enc[2]))
datapicf=datamul[xpic(epic)]

;kinematic cut

x=datapicf.pos(0,1)-datapicf.pos(0,0)
y=datapicf.pos(1,1)-datapicf.pos(1,0)
costeta=-10./sqrt((10.8^2.)+x^2+y^2) ; 10cm isgri to picsit(negative)
tote=datapicf.en[0]+datapicf.en[1]
cosfi=1.-(511.*((1./datapicf.en[1])-(1./tote)))
teta=acos(costeta)
fi=acos(cosfi)
lim=abs(teta-fi)*180./!PI
kcutp=where(lim le in)
wkcp=where((lim gt in) and (lim lt out))

if (kcutp[0] ne -1) then datapicfkcut=datapicf[kcutp]
if (wkcp[0] ne -1) then datapicfnkcut=datapicf[wkcp]


;isgri first
xpic=where(datamul.dete[0] lt 8)
tote=datamul[xpic].en[0]+datamul[xpic].en[1]
epic=where((datamul[xpic].en[0] ge enc[0]) and (datamul[xpic].en[1] ge enc[1])$
           and (tote lt enc[2]))
dataisgf=datamul[xpic(epic)]

;kinematic cut

x=dataisgf.pos(0,1)-dataisgf.pos(0,0)
y=dataisgf.pos(1,1)-dataisgf.pos(1,0)
costeta=10./sqrt((10.8^2.)+x^2+y^2) ; 10cm isgri to picsit
tote=dataisgf.en[0]+dataisgf.en[1]
cosfi=1.-(511.*((1./dataisgf.en[1])-(1./tote)))
teta=acos(costeta)
fi=acos(cosfi)
lim=abs(teta-fi)*180./!PI
;print,n_elements(lim)
;plot,histogram(lim,min=0),xr=[0.,30.],psym=10.
kcuti=where(lim le in)
wkci=where((lim gt in) and (lim lt out))

dataisgfkcut=dataisgf[kcuti]
dataisgfnkcut=dataisgf[wkci]

if (kcutp[0] ne -1) then datamul=[datapicfkcut,dataisgfkcut] $
                    else datamul=dataisgfkcut

dataout=datamul

if (wkcp[0] ne -1) then datankc=[datapicfnkcut,dataisgfnkcut] $
                  else datankc=dataisgfnkcut


print,'energycut',n_elements(datapicf),n_elements(dataisgf)
print,'kinematic cut',n_elements(dataout),n_elements(datankc)


;this part for our histogramming


yy=n_elements(dataout)
anout=0.
histout=0.

datahist=dataout

while yy[0] ne -1 do begin
minang=min(datahist.ang)
anout=[anout,minang]
xx=where((datahist.ang ge minang-0.01) and (datahist.ang le minang+0.01))
histout=[histout,n_elements(xx)]  
yy=where(datahist.ang gt minang+0.01)
if (yy[0] ne -1) then datahist=datahist[yy]
endwhile

anout=anout(1L:n_elements(anout)-1L)
histout=histout(1L:n_elements(histout)-1L)


yy=n_elements(datankc)
annkc=0.
histnkc=0.

datahist=datankc
while yy[0] ne -1 do begin
minang=min(datahist.ang)
annkc=[annkc,minang]
xx=where((datahist.ang ge minang-0.01) and (datahist.ang le minang+0.01))
histnkc=[histnkc,n_elements(xx)]  
yy=where(datahist.ang gt minang+0.01)
if (yy[0] ne -1) then datahist=datahist[yy]
endwhile

annkc=annkc(1L:n_elements(annkc)-1L)
histnkc=histnkc(1L:n_elements(histnkc)-1L)

end
