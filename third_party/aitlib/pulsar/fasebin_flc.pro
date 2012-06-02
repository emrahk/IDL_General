pro fasebin_flc, fl, range=rng, back=backfile, err=errdata, $
    flc=data, ex=expos, ph=phase, plot=plot

;
;Generic Output
;
if (n_params() eq 0) then begin  
    print,'USAGE: fasebin_flc, infile, [range=[chmin,chmax]], $'
    print,'   [back=bgfile], [err=flcerror], [flc=flc], [ex=exposure], $'
    print,'   [ph=phases],[/plot]'
    print,' '
    return
endif

;
;Read in the fasebin file
;
hd=headfits(fl)
tab=readfits(fl,hd,ext=1)

;Get data from the different columns
phase=fits_get(hd,tab,'PHASE')
cnts=fits_get(hd,tab,'COUNTS')
expos=fits_get(hd,tab,'EXPOSURE')
channel=fits_get(hd,tab,'CHANNEL')

result=size(cnts)
nbins=result(2)      ; Number of phase bins
data=dblarr(nbins)

;
;If an energy range is not specified then use the entire spectrum
;
if (keyword_set(rng) eq 0) then rng=[min(channel),max(channel)]

;
;Acumulate the Folded Light Curve.  Source + BG Counts
;
for i=0,nbins-1 do BEGIN 
    data(i)=total(cnts(rng(0):rng(1),i))
endfor

;
;Convert to rates
;
data_err=sqrt(data)/expos ; Get the err while data is still cnts
data=data/expos           ; convert cnts to rate

;
;If a background file is specified, then load it and do
;   a proper background subtraction.  Otherwise just
;   center the FLC around (max+min)/2.
;
if (keyword_set(backfile)) then begin
    ;load the Background Fits File
    hd=headfits(backfile)
    tab=readfits(backfile,hd,ext=1)

    ;Get data from the different columns
    bg_cnts=fits_get(hd,tab,'COUNTS')
    bg_expos=fxpar(hd,'EXPOSURE')

    bg_cnts=total(bg_cnts(rng(0):rng(1))) ; total bg counts
    bg_rate=bg_cnts/bg_expos               ; bg rate
    bg_err=sqrt(bg_cnts)/bg_expos          ; err on bg rate

    data=data-bg_rate
    errdata=sqrt(data_err^2. + bg_err^2)
endif else begin
    data=data-(max(data)+min(data))/2.d
    errdata=data_err
endelse

if (keyword_set(plot)) then begin
    plot,phase,data,psym=10
    oploterr,phase,data,errdata,3
endif

return
end






