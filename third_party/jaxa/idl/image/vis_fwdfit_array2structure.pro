FUNCTION VIS_FWDFIT_ARRAY2STRUCTURE, srcparm, mapcenter
;
; Converts a vis_fwdfit source parameter vector to a source structure array.
; 	This is the inverse task to vis_fwdfit_structure2array
;
;  9-Nov-05 gh	Initial version (ghurford@ssl.berkeley.edu)
; 13-Nov-05 gh	Adapt to srctype tag in source component structure
;  9-Dec-05 gh	Adapt to revised srcstr and srcparm formats
; 13-Jan-09, Kim.  added reform to expression for srcpa
; 14-Sep-09, Kim. fixed bug in srcpa line (previously second arg was srcparm, not parmaray)
; 30-Oct-13 A.M.Massone   Removed hsi dependencies
;
srccode 			= ['point', 'circle', 'ellipse', 'loop', 'albedo']
nsrc 				= N_ELEMENTS(srcparm) / 10
parmaray			= REFORM(srcparm, 10, nsrc)
srcstr 				= {vis_src_structure}
IF nsrc GT 1 THEN srcstr = REPLICATE(srcstr, nsrc)
;
srcstr.srctype 		    = srccode[REFORM(parmaray[0,*])]
primary                 = WHERE(srcstr.srctype NE 'albedo', nprimary)
srcstr.srcflux 		    = REFORM(parmaray[1,*])
srcstr[primary].srcx	= REFORM(parmaray[2,primary]) + mapcenter[0]
srcstr[primary].srcy	= REFORM(parmaray[3,primary]) + mapcenter[1]
srcstr.srcfwhm		    = REFORM(parmaray[4,*])
srcstr.loop_angle 	    = REFORM(parmaray[7,*])
srcstr.albedo_ratio     = REFORM(parmaray[8,*])
srcstr.srcheight	    = REFORM(parmaray[9,*])
ecmsr				    = REFORM(SQRT(parmaray[5,*]^2 + parmaray[6,*]^2))					; >=0
srcstr.eccen 		    = SQRT(1 - EXP(-2*ecmsr))
ok					    = WHERE(ecmsr GT 0, nok)
IF nok GT 0 THEN srcstr[ok].srcpa = reform(ATAN(parmaray[6,ok], parmaray[5,ok]) * !RADEG)
RETURN, srcstr
END

