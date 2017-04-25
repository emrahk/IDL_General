pro energy_res_test, matrix, eout
eres = obj_new('energy_res')
matrix = eres->getdata()
eout = eres->Get(/eout)
end


function energy_res_control
var = {energy_res_control}
var.ein = ptr_new(get_edges(/edges_2, findgen(101)+3.5))
var.eout = ptr_new(*var.ein)

var.e_vs_fwhm = ptr_new(findgen(100)+1.)
var.fwhm_vs_e = ptr_new(0.8 + fltarr(100))
var.sig_lim   = 6.0


return, var
end

pro energy_res_control__define

d = {energy_res_control, $
	ein: ptr_new(), $    ;Energy input edges
	eout: ptr_new(),$	 ;Energy output edges
	e_vs_fwhm: ptr_new(), $ ;energy for fwhm array
	fwhm_vs_e: ptr_new(), $ ;fwhm as a function of E_VS_FWHM.
	sig_lim: 0.0 	}  ;Integration limit in sigma

end

pro energy_res_info__define

d = {energy_res_info, $
	info_state: ptr_new(0) }

end

;---------------------------------------------------------------------------
; Document name: energy_res__define.pro
; Created by:    Andre Csillaghy, March 4, 1999
;
; Last Modified: Mon Apr 23 14:19:32 2001 (csillag@soleil)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;
;
; NAME:
;       energy_res class
;
; PURPOSE:
;
;       Compute pulse spread response matrix
;
; CATEGORY:
;       ssw/gen/idl/util
;
; CONTRUCTION:
;       o = Obj_New( 'energy_res' )
;       or
;       o = energy_res( )
;
; INPUT (CONTROL) PARAMETERS:
;       Defined in {energy_res_control}
;
;		ein: ptr_new(), $    ;Energy input edges
;		For the psm matrix we use the same ein and eout. The pulse shape is along the output rows
;		and is indifferent to the channel of ein, so really disregard ein
;		In the end the pulse broadened matrix is obtained by psm # pls_height_matrix
;		where the rows and columns of psm have the same bins as the output bins of pls_height_matrix

;		eout: ptr_new(),$	 ;Energy output edges
;		e_vs_fwhm: ptr_new(), $ ;energy for fwhm array
;		fwhm_vs_e: ptr_new(), $ ;fwhm as a function of E_VS_FWHM.
;		sig_lim: 0.0 	}  ;Integration limit in sigma
; DISCUSSION
;		While designed to provide a module for detector resolution broadening it can
;		be used more generally.  This creates a matrix with a Gaussian response
;		for each output channel.  The FWHM can obey any functional form desired as
;		it can be given explicitly by the E_VS_FWHM and FWHM_VS_E control parameters
; SEE ALSO:
;       energy_res_control__define
;       energy_res_control
;       energy_res_info__define
;		Requires FRAMEWORK
;
; HISTORY:
;       6-jul-2006, richard.schwartz@gsfc.nasa.gov ; Based on pulse_spread
;		12-feb-2014, richard.schwartz@nasa.gov - came to understand the binning of the psm
;		For the psm matrix we use the same ein and eout. The pulse shape is along the output rows
;		and is indifferent to the channel of ein, so really disregard ein
;		In the end the pulse broadened matrix is obtained by psm # pls_height_matrix
;		where the rows and columns of psm have the same bins as the output bins of pls_height_matrix
;
;
;
;-
;


;--------------------------------------------------------------------

FUNCTION energy_res::INIT, $
	;SOURCE = source, $
	_EXTRA=_extra



RET=self->Framework::INIT( CONTROL = energy_res_control(), $
                           INFO={energy_res_info}, $
                           ;SOURCE=source, $
                           _EXTRA=_extra )


RETURN, RET

END



;--------------------------------------------------------------------


PRO energy_res::Process, $

             _EXTRA=_extra



ein  = Self->Get(/ein) ;2 x N
;For the psm matrix we use the same ein and eout. The pulse shape is along the output rows
;and is indifferent to the channel of ein
eout = Self->Get(/eout) ;2 x M
;And so ein is eout
ein = eout
fwhm_vs_e = Self->Get(/fwhm_vs_e)
e_vs_fwhm = Self->Get(/e_vs_fwhm)

sig_lim = self->Get(/sig_lim)
ninput = n_elements( ein(0,*))
noutput= n_elements( eout(0,*))
edge_products, ein, width=wein, mean=emin
edge_products, eout,  mean=emout
sigmax = interpol(fwhm_vs_e, e_vs_fwhm, emin)/2.36
sigrow = abs((rebin( emout, noutput, ninput)-transpose(rebin(emin,ninput,noutput))) $
	/ transpose( rebin(sigmax, ninput, noutput)) )
psm = fltarr(noutput,ninput)

res_elem = f_div( sigmax, wein )
w1 = where( res_elem ge 2.0, nw1)
w2 = where( res_elem lt 2.0, nw2)

if nw1 ge 1 then for i=0,nw1 - 1 do begin
		ss = where(sigrow[*,w1[i]] le sig_lim, nss)
		if nss eq 0 then ss = lindgen(noutput)
        psm[ss,w1[i]]= (gaussint((eout[1,ss]-emin[w1[i]])/sigmax[w1[i]]) $
             -   gaussint( (eout[0,ss]-emin[w1[i]])/sigmax[w1[i]] ))[*]
        endfor
if nw2 ge 1 then for i=0,nw2 -1 do begin
	ss = where(sigrow[*,w2[i]] le sig_lim, nss)
	if nss eq 0 then ss = lindgen(noutput) else begin

		if ss[0] ge 1 then ss = [ss[0]-1,ss]
		if ss[nss-1] lt (noutput-1) then ss=[ss,ss[nss-1]+1]
		endelse
	nss  = n_elements(ss)
	nbins = ceil(1./res_elem[w2[i]]*4.0)
	enew = interpol( ein[*,w2[i]], nbins+1)
	edge_products, enew, mean=emnew
	emnew=rebin(reform(emnew,1,nbins),nss,nbins)
	e1 = rebin((eout[1,ss])[*],nss,nbins)
	e0 = rebin((eout[0,ss])[*],nss,nbins)
	psm[ss,w2[i]]= rebin( gaussint( (e1-emnew)/sigmax[w2[i]]) $
			  -  gaussint( (e0-emnew)/sigmax[w2[i]]), nss)

	endfor


self->SetData, psm


END


;
;---------------------------------------------------------------------------

PRO energy_res__Define

self = {energy_res, $
        INHERITS Framework }

END


;---------------------------------------------------------------------------
; End of 'energy_res__define.pro'.
;---------------------------------------------------------------------------
