FUNCTION CCD_BCORR, tdt, ra, dec
;+
; NAME:
;	CCD_BCORR
;
; PURPOSE:
;	Calculate barycentric correction from reduced geocentric Julian
;	date (-2 400 000) (i.e. correct for extra light travel time between
;	Earth and CM of solar system).
;
; CATEGORY:
;	Astronomy.
;
; CALLING SEQUENCE:
;	baryc = CCD_BCORR( tdt, ra, dec )
;
; INPUTS
;	TDT    : Reduced Julian date (= JD - 2 400 000), scalar,
;	         MUST be double precision.
;	RA,DEC : Scalars giving right ascension and declination in DEGREES.
;
; OUTPUTS:
;	BARYC : Barycentric correction with BJD = GeocenJD + baryc.
;
; PROCEDURES CALLED:
;	NONE.
;
;-


On_error,2

If N_params() LT 3 then begin
   message,'Syntax -   barycc = CCD_BCORR( date, ra, dec)',/inf
   message,'NOTE - Ra and Dec must be in degrees',/inf
endif
    
zparcheck,'CCD_BCORR',tdt,1,[3,4,5],[0,1],'Reduced Julian Date'
;convert to non-reduced JD
tdt_n=tdt+2.4d6

setlog,'bary_corr','AIT321$DKA400:[GECKELER.IDL.PRO.FOR]BARY_CORR.EXE'

ra_h=ra/15.d0 ;BJD routines need RA in hours

baryc=0.0d0
a=CALL_EXTERNAL('bary_corr','bar_cen_init',ra_h,dec)
a=CALL_EXTERNAL('bary_corr','barycentric',tdt_n,baryc)

RETURN,baryc
END
