;; convert2fits - reads data in and converts it to 
;; fits data
;; eg, 31-03-2003


;; setup:
reftime = 50000.D0


;; read XMM data:
print, "XMM MOS1"
readxmm,time,rate,error=error,/mos1, reftime=reftime,header=header,binning=1
readxmm,barytime,rate,/mos1, reftime=reftime,/bary,binning=1
writelcfits,"mos1.fits",time,rate,error,barytime=barytime, reftime=reftime,header=header

print, "XMM MOS2"
readxmm,time,rate,error=error,/mos2, reftime=reftime,header=header,binning=1
readxmm,barytime,rate,/mos2, reftime=reftime,/bary,binning=1
writelcfits,"mos2.fits",time,rate,error,barytime=barytime, reftime=reftime,header=header


print, "XMM OM"
readxmm,time,rate,error=error,/om, reftime=reftime,header=header,binning=1
readxmm,barytime,rate,/om, reftime=reftime,/bary,binning=1
writelcfits,"om.fits",time,rate,error,barytime=barytime, reftime=reftime,header=header


;; Different RXTE Data:
print, "XTE"
dummy=readfits('/xtescratch/goehler/P60007/01-01-00/standard2f_34off_excl_ign0_top/standard2f_34off_excl_ign0_top.lc',$ 
               header,/silent)
readxte, time,rate,error=error, reftime=reftime,binning=1, propid="P60007"
readxte, barytime,rate, reftime=reftime,binning=1, propid="P60007",/bary
writelcfits,"rxte_p60007.fits",time,rate,error,barytime=barytime,reftime=reftime,header=header

;; geckeler
dummy=readfits('/xtescratch/goehler/P10025/01-01-00/standard2f_3off_excl_ign0_top/standard2f_3off_excl_ign0_top.lc',$ 
               header,/silent)
readxte, time,rate,error=error, reftime=reftime,binning=1, propid="P10025"
readxte, barytime,rate, reftime=reftime,binning=1, propid="P10025",/bary
writelcfits,"rxte_p10025.fits",time,rate,error,barytime=barytime,reftime=reftime,header=header


;; mukai:
dummy=readfits('/xtescratch/goehler/P30015/01-01-00/standard2f_excl_ign0_top/standard2f_excl_ign0_top.lc',$ 
               header,/silent)
readxte, time,rate,error=error, reftime=reftime,binning=1, propid="P30015"
readxte, barytime,rate, reftime=reftime,binning=1, propid="P30015",/bary
writelcfits,"rxte_p30015.fits",time,rate,error,barytime=barytime,reftime=reftime,header=header


dummy=readfits('/xmmscratch/goehler/RXJ1940-1025/CAHA-Jul-2001/Jul17/rxj1940_0005.fits',$ 
               header,/silent)
readcaha,time,rate,error=error,reftime=reftime
readcaha,barytime,rate,error=error,reftime=reftime,/bary
writelcfits,"caha.fits",time,rate,error,barytime=barytime,reftime=reftime,header=header
    

readhobart,time,rate,reftime=reftime
readhobart,barytime,rate,reftime=reftime,/bary
writelcfits,"hobart.fits",time,rate,reftime=reftime,barytime=barytime

;; SSO R Band:
dummy=readfits('/xmmscratch/rexer/rxj1940/R/ccd0001.fits',$ 
               header,/silent)
header=["RADECSYS= 'FK5     '           / Co-ordinate frame used for equinox",header]
readsso,time,rate,reftime=reftime
readsso,barytime,rate,reftime=reftime,/bary
writelcfits,"sso_r.fits",time,rate,barytime=barytime,reftime=reftime,header=header


;; SSO U Band:
dummy=readfits('/xmmscratch/rexer/rxj1940/newrawdata/V/ccd0001.fits',$ 
               header,/silent)
header=["RADECSYS= 'FK5     '           / Co-ordinate frame used for equinox",header]
readsso,time,rate,reftime=reftime,/uband
readsso,barytime,rate,reftime=reftime,/uband,/bary
writelcfits,"sso_v.fits",time,rate,barytime=barytime,reftime=reftime


end

