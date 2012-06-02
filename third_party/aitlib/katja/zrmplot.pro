PRO zrmplot,nameorg,pathfin, $
            mostquan=mostquan,meanquan=meanquan,sigquan=sigquan, $
            nseg=inpnseg,bt=inpbt,quantities=quantities, $
            plotbin=inpplotbin,histmax=inphistmax, $
            itemax=inpitemax,label=label, $
            color=color,postscript=postscript,chatty=chatty
   
   
;; helpful parameters
nseg    = long(inpnseg) 
bt      = double(inpbt)   
plotbin = double(inpplotbin)
histmax = double(inphistmax)
itemax  = long(inpitemax)
nquan   = n_elements(quantities)


;; prepare plot
IF (postscript EQ 1) THEN BEGIN
    namefin=pathfin+'.ps'
ENDIF ELSE BEGIN 
    namefin=pathfin+'.eps'
ENDELSE  


;; read Zuramo parameters 
openr,unit,nameorg,/get_lun
arr=dblarr(nquan+1,nseg)
readf,unit,arr
free_lun,unit


;; check, if the zuramo model used less than the allowed number of
;; iterations
;; if the number of iterations is maximal, remove the fit results from
;; the sample 
ndxa=where(arr(6,*) GE itemax,count)
nseg=nseg-count
IF (keyword_set(chatty)) THEN BEGIN 
    print,'zrmplot: number of fits with the max. No. of iterations:',count    
ENDIF 
ndxb=where(arr(6,*) LT itemax)
arr=arr(*,ndxb)


;; plot to namefin
open_print,namefin,/color,postscript=postscript
!p.multi=[0,4,2]
loadct,39

brr=dblarr(nquan,nseg)
brr(0,*)=arr(0,*)
brr(1,*)=arr(2,*)
brr(2,*)=arr(3,*)
brr(3,*)=arr(4,*)
brr(4,*)=arr(5,*)
brr(5,*)=arr(6,*)

mostquan=dblarr(nquan)
meanquan=dblarr(nquan)
sigquan=dblarr(nquan)

FOR i=0,nquan-1 DO BEGIN
    
    quan=brr(i,*)
    
    IF (quantities(i) EQ 'TAU [sec]') THEN BEGIN 
        quan(*)=quan(*)*bt  
    ENDIF 
    
    IF (histmax(i) LE max(quan)) THEN BEGIN  
        message,'zrmplot: maximum histogram value (=histmax) is too small'
    ENDIF 
    
    ;; calculate histogram
    value=(findgen(histmax(i)/plotbin(i))*plotbin(i))+plotbin(i)/2.
    prob=histogram(quan,binsize=plotbin(i),min=0D0,max=histmax(i))
    
    ;; plot histogram
    low=min(quan)-2*plotbin(i)
    high=max(quan)+2*plotbin(i)
    plot,value,prob,xrange=[low,high],yrange=[0.,1.05*max(prob)], $
      xstyle=1,ystyle=5,psym=10
    
    ;; determin important distribution parameters    
    tit  =  quantities(i) 
    avg  =  mean(quan)
    sig  =  sqrt(variance(quan))
    med  =  median(quan)
    ndx1 =  where(prob EQ max(prob))
    most =  value(ndx1(0))
    bin  =  value(1)-value(0)
    mxx  =  max(quan)
    mii  =  min(quan)
    
    ;; plot vertical lines
    oplot,[avg,avg],[0.,1.05*max(prob)],linestyle=2
    oplot,[avg-sig,avg-sig],[0.,1.05*max(prob)],linestyle=1
    oplot,[avg+sig,avg+sig],[0.,1.05*max(prob)],linestyle=1
    oplot,[med,med],[0.,0.5*max(prob)],linestyle=3
    
    ;; plot important distribution parameters
    xyouts,0.96*(high-low)+low,1.00*max(prob),tit,alignment=1,size=0.50
    xyouts,0.96*(high-low)+low,0.95*max(prob), $
      'most prob.='+string(format='(E9.2)',most),alignment=1,size=0.50
    xyouts,0.96*(high-low)+low,0.90*max(prob), $
      'median='+string(format='(E9.2)',med),alignment=1,size=0.50     
    xyouts,0.96*(high-low)+low,0.85*max(prob), $
      'mean='+string(format='(E9.2)',avg),alignment=1,size=0.50
    xyouts,0.96*(high-low)+low,0.80*max(prob), $
      'sigma='+string(format='(E9.2)',sig),alignment=1,size=0.50    
    xyouts,0.96*(high-low)+low,0.75*max(prob), $
      'x bin width='+string(format='(E9.2)',bin),alignment=1,size=0.50
    xyouts,0.96*(high-low)+low,0.70*max(prob), $
      'x max='+string(format='(E9.2)',mxx),alignment=1,size=0.50
    xyouts,0.96*(high-low)+low,0.65*max(prob), $
      'x min='+string(format='(E9.2)',mii),alignment=1,size=0.50
    
    ;; plot yaxis left: number of fits
    ;; plot yaxis right: probabilily density
    axis,yaxis=0,yrange=[0.,1.05*max(prob)],ystyle=1
    axis,yaxis=1,yrange=[0.,1.05*max(prob)/double(nseg)/plotbin(i)],ystyle=1
    
    ;; save important distribution parameters
    mostquan(i)=most
    meanquan(i)=avg
    sigquan(i)=sig
    
ENDFOR


;; plot label infos
IF (n_elements(label(0)) NE 0) THEN BEGIN
    xyouts,0.99,0.11,label(0),/normal,alignment=1,size=0.70
ENDIF
IF (n_elements(label(1)) NE 0) THEN BEGIN
    xyouts,0.99,0.09,label(1),/normal,alignment=1,size=0.70
ENDIF
IF (n_elements(label(2)) NE 0) THEN BEGIN
    xyouts,0.99,0.07,label(2),/normal,alignment=1,size=0.70
ENDIF
IF (n_elements(label(3)) NE 0) THEN BEGIN 
    xyouts,0.99,0.05,label(3),/normal,alignment=1,size=0.70
ENDIF
IF (n_elements(label(4)) NE 0) THEN BEGIN
    xyouts,0.99,0.03,label(4),/normal,alignment=1,size=0.70
ENDIF

close_print


END 









