PRO comp_orbit, MJD, POS, VEL, file=file
;+
; NAME: 
;          comp_orbit
;
;
;
; PURPOSE: 
;         Computes orbital information for the XMM satellite for given 
;         date and orbit file
;
;
;
; CATEGORY:
;         XMM
;
;
;
; CALLING SEQUENCE:
;         comp_orbit, MJD, POS, VEL, file=file
;
;
;
; INPUTS:
;         MJD   : Float value representing the date for which orbit
;         information is to be collected. Value is expressed in the
;         Modified Julian Date (MJD 2000, i.e. the date 0.0 refers to
;         1st January 2000 at 0:00:00)
;
;
; OPTIONAL INPUTS:
;         file  : Orbit input file string (ASCII, refer XMM-MOC-ICD-0021-OAD)
;                 Default: orbita
;                 May be fetched from http://xmm.vilspa.esa.es/~xmmdoc/orbit/.
;
;
;
; KEYWORD PARAMETERS:
;         none
;
;
; OUTPUTS:
;         POS  : 3-dim vector containing X,Y,Z position of XMM for
;                given date. Unit are km in the Kepler reference
;                orbit, coordinate system is the Inertial Mean
;                Geocentric Equatorial System of year J2000.0, x-axis
;                towards mean vernal equinox, x-y plane conciding with
;                mean equatorial plane, z-axis toward north. 
;         VEL  : 3-dim vector containing X,Y,Z components of velocity
;                for XMM at given date. Unit are km in the Kepler reference
;                orbit, coordinate system is the Inertial Mean
;                Geocentric Equatorial System of year J2000.0, x-axis
;                towards mean vernal equinox, x-y plane conciding with
;                mean equatorial plane, z-axis toward north. 
;
;
;
; SIDE EFFECTS:
;         not known
;
;
; RESTRICTIONS:
;         each time the procedure is called the file is scanned - not
;         to used for often access.
;                                                                
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;        Compute position and velocity for 2001-12-28,15:00,
;        orbit file is 'new_orbit':
;
;        comp_orbit, 362.62500,POS,VEL,file='new_orbit'
;
;
; MODIFICATION HISTORY:
;        $Log: comp_orbit.pro,v $
;        Revision 1.1  2002/03/07 13:54:22  goehler
;        Initial version to make private version public.
;
;-




PREREC=''
GENTIM=''
SRTTIM=''
ENDTIM=''

INPUTSTR=''

POS=fltarr(3)
VEL=fltarr(3)

POS=0
VEL=0

; set default file 'orbita'
IF (n_elements(file) EQ 0) THEN file='orbita'

; start reading:
openr, 2, file


; read records:
FOR i=1,15000 DO BEGIN

IF INPUTSTR EQ '' THEN readf,2,INPUTSTR

reads,INPUTSTR,     $
      SCID,  $
      PREREC,$
      GENTIM,$
      SRTTIM,$
      ENDTIM,$
      format='(I3,2X,A1,2X,A20,2X,A20,2X,A20)'
;print,SCID


readf,2,   $
      NREC,$
      DAYBEG,$
      DAYEND,$
      EPOCH,$
      ORBIN,$
      SMAXIS,$
      OMOTIN,$
      format='(I3,F12.6,F12.6,F15.9,F11.3,F13.5,F13.5)'
;print,NREC
readf,2,   $
      NREC,$
      XPOS,$
      YPOS,$
      ZPOS,$
      XVEL,$
      YVEL,$
      ZVEL,$
      RDIST,$
      format='(I3,3F11.3,3F11.7,3F11.3)'
;print,NREC



; read polynome:

; read record line
readf,2,INPUTSTR

;extract record identifier
reads,INPUTSTR,NREC,format='(I3)'
IF  NREC NE 60 THEN BEGIN 

REPEAT BEGIN
reads,INPUTSTR,   $
      NREC,   $
      XPOLPOS,$
      YPOLPOS,$
      ZPOLPOS,$
      XPOLVEL,$
      YPOLVEL,$
      ZPOLVEL,$
      format='(I3,3F11.3,3F11.7)'

; record identifier: 13 -> 2 polynomes
IF NREC EQ 13 THEN J=2
; record identifier: 14 -> 3 polynomes
IF NREC EQ 14 THEN J=3
; record identifier: 15 -> 4 polynomes
IF NREC EQ 15 THEN J=4
; record identifier: 16 -> 5 polynomes
IF NREC EQ 16 THEN J=5
J=J-1

;print,NREC,I

; read next record string:
readf,2,INPUTSTR

ENDREP UNTIL (J EQ 0) 
ENDIF ; any polynoms

;print,I,XPOS,YPOS,ZPOS
;POS[i]=[XPOS,YPOS,ZPOS]
;VEL[i]=[XVEL,YVEL,ZVEL]
;STIME[i]=DAYBEG

; if date found -> put to result
IF (DAYBEG LE MJD) AND (DAYEND GE MJD) THEN BEGIN
    POS=[XPOS,YPOS,ZPOS]
    VEL=[XVEL,YVEL,ZVEL]
ENDIF 


ENDFOR
close, 2

END

