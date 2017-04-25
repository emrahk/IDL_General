;+
; Project:
;	SDAC
;
; NAME: 
;	MAKE_GOES_RESP
;
; PURPOSE:
;	This procedure integrates the GOES transfer functions over a thermal solar
;	spectrum for 200 temperatures to set up an interpolation table.
;	Calculates the response in watts/m2 of the two GOES channels to the thermal
;	emission from a solar plasma of emission measure 1e49 cm-3 as a function
;	of the temperature in units of megaKelvin (1e6).
;
; CATEGORY:
;	GOES, SPECTROSCOPY, ANALYSIS
;
; CALLING SEQUENCE:
;	make_goes_resp, te6, goes_resp_49 [, goes8=goes8, goes9=goes9]
;
; CALLS:
;	MEWE_SPEC, GOES_TRANSFER, AVG, EDGE_PRODUCTS
;
; INPUTS:
;       none explicit, only through commons;
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;		te6 - Temperature vector in units of 1e6 Kelvin, 200 values
;		      from 1e6 to 97.7e6
;
;		goes_resp_49(2,200) - GOES flux in units of Watts/m2 for emission measure of 1.e49 cm-3
;				      Channel 0, 1-8 Angstroms
;				      Channel 1, .5-4 Angstroms

; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;
; 	GOES6- Use transfer function for GOES6
; 	GOES7- Use transfer function for GOES7
;	GOES8- Use transfer function for GOES8
;	GOES9- Use transfer function for GOES9
;	GOES10- Use transfer function for GOES10
;	SHORTWN - 2xN wavelength bins used with MEWE_SPEC, angstroms, short channel
;	LONGWN  - 2XN wavelength bins for long channel (1-8 Angstrom nominal response)
;	GSHORT  - Response for SHORTWN
;	GLONG   - Response for LONGWN
;	WRITE   - If set, response functions are written as an IDL save file (/xdr)
;	to SSWDB_GOES, intended for use on SDAC only.
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	This procedure is designed to be run to write the data file, goes_resp2.dat
;	only on SDAC at GSFC
;
; PROCEDURE:
;	This procedure integrates the GOES transfer functions over a thermal solar
;	spectrum for 200 temperatures to set up an interpolation table.
;
;Needed Files:
;	Stored lookup table stored in goes_resp2.dat
;	goes_resp2.dat will usually be in the same directory as goes_tem.pro
;	so will be found by loc_file.
;
; MODIFICATION HISTORY:
;	written 1991, RAS
; 	5-dec-95, jmm, changed from restoration of the file
;	'richard$data:mewe_spec.vms', to the use of MEWE_SPEC for the photon flux
;	Version 3, RAS/SDAC/GSFC/HSTX incorporate GOES8 and 9
;	Version 4, RAS/SDAC/GSFC/HSTX incorporate GOES6 and 7, 20-nov-1996
;	Version 5, RAS, use the edge integration capability of MEWE_SPEC directly
;	Version 6, RAS, 4-feb-1997, write the goes resp into a comprehensive structure
;	to increase speed when switching between responses of GOES satellites!
;		Concommitant changes implemented in GOES_TEM.PRO
;	Version 7, RAS, 5-feb-1997, using savegen and restgen for the saved response file
;		Concommitant changes implemented in MAKE_GOES_RESP.PRO
;	Version 8, added GOES10
;-
pro make_goes_resp, te6, goes_resp_49, goes8=goes8, goes9=goes9, goes6=goes6, goes7=goes7,goes10=goes10, $
	shortwn=shortwn, longwn=longwn, gshort=gshort, glong=glong, write=write	       	

if keyword_set(write) then begin
	filename = loc_file('goes_resp.genx',path='SSWDB_GOES')
	if filename ne '' then restgen,/inq, gresp, file= filename
	make_goes_resp, te6, gresp_mewe
	make_goes_resp, te6, gresp_mewe_6, /goes6
	make_goes_resp, te6, gresp_mewe_7, /goes7
	make_goes_resp, te6, gresp_mewe_8, /goes8
	make_goes_resp, te6, gresp_mewe_9, /goes9
	make_goes_resp, te6, gresp_mewe_10, /goes10
	g = {gresp, satellite:0L, resp:fltarr(2,200)}
	g = replicate(g, 6)
	g.satellite = [2L, 6, 7, 8, 9, 10]
	g.resp = [[[gresp_mewe]],[[gresp_mewe_6]],[[gresp_mewe_7]],$
		[[gresp_mewe_8]],[[gresp_mewe_9]],[[gresp_mewe_10]]]
	prstr, string(gresp.readme),file='readme.txt'
	xedit, 'readme.txt'
	stop
	readme = rd_ascii('readme.txt')
	gresp  ={goes_gen_resp, readme: byte(readme), te6:te6, goes:g}
	;we re-edit the readme by hand! RAS.
	savegen, file='goes_resp.genx', gresp
	return
endif	

   te6 = 10.0^(0.01*findgen(200))


   goes_transfer, gshort_trnfr = gshort_trnfr, $
     gshort_lambda = shortw, $
     glong_trnfr = glong_trnfr, glong_lambda = longw, $
     bar_gshort = bar_gshort, bar_glong = bar_glong, goes8=goes8, goes9=goes9,$
     goes6=goes6, goes7=goes7, goes10=goes10
   ;The GOES transfer functions are defined at the returned wavelengths (Angstrom)
   ;For MEWE_SPEC we need wavelengths which are 2xN for the integration

   nw = n_elements(longw)-1
   longwn  = [1.5*longw(0)-0.5*longw(1),$ 
               longw+0.5*(longw(1:*)-longw),1.5*longw(nw)-0.5*longw(nw-1)]
   edge_products, longwn, edges_2=longwn
   glong = interpol( glong_trnfr, longw, avg(longwn,0) ) >0.0

   nw = n_elements(shortw)-1
   shortwn  = [1.5*shortw(0)-0.5*shortw(1),$ 
               shortw+0.5*(shortw(1:*)-shortw),1.5*shortw(nw)-0.5*shortw(nw-1)]
   edge_products, shortwn, edges_2=shortwn
   gshort = interpol( gshort_trnfr, shortw, avg(shortwn,0) ) >0.0


   ster = 4.*!Pi*(1.5e13)^2.    ;area of sphere 1AU in radius

   goes_resp_49 = fltarr(2, 200)

;integrate the emission over the transfer functions for each channel
;compute for an em of 1e49 cm-3, mewe_emiss in units of 1e44 cm-3
;factor of 1e3 to compute from erg/s/cm2 to watts/m2

   goes_resp_49(0, *) = (mewe_spec(te6,longwn, /edges, /erg)#glong*1e5/ster/1e3 /bar_glong )(*) 
   goes_resp_49(1, *) = (mewe_spec(te6,shortwn,/edges, /erg)#gshort*1e5/ster/1e3 /bar_gshort )(*) 


end
