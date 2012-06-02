PRO dcpsd,time,rate,period,psd,pstart=pstart,pstop=pstop, $
          sampling=sampling, freq=freq,                   $
          nbins=nbins,chatty=chatty,tolerance=tolerance,  $
          ft=ft
           
;+
; NAME:
;             dcsd
;
;
; PURPOSE: 
;            computes density corrected power spectra distribution
;
; CATEGORY: 
;             timing tools
;
;
; CALLING SEQUENCE:
;          dcpsd,time,rate,freq,psd,fstart=pstart,fstop=pstop, $
;                nbins=nbins,chatty=chatty
;                       
; 
; INPUTS:
;             time : a vector containing the time in arbitary units
;             rate : a vector containing the countrate
;             pstart:   shortest period  to be considered
;             pstop:    longest period to be considered
;
; OPTIONAL INPUTS:
;             nbins:    number of phase-bins to be used in creating the trial
;                       pulse (default=20)
;             sampling: how many frequencies to use from 1/pstop..1/pstart
;                        default=1000
;             freq    : Array containing desired frequencies to
;                       compute psd for.
;                       If set pstart/pstop/sampling are ignored.
;	
; KEYWORD PARAMETERS:

;             chatty   : if set, be chatty
;   
; OUTPUTS:
;             period :   period of power
;             psd    :   power density spectrum 
;
; OPTIONAL OUTPUTS:
;
;             ft     : quasi fourier transformation, i.e. complex array
;
; COMMON BLOCKS:
;             none
;
;
; SIDE EFFECTS:
;             none
;
;
; RESTRICTIONS:
;
;             the input lightcurve has to be given in count rates (not
;             in photon numbers). 
;
;
; PROCEDURE:
;             <Laenger Erklaerung, wenns denn mal tut>
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
;             Version 0.1, 2002/03/24, Eckart Goehler IAAT
;                          Initial version.

;-


if n_elements(nbins) eq 0 then nbins=20
if n_elements(sampling) eq 0 then sampling=1000
if n_elements(tolerance) eq 0 then tolerance=1.E-8

; default start/stop frequency: 0..1/2*time
if n_elements(pstart) eq 0 then pstart=10
if n_elements(pstop) eq 0 then $\
   pstop=(time[n_elements(time)-1] - time[0]) / 2.D0


; no input frequence defined -> create one within 
; given range
if n_elements(freq) eq 0 then begin

    freq=dblarr(sampling)



    fstart=1./pstop
    fstop=1./pstart


    f=fstart
    fstep=(fstop-fstart)/sampling

    ; define frequence array
    for i=0,sampling-1 do begin
        freq[i]=f
        f=f+fstep
    endfor
endif

;; result psd array
real_part=dblarr(n_elements(freq))  
im_part=dblarr(n_elements(freq))  



for i=0,n_elements(freq)-1 do begin
  
    ;; compute integral for period=1/f:
    dsinint2,time,rate,1.D0/freq[i],fft,nbins=nbins,tolerance=tolerance,/chatty,/nogaps

    real_part[i]=fft[0]
    im_part[i]=-fft[1]
endfor


period=1./freq   

ft=complex(real_part,im_part)

psd=abs(ft)^2   

end







