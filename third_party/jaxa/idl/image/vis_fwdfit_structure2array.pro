FUNCTION VIS_FWDFIT_STRUCTURE2ARRAY, srcstr, mapcenter
;
; Converts a vis_fwdfit source structure array to a source parameter vector suitable for use by amoeba_c
;
; 11-Nov-05 gh	Initial version
; 13-Nov-05	gh	Adapt to revised definition of srcstr.xyoffset
;  9-Dec-05 gh	Adapt to revised array and vector definitions
; 16-Jan-06 gh  Add provision for albedo source components.
; 30-Oct-13 A.M.Massone   Removed hsi dependencies 
;
;
srccodes 	= ['point   circle  ellipse loop     albedo ']
nsrc 		= N_ELEMENTS(srcstr)
srcparm 	= FLTARR(10,nsrc)
;
ip = WHERE(srcstr.srctype NE 'albedo', nprimary)
FOR n=0, nsrc-1 DO srcparm[0,n] = STRPOS(srccodes, srcstr[n].srctype)/8
IF nprimary EQ 0 THEN MESSAGE, 'ERROR:  No primary sources !'
ecmsr	    	= -0.5 * ALOG(1.-srcstr[ip].eccen^2)			; measure of eccentricity = ALOG(majoraxis/minoraxis)
srcparm[1,ip] 	= srcstr[ip].srcflux
srcparm[2,ip] 	= srcstr[ip].srcx - mapcenter[0]				;assumes all visibilities have same mapcenter
srcparm[3,ip] 	= srcstr[ip].srcy - mapcenter[1]
srcparm[4,ip] 	= srcstr[ip].srcfwhm
srcparm[5,ip] 	= ecmsr * COS(srcstr[ip].srcpa*!DTOR)			; 'Cartesian' representation avoids ill-defined srcpa
srcparm[6,ip] 	= ecmsr * SIN(srcstr[ip].srcpa*!DTOR)
srcparm[7,ip] 	= srcstr[ip].loop_angle
srcparm[8,*]	= srcstr[*].albedo_ratio
srcparm[9,*] 	= srcstr[*].srcheight
srcparm			= REFORM(srcparm, nsrc*10)
RETURN, srcparm
END
