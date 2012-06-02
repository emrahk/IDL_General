pro ibis_fit_mod, data, data_pol, guess, res, disp

datamul=data
datamul_pol=data_pol

;first apply energy cut (20 keV for ISGRI, 140 keV for PICSIT)

;picsit first
xpic=where(datamul.dete[0] ge 8)
epic=where((datamul[xpic].en[0] ge 140.) and (datamul[xpic].en[1] ge 20.))
datapicf=datamul[xpic(epic)]

;kinematic cut

x=datapicf.pos(0,1)-datapicf.pos(0,0)
y=datapicf.pos(1,1)-datapicf.pos(1,0)
costeta=-10./sqrt(100.+x^2+y^2) ; 10cm isgri to picsit(negative)
equ=1./((1./datapicf.en[1])-((1.-costeta)/511.))
tote=datapicf.en[0]+datapicf.en[1]
kcutp=where((equ gt tote*.9) and (equ lt tote*1.1))
if (kcutp[0] ne -1) then datapicfkcut=datapicf[kcutp]

;isgri first
xpic=where(datamul.dete[0] lt 8)
epic=where((datamul[xpic].en[0] ge 20.) and (datamul[xpic].en[1] ge 140.))
dataisgf=datamul[xpic(epic)]

;kinematic cut

x=dataisgf.pos(0,1)-dataisgf.pos(0,0)
y=dataisgf.pos(1,1)-dataisgf.pos(1,0)
costeta=10./sqrt(100.+x^2+y^2) ; 10cm isgri to picsit
equ=1./((1./dataisgf.en[1])-((1.-costeta)/511.))
tote=dataisgf.en[0]+dataisgf.en[1]
kcuti=where((equ gt tote*.9) and (equ lt tote*1.1))
dataisgfkcut=dataisgf[kcuti]

if (kcutp[0] ne -1) then datamul=[datapicfkcut,dataisgfkcut] $
                    else datamul=dataisgfkcut


;picsit first
xpic=where(datamul_pol.dete[0] ge 8)
epic=where((datamul_pol[xpic].en[0] ge 140.) and (datamul_pol[xpic].en[1] ge 20.))
data_polpicf=datamul_pol[xpic(epic)]

;kinematic cut

x=data_polpicf.pos(0,1)-data_polpicf.pos(0,0)
y=data_polpicf.pos(1,1)-data_polpicf.pos(1,0)
costeta=-10./sqrt(100.+x^2+y^2) ; 10cm isgri to picsit(negative)
equ=1./((1./data_polpicf.en[1])-((1.-costeta)/511.))
tote=data_polpicf.en[0]+data_polpicf.en[1]
kcutp=where((equ gt tote*.9) and (equ lt tote*1.1))
if (kcutp[0] ne -1) then data_polpicfkcut=data_polpicf[kcutp]

;isgri first
xpic=where(datamul_pol.dete[0] lt 8)
epic=where((datamul_pol[xpic].en[0] ge 20.) and (datamul_pol[xpic].en[1] ge 140.))
data_polisgf=datamul_pol[xpic(epic)]

;kinematic cut

x=data_polisgf.pos(0,1)-data_polisgf.pos(0,0)
y=data_polisgf.pos(1,1)-data_polisgf.pos(1,0)
costeta=10./sqrt(100.+x^2+y^2) ; 10cm isgri to picsit
equ=1./((1./data_polisgf.en[1])-((1.-costeta)/511.))
tote=data_polisgf.en[0]+data_polisgf.en[1]
kcuti=where((equ gt tote*.9) and (equ lt tote*1.1))
data_polisgfkcut=data_polisgf[kcuti]

if (kcutp[0] ne -1) then datamul_pol=[data_polpicfkcut,data_polisgfkcut] $
                    else datamul_pol=data_polisgfkcut

;help,datamul,datamul_pol

;displacement cuts

positions=sqrt((datamul.pos(0,1)-datamul.pos(0,0))^2.+(datamul.pos(1,1)-datamul.pos(1,0))^2.)

xdisp=where((positions ge disp[0]) and (positions le disp[1]))
datamul=datamul[xdisp]

positions=sqrt((datamul_pol.pos(0,1)-datamul_pol.pos(0,0))^2.+(datamul_pol.pos(1,1)-datamul_pol.pos(1,0))^2.)

xdisp=where((positions ge disp[0]) and (positions le disp[1]))
datamul_pol=datamul_pol[xdisp]

print,'effects of cuts:'
print,'no cut=',n_elements(data)
print,'energy cut',n_elements(datapicf)+n_elements(dataisgf)
print,'kinematic cut',n_elements(datapicfkcut)+n_elements(dataisgfkcut)
print,'kinematic cut, only isgri first events',n_elements(dataisgfkcut)
print,'displacement cut',n_elements(datamul)


;hispol=histogram(datamul_pol.ang,min=0,binsize=18)
;his=histogram(datamul.ang,min=0,binsize=18)

;pixellate to match the real data
pixellate, datamul, angnp
pixellate, datamul_pol, angpol

hispol=histogram(angpol,min=0,binsize=18)
his=histogram(angnp,min=0,binsize=18)

his=his*total(hispol)/total(his)

hispol=[hispol,hispol]
his=[his,his]

xax=(findgen(40)*18.)+9.

ploterror,xax,hispol-his,replicate(6.,40),sqrt(2.*his),psym=1,/nohat,$
          xr=[-30,750],/xstyle,yr=[-max(hispol-his),max(hispol-his)]*1.2,$
         /ystyle,xtit='Scatter Azimuth Angle',ytit='Cnts/bin - syst.'


hish=his(0:19)
hispolh=hispol(0:19)

modelname='cosfit'
angs=(findgen(20)*18.)+9.
w=1./(2.*hish)

a=guess

yfit = curvefit(angs, hispolh-hish, w, a, sigmaa, function_name = modelname)
array = [transpose(a), transpose(sigmaa)]
print, array

x=findgen(720)
f=a(0)+a(1)*cos(2*((x-a(2))*!PI/180.))
plot,x,f,xr=[-30,750],/xstyle,/ystyle,/noerase,$
xtickname=replicate(' ',6),ticklen=0.,yr=[-max(hispol-his),max(hispol-his)]*1.2

res=array
modul=res(*,1)/avg(his)
print,reform(modul)

end
