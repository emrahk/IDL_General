PRO RMC_OMPLOT,omegat,messung,_extra=extra
;+
; NAME: rmc_omplot
;
;
;
; PURPOSE: plotting the datapoints of messung
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: RMC_OMPLOT,omegat,messung,_extra=extra
;
;
;
; INPUTS: omegat: position of rmc in degrees
;         messung: measured data points
;         
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;         _extra: other keywords are possible but not necessary
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
; $Log: rmc_omplot.pro,v $
; Revision 1.2  2002/05/21 12:33:14  slawo
; Add comments
;
;-
   
   

   plot,omegat,messung,xtitle=textoidl('\omega t [deg]'), $
     ytitle=textoidl('Count Rate [counts sec^{-1}]'),xstyle=1, $
     xticks=4,xminor=9,xrange=[0,360],_extra=extra
  
END
