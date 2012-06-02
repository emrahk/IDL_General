PRO CCD_HELIO, IN=in, OUT=out, COORD=coord
;
;+
; NAME:
;	CCD_HELIO
;
; PURPOSE:   
;	Apply heliocentric correction to RMS file IN from CCD_RMS
;	and save as OUT.
;	Sets variable helioc=1 before saving of data.
;	ACCURACY : Approx. +- 8 sec.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_HELIO, [ IN=in, OUT=out, COORD=coord ]
;
; INPUTS:
;	NONE.
;
; OPTIONAL INPUTS:
;       NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;       IN    : Name of IDL save file with lightcurve data
;               defaulted to interactive loading of '*.RMS'.
;       OUT   : Name of IDL save of HC lightcurve data,
;               defaulted to IN.
;	CORRD : Name of file with source coordinates.
;               defaulted to interactive loading of '*.CRD'.
;		Structure: Arbitrary number of comment lines
;		beginning with %.
;		ONE Line with :
;		RA and Dec as e.g. '17 00 45.2 25 4 32.4' (both 1950.0).
;	
; OUTPUTS:
;	IDL save containing HC lightcurve data.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


;on_error,2                      ;Return to caller if an error occurs

if not EXIST(in) then $
in=pickfile(title='Input Data File',$
              file='ccd.rms',filter='*.rms')

message,'Input data file        : '+in,/inf

if not EXIST(out) then begin
   a=STR_SEP(in,';')
   out=a(0)
endif

message,'Output data file       : '+out,/inf

if not EXIST(coord) then $
coord=pickfile(title='Source Coordinate File',filter='*.crd')

message,'Source coordinate file : '+coord,/inf

CCD_RASC,coord,co

;convert string to ra & dec in DEGREES.
STRINGAD,co(0),ra,dec

RESTORE,in,/verbose

time=time+CCD_HCORR(time,ra,dec)

helioc=1

SAVE,/xdr,rad,f,meanf,rms,ref,sname,time,helioc,filename=out,/verbose

RETURN
END
