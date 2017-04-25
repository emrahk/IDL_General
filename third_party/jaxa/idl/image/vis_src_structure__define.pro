PRO vis_src_structure__define
;
; Defines a structure that defines one component of a source structure used by vis_fwdfit and related modules.
;
; {vis_source_structure} returns the following structure
;
; 9-Dec-2005 	Initial version (ghurford@ssl.berkeley.edu)
; 30-Oct-13 A.M.Massone   Removed hsi dependencies 
;
dummy = {vis_src_structure, 	$
			srctype:  		' ', 			$		; Label indicating source type
			srcflux: 		 0., 			$		; Semi-calibrated flux (ph/cm2/s)
			srcx: 			 0., 			$		; X-offset (+W) relative to sun center (arcsec)
			srcy: 			 0., 			$		; Y-offset (+N) relative to sun center (arcsec)
			srcfwhm: 		 0., 			$		; Source FWHM diameter (arcsec)
			eccen: 			 0., 			$		; Eccentricity of elliptical source
			srcpa: 			 0., 			$		; Position angle of long axis (degrees E of N)
			loop_angle: 	 0., 			$		; Angle subtended by loop, as seen from its center of curvature (deg)
			albedo_ratio: 	 0., 			$		; Ratio of albedo to primary source flux
			srcheight: 		 0.  			}		; Height of source above 'albedo' surface.
RETURN
END
