;; convert2dat - reads data in and converts it to 
;; ascii data
;; eg, 11-03-2003


;; setup:
reftime = 50000

bary=1
helio=0

;; default time string:
timestr = "JD-"+strtrim(string(reftime))

IF keyword_set(helio) THEN timestr = "HJD-"+strtrim(string(reftime),2)
IF keyword_set(bary)  THEN timestr = "BJD-"+strtrim(string(reftime),2)

;; read XMM data:
print, "XMM"
readxmm,time,rate,error=error,/mos1,helio=helio, bary=bary, reftime=reftime
writelcdata,"mos1.dat",time,rate,error,title="XMM mos1",tdescr=timestr

readxmm,time,rate,error=error,/mos2,helio=helio,bary=bary, reftime=reftime
writelcdata,"mos2.dat",time,rate,error,title="XMM mos2",tdescr=timestr

readxmm,time,rate,error=error,reftime=reftime,/om,helio=helio,bary=bary,binning=1
writelcdata,"om.dat",time,rate,error,title="XMM OM",tdescr=timestr

;; Different RXTE Data:
readxte, time,rate,error=error, reftime=reftime,helio=helio,bary=bary,binning=2, propid="P60007"
writelcdata,"rxte_p60007.dat",time,rate,error,title="XTE DATA, P60007",tdescr=timestr

;; geckeler
readxte, time,rate,error=error, reftime=reftime,helio=helio,bary=bary,binning=2, propid="P10025"
writelcdata,"rxte_p10025.dat",time,rate,error,title="XTE DATA, P10025",tdescr=timestr

;; mukai:
readxte, time,rate,error=error, reftime=reftime,helio=1,binning=2, propid="P30015"
writelcdata,"rxte_p30015.dat",time,rate,error,title="XTE DATA, P30015",tdescr=timestr

readcaha,time,rate,error=error,reftime=reftime,helio=helio, bary=bary
writelcdata,"caha.dat",time,rate,error,title="CAHA Jul 2001",tdescr=timestr
    
readhobart,time,rate,reftime=reftime,helio=helio, bary=bary
writelcdata,"hobart.dat",time,rate,title="Hobart",tdescr=timestr

readsso,time,rate,reftime=reftime,helio=helio, bary=bary
writelcdata,"sso_r.dat",time,rate,title="SSO 40''",tdescr=timestr

readsso,time,rate,reftime=reftime,helio=helio, bary=bary,/uband
writelcdata,"sso_v.dat",time,rate,title="SSO 40''",tdescr=timestr

readdips,time,rate,reftime=reftime,helio=helio,bary=bary
writelcdata,"refdips.dat",time,rate,title="Expected dip times",tdescr=timestr

readtroughs,time,rate,reftime=reftime,helio=helio,bary=bary
writelcdata,"reftroughs.dat",time,rate,title="Expected trough times",$
            tdescr=timestr

end

