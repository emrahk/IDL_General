PRO CCD_TBDF, file, gjd , SHIFT=shift
;
;+
; NAME:
;	CCD_TBDF
;
; PURPOSE:   
;	Extract date and time from a BDF image header and return
;	GeocenJD of CENTER of exposure.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_TBDF, file, [ gjd , SHIFT=shift ]
;
; INPUTS:
;	FILE : Name of BDF file.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	SHIFT : Add shift [hours] to GeocenJD to correct for time zones.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	GJD : GeocenJD of center of exposure.
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


on_error,2                      ;Return to caller if an error occurs

if not EXIST(file) then message,'File name missing'

unit=8
openr,8,file
mid_rd_dirdsc,8,'date',date
mid_rd_dirdsc,8,'time',time
mid_rd_dirdsc,8,'exposure',exposure
close,8

date=str_sep(strtrim(date,2),'/')
month=long(date(0))
day=long(date(1))
year=long(date(2))+1900

time=str_sep(strtrim(time,2),':')
hour=long(time(0))
min=long(time(1))

JULDATE,[year,month,day,hour,min],gjd

;add seconds plus 0.5*exposure time to obtain center of exposure
gjd=gjd+(double(time(2))+double(exposure)/2.0d0)/86400.0d0

if EXIST(shift) then gjd=gjd+double(shift)/24.0d0

RETURN
END
