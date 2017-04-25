
PRO read_line_fits, fname, struc, shift=shift, stis=stis, vcheck=vcheck, eis=eis

;+
; NAME
;
;    READ_LINE_FITS
;
; EXPLANATION
;
;    The routine spec_gauss_widget outputs Gaussian line fits in a particular
;    format. READ_LINE_FITS reads these files and optionally performs line
;    identifications using CHIANTI.
;
;    An earlier version of spec_gauss_widget did not print parameters
;    for the background fit. For this reason you will see two options
;    below, one for reading the background parameters fits, and one
;    that doesn't. 
;
; INPUTS
;
;    FNAME  The name of the file output by SPEC_GAUSS_WIDGET.
;
; OUTPUTS
;
;    STRUC  An IDL structure containing the line fits and identified
;           transitions. The tags are:
;            .wvl  Wavelength
;            .swvl 1-sigma error on wavelength
;            .peak Line amplitude.
;            .speak 1-sigma error on amplitude
;            .width FWHM of Gaussian
;            .swidth 1-sigma error on FWHM
;            .int   Intensity (or flux) of emission line
;            .sint  1-sigma error on intensity
;            .x0    The fitted background has a value of y0 at
;                   wavelength x0.  
;            .y0    The fitted background has a value of y0 at
;                   wavelength x0.  
;            .x1    The fitted background has a value of y1 at
;                   wavelength x1.  
;            .y1    The fitted background has a value of y1 at
;                   wavelength x1.  
;            .sigy0 1-sigma error on y0
;            .sigy1 1-sigma error on y1
;            .ion   String to which an ion name can be assigned.
;            .i     Integer to which the lower level index of the
;                   identified transition can be assigned.
;            .j     Integer to which the upper level index of the
;                   identified transition can be assigned.
;            .trans String to which transition information can be
;                   assigned. 
;            .shift Velocity shift (km/s) of measured line relative to
;                   identified transition.
;            .gf    gf value of identified transition.
;            .aval  A-value of identified transition.
;
;           Note that a number of the tags will only be populated if
;           the transition is identified.
;
; KEYWORDS
;
;    STIS   Use the STIS line ID file for performing line
;           identifications.
;
;    EIS    Use the Hinode/EIS line ID file for performing line
;           identifications. 
;
; OPTIONAL INPUTS
;
;    SHIFT  The radial velocity of the star to apply when performing line
;           identifications.
;
;    VCHECK A line is identified if it is within +/- VCHECK km/s of the
;           lab. wavelength of the line. Default is 15 km/s.
;
; CALLS
;
;    READ_LINE_IDS
;
; HISTORY
;
;    Ver. 1, 27-Oct-2008, Peter Young
;    Ver. 2, 22-Apr-2009, Peter Young
;       Corrected the reading of the background parameters.
;    Ver. 3, 7-Aug-2009, Peter Young
;       Made numbers in output structure double precision; updated
;       header.
;-

IF n_params() LT 2 THEN BEGIN
  print,'Use:  IDL> read_line_fits, fname, str [, shift=, /stis, /eis, vcheck= ]'
  return
ENDIF 

list=file_search(fname)
IF list[0] EQ '' THEN BEGIN
  print,'% READ_LINE_FITS: the file '+fname+' does not exist. Returning...'
  return
ENDIF

IF n_elements(vcheck) EQ 0 THEN vcheck=15.0

IF keyword_set(stis) THEN line_id=getenv('STIS_LINE_IDS')
IF keyword_set(eis) THEN line_id=getenv('SSW')+'/hinode/eis/idl/atest/pyoung/eis_line_ids.txt'

str={wvl: 0d0, swvl: 0d0, peak: 0d0, speak: 0d0, width: 0d0, swidth: 0d0, $
     int: 0d0, sint: 0d0, ion: '', i: 0, j: 0, trans: '', shift: 0d0, $
     gf: 0d0, aval: 0d0, $
     x0: 0d0, x1: 0d0, y0: 0d0, y1: 0d0, sigy0: 0d0, sigy1: 0d0}
empty_str=str
struc=0

;
; Before Oct 2008, spec_gauss_widget did not print out the background
; fit parameters, so there are two possibilities for the format of the
; line fit parameters which are given below.
;
form1='(2f12.4,2e12.3,2f12.4,2e12.4)'
form2='(2f12.4,2e12.3,2f12.4,2e12.4,2f12.4,4e12.4)'

openr,lin,fname,/get_lun

str1=''
WHILE eof(lin) NE 1 DO BEGIN
  readf,lin,str1
  str=empty_str
  IF strlen(str1) LE 96 THEN BEGIN
   ;
   ; This is the pre-Oct 2008 format (no background params).
   ;
    reads,str1,format=form1,l,sl,p,sp,w,sw,t,st
  ENDIF ELSE BEGIN
   ;
   ; This is the post-Oct 2008 format (with background params).
   ;
    reads,str1,format=form2,l,sl,p,sp,w,sw,t,st,x0,x1,y0,sigy0,y1,sigy1
   ;
    str.x0=x0
    str.x1=x1
    str.y0=y0
    str.y1=y1
    str.sigy0=sigy0
    str.sigy1=sigy1
  ENDELSE
  str.wvl=l
  str.swvl=sl
  str.peak=p
  str.speak=sp
  str.width=w
  str.swidth=sw
  str.int=t
  str.sint=st
 ;
  IF n_elements(line_id) NE 0 THEN BEGIN
    range=v2lamb(vcheck,l)
    read_line_ids,line_id,l,out,shift=shift,range=range
    IF n_tags(out) NE 0 THEN BEGIN
      str.ion=trim(out[0].name)
      str.gf=out[0].gf
      str.aval=out[0].aval
      str.shift=lamb2v(l-out[0].wvl,out[0].wvl)
      str.trans=out[0].trans
      str.i=out[0].lvl1
      str.j=out[0].lvl2
    ENDIF
  ENDIF
 ;
  IF n_tags(struc) EQ 0 THEN struc=str ELSE struc=[struc,str]
ENDWHILE

free_lun,lin

END
