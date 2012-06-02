pro loadrsp, fl, nrg, channel=ch, width=wdth, emin=e_min, emax=e_max, ext=ext

;
; Be nice to the user, they're probably me a few
; months from now
;
if (n_params() eq 0) then begin
    print,'USAGE: loadrsp,infile,energy,width=width, $'
    print,'       emin=emin,emax=emax,ext=extension'
    print,' '
    print,' INPUTS:  infile, input filename (single file only)'
    print,'          extension, extension to look in (1=PCA,2=HEXTE)'
    print,' OUTPUTS: Energy, values of the energy centroids'
    print,'          width, widths of the energy bins'
    print,'          emin, energy lower boundary'
    print,'          emax, energy upper bondary'
    return
endif

if ( keyword_set(ext) eq 0 ) then begin
   ext = 1 ; Default to the PCA
endif

;
; Load in the fits file
; 
hd=headfits(fl)
tab=readfits(fl,hd,ext=ext)

;
; Load in the data from the fits file
;
ch=double(fits_get(hd,tab,'CHANNEL'))
e_min=double(fits_get(hd,tab,'E_MIN'))
e_max=double(fits_get(hd,tab,'E_MAX'))

;
; Calculate the energy and width from the
; min an max edges in the response matrix
; 
nrg=(e_max + e_min)/2.d
wdth=(e_max - e_min)/2.d

;
; fin
;
print,'fin'

return
end
