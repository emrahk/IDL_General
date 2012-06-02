PRO PLOT_PHASE, time,rate,period,nbins=nbins,error=error,$
     xtitle=xtitle,ytitle=ytitle,title=title, ynozero=ynozero,npts=npts, $
     yrange=yrange
; period=12113
;+
; NAME:
;       plot_phase
;
;
;
; PURPOSE:
;       bin and plot phase of lightcurve
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;       Fri May 11 15:55:59 2001, Eckart Goehler
;       <goehler@aithp3.ait.physik.uni-tuebingen.de>
;
;		
;
;-

; set optional parameter:
IF n_elements(nbins) EQ 0 THEN nbins=20

IF n_elements(xtitle) EQ 0 THEN xtitle='Phase time [sec]'
IF n_elements(ytitle) EQ 0 THEN ytitle='Pulse height'
IF n_elements(title) EQ 0 THEN title='Pulse Profile, Period:'+string(period)+'sec'
IF n_elements(ynozero) EQ 0 THEN ynozero=0



; bin phase: 
pfold,time,rate,profile,period=period,nbins=nbins, raterr=error,$
      proferr=proferr, phbin=phbin,/chatty,npts=npts

; generate x-axis:
phase=indgen(nbins*2,/float)*period/nbins
; doubel profile:
profile=[profile,profile]
proferr=[proferr,proferr]

; check y-range:
IF ynozero EQ 0 THEN ymin = 0 ELSE    ymin=min(profile)
ymax=max(profile)

IF n_elements(yrange) EQ 0 THEN yrange=[ymin,ymax] 




plot, phase,profile,xtitle=xtitle,ytitle=ytitle,ynozero=ynozero, $
      psym=10,xtickformat='(F10.1)',yrange=yrange,title=title

; display error if desired:
IF n_elements(error) NE 0 THEN jwoploterr,phase,profile,proferr,psym=10


END


