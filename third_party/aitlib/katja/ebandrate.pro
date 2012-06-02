PRO ebandrate,phafile,avgrate,cmin=cmin,cmax=cmax 
;+
; NAME:
;          ebandrate
;
;
; PURPOSE:
;          read the average count rate in a given energy band from a
;          FITS spectrum
;
;
; FEATURES:
;          read average count rate, ``avgrate'', from a spectral file
;          in FITS format, ``phafile'', between the energy channels
;          ``cmin'' and  ``cmax''     
;
;
; CATEGORY:
;          timing tools
;          (since the average count rate of the background is needed
;          for correcting the normalization of the power spectrum in
;          case that the Miyamoto normalization is applied) 
;
; CALLING SEQUENCE:
;          ebandrate,phafile,avgrate,cmin=cmin,cmax=cmax 
;
;
; INPUTS:
;          phafile : name of the FITS file containing the spectrum
;                    that is to be read 
;
;
; OPTIONAL INPUTS:
;          cmin : minimum channel for the count rate average
;                 default: minimum channel available in the spectrum     
;          cmax : maximum channel for the count rate average
;                 default: maximum channel available in the spectrum 
;   
;
; KEYWORD PARAMETERS:
;          none
;
;
; OUTPUTS:
;          avgrate : average count rate in the energy band from cmin
;                    to cmax 
;
;
; OPTIONAL OUTPUTS:
;          none
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:
;          if no channel ranges are given, the keywords cmin and cmax
;          are set to the minimum and maximum channel present in
;          phafile  
;
;
; RESTRICTIONS:
;          the FITS file phafile has to exist
;
;
; PROCEDURE USED:   
;          (mrdfits.pro)
;
;
; EXAMPLE:
;          ebandrate,'fullback.pha',avgrate,0,10  
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 2000/12/01 Katja Pottschmidt, initial revision
;          Version 1.2, 2001/01/28 Katja Pottschmidt, IDL header added
;
;
;-
   
   data=mrdfits(phafile,1,header)
   
   IF (n_elements(cmin) EQ 0) THEN cmin=min(data.channel)
   IF (n_elements(cmax) EQ 0) THEN cmax=max(data.channel) 
   
   ndx=where(data.channel GE cmin AND data.channel LE cmax)
   
   expo=double(fxpar(header,'EXPOSURE'))
   avgrate=total(data[ndx].counts)/expo
   
   ;print,avgrate
   
END 



