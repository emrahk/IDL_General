; readxmm.pro -reads xmm data for RX J1940.1-1025
; $Log: readxmm.pro,v $
; Revision 1.2  2003/04/03 07:57:43  goehler
; update for header reading
;
; Revision 1.1  2003/03/31 09:19:41  goehler
;  read rxj1940.1-1025 functions added to cvs
;


pro readxmm, time,rate,error=error, mos1=mos1,mos2=mos2,om=om, reftime=reftime,$
             helio=helio, bary=bary,binning=binning, header=header
; readxmm - reads lightcurve for xmm with given 
;           time,rate (and error)
;           instrument may be selected. Default mos1.
;           [mos_common reads common (merged event) lightcurve]
;           time is in mjd less reference time
;           binning for OM only
;           still no background subtraction
;          

; ============================= GENERAL INFO =================================:

; path of xmm observation:
base_path="/xmmarray/xmmscratch/goehler/RXJ1940-1025/XMM"

; reference time (mjd)
if n_elements(reftime) eq 0 then reftime=52191

; ============================= MOS INFO
; ====================================:

;; select bary center corrected data:
IF keyword_set(bary) THEN baryext = '_bary' else baryext=""


mos1_input=base_path+"/mos1/src_rate"+baryext+".fits"
mos2_input=base_path+"/mos2/src_rate"+baryext+".fits"
;mos_common_input=base_path+"/common/src_rate.fits"

; background rates:
;mos1_bg=base_path+"/mos1/bg_rate.fits"
;mos2_bg=base_path+"/mos2/bg_rate.fits"



;; ============================= OM INFO ===================================== 

; OM input path:
om_input=base_path+"/om/ODF/"

; exposures to read:
exposures=[$
            '006', $
            '007', $
            '008', $
            '401', $
            '402', $
            '403', $
            '404', $
            '405', $
            '406', $
            '407', $
            '408', $
            '409', $
            '410',  $
            '411',  $
            '412'  $
          ]

; default binning to be used:
if n_elements(binning) eq 0 then binning=8

;; =================================================================

; set default: MOS 1
input=mos1_input
;bg_input=mos1_bg
;
; MOS 2
if keyword_set(mos2) then input=mos2_input; & bg_input=mos2_bg


;; ===================== MOS ====================
IF NOT keyword_set(om) THEN BEGIN 

; read lightcurves:
readlc,time,rate,input,/counts

;; read header information:
dummy=readfits(input,header,/silent)
;readlc,bgtime,bgrate,bg_input,/counts

; compute time:

; convert to MJD, subtract reference time:
CCD_FHRD,input,'MJDREF', refxmm,extension=1
time=time/86400.D0     + refxmm
;bgtime=bgtime/86400.D0 + refxmm

; shift to helio center if necessary:
if keyword_set(helio) then begin
    time=rxj_helio(time,/mjd)    
;    bgtime=rxj_helio(bgtime,/mjd)

    print, "Helio center correction!"
endif

time=time-reftime
;bgtime=bgtime-reftime


; compute error:
error=sqrt(rate)


;; ===================== OM ====================    
endif ELSE BEGIN    

lc_om, om_input,time,rate,error,/mjd,exposures=exposures,binning=binning,header=header

if keyword_set(helio) OR keyword_set(bary) then begin
    time=rxj_helio(time,/mjd)
    print, "Helio center correction!"
endif

time=time-reftime

ENDELSE

end



