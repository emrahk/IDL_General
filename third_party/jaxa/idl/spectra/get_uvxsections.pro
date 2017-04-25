
pro get_uvxsections, lambda, O, N2, O2, debug=debug, $
		     lamx=lambdax, raw_table=raw_table
;+
;   Name: get_uvxsections
;
;   Purpose: return UV/EUV xsections for input lambda, O, N2, and O2
;
;   Input Parameters:
;      lambda - desired wavelength(s)
;  
;   Output Parameters:
;      O  - corresponding atomic Oxygen X-section Units: 10^-18/cm^2
;      N2 - corresponding Nitrogen X-section       ""      ""
;      O2 - corresponding Oxygen   X-section       ""      ""
;
;   Keyword Parameters:
;
;   Calling Seqeunce:
;      get_uvxsection, lambda, O, N2, O2
;  
;   History:
;      31-March-2000 - S.L.Freeland
;
;   Method:
;      Uses data supplied by Roger Thomas which is contained in
;      $SSW/gen/data/spectra/uv_xsections.dat (inc. source info)
;      Output (xsections) are interpolated according to that table
;-

common get_uvxsections_blk, lamdax, Ox, N2x, O2x
debug=keyword_set(debug)

if n_params() lt 2 then begin
   box_message,['Expect LAMBDA input and at least one output param',$
               'IDL> get_uvxsection, lambda, O, N2, O2 [,/no_interp]']
   return
endif

nout=n_elements(lambda)

if n_elements(lambdax) eq 0 then begin
   xfiles=concat_dir('DIR_GEN_SPECTRA','uv_xsections.dat')  ;TTIOT!
   if not file_exist(xfiles) then begin
      box_message,'Cross Section File: '+xfiles+ ' not online, ...'
      return
   endif
   xdat=rd_tfile(xfiles,nocom=';',/compre)
   strtab2vect,float(str2cols(xdat,/unal)),lambdax, Ox, N2x, O2x
endif
if keyword_set(raw_table) then begin
   lambda=lambdax
   O=Ox
   N2=N2x
   O2=O2x
endif else begin 
   O =interpol(Ox,  lambdax, lambda)
   N2=interpol(N2x, lambdax, lambda)
   O2=interpol(O2x, lambdax, lambda)
endelse

if debug then stop

return
end
