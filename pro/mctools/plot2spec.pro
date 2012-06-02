subdir = './'
;subdir = '/scratch/dove/kotelp/s+dgrids/powdenshe/n1.5h2.5/'
titlename = ''
read, 'Which file do you want to plot? ',titlename 
;titlename = 'T150L000100K0150'
filename = subdir+titlename
specread,spe1,filename,1
loadct,39

npts = 100
emin = .1
emax = 1.e3
specplot,spe1(0),erange=[0.1,1.e3],frange=[1.e-2,1.],fluxtype=2, $
  color=[100],norm=1

wait,1.0

;subdir = '/scratch/dove/kotelp/s+dgrids/sphTofR1/'
;titlename = 'T150L000100K0150'
read,'enter second filename ',titlename
filename = subdir+titlename

specread,spe2,filename,1
ospecplot,[spe2(0)],color=[200],norm=1

END 




