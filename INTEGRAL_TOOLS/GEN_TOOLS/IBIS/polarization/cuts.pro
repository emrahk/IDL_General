pro cuts, datain, dataout, datankc, enc=enc, tol=tol, disp=disp

if (NOT keyword_set(enc)) then enc=[20.,140.] ; 20 keV for ISGRI, 140 keV for PICSIT
if (NOT keyword_set(tol)) then tol=.15 ; tolerance for kinematic cut
if (NOT keyword_set(disp)) then disp=[5.,100.] ; displacement cut

datamul=datain



;displacement cuts

positions=sqrt((datamul.pos(0,1)-datamul.pos(0,0))^2.+(datamul.pos(1,1)-datamul.pos(1,0))^2.)

xdisp=where((positions ge disp[0]) and (positions le disp[1]))
datamul=datamul[xdisp]



 ;apply energy cut 

;picsit first
xpic=where(datamul.dete[0] ge 8)
epic=where((datamul[xpic].en[0] ge enc[1]) and (datamul[xpic].en[1] ge enc[0]))
datapicf=datamul[xpic(epic)]

;kinematic cut

x=datapicf.pos(0,1)-datapicf.pos(0,0)
y=datapicf.pos(1,1)-datapicf.pos(1,0)
costeta=-10./sqrt(100.+x^2+y^2) ; 10cm isgri to picsit(negative)
equ=1./((1./datapicf.en[1])-((1.-costeta)/511.))
tote=datapicf.en[0]+datapicf.en[1]

kcutp=where((equ gt tote*(1.-tol)) and (equ lt tote*(1.+tol)))
if (kcutp[0] ne -1) then begin
   datapicfkcut=datapicf[kcutp]
   ar=lonarr(n_elements(equ))
   ar(kcutp) = 1
   wkc=where(ar eq 0)
   datapicfnkcut=datapicf[wkc]
endif else datapicfnkcut=datapicf


;isgri first
xpic=where(datamul.dete[0] lt 8)
epic=where((datamul[xpic].en[0] ge enc[0]) and (datamul[xpic].en[1] ge enc[1]))
dataisgf=datamul[xpic(epic)]

;kinematic cut

x=dataisgf.pos(0,1)-dataisgf.pos(0,0)
y=dataisgf.pos(1,1)-dataisgf.pos(1,0)
costeta=10./sqrt(100.+x^2+y^2) ; 10cm isgri to picsit
equ=1./((1./dataisgf.en[1])-((1.-costeta)/511.))
tote=dataisgf.en[0]+dataisgf.en[1]
kcuti=where((equ gt tote*(1.-tol)) and (equ lt tote(1.+tol)))
dataisgfkcut=dataisgf[kcuti]
ar=lonarr(n_elements(equ))
ar(kcutp) = 1
wkc=where(ar eq 0)
dataisgfnkcut=dataisgf[wkc]


if (kcutp[0] ne -1) then datamul=[datapicfkcut,dataisgfkcut] $
                    else datamul=dataisgfkcut

dataout=datamul
datankc=[datapicfnkcut,dataisgfnkcut]

end
