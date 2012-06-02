
PRO readcyclo,energy,inspec,outspec,filename,spawnspec=spawnspec,$
              depth=depth,step=step,relative=relative,tau=tau,kev=kev,$
              chatty=chatty, nangle=nangles, nbins=lines_per_block 


;+
; NAME:
;       readcyclo
;
;
; PURPOSE:
;       Read spectra from a file with results of R. Araya's MC code
;
; CATEGORY:
;       cyclotron lines
;
;
; CALLING SEQUENCE:
;       readcyclo,energy,inspec,outspec,filename,spawnspec=spawnspec
; 
; INPUTS:
;       filename : [path/]name of the file from which the data is read 
;
;       
; KEYWORD PARAMETERS:
;       spawnspec : The spawned spectra as fltarr(4,en)       [optional output]
;       depth     : Optical depth level required (1-4). Default is 4.   [input]
;       step      : Output step requested. Default is last (see below). [input]
;       relative  : Return output spectra divided by input spectrum.     [flag]
;       tau       : Array(4) of Thomson optical depths actually used   [output]
;       kev       : Return energy array in keV instead of in MeV         [flag]
;       chatty    : Give all sorts of messages                           [flag]
;
; OUTPUTS:
;       energy  : Energy in MeV of the sample spectral bins
;       inspec  : 2-dim array with the input spectra at 4 different angles
;       outspec : 2-dim array with the output spectra at 4 different
;                 angles sampled at a given optical depth. Only the 
;                 highest optical depth is considered reliable by
;                 R. Araya.
;                 
;                 Note: a value of 1e-10 is used where no valid data exists.
;
; COMMON BLOCKS:
;       none
;
;
; SIDE EFFECTS:
;       none
;
; RESTRICTIONS:
;       none
;
; PROCEDURE:
;       First, the whole input file is scanned to see how often the MC
;       code wrote out a results table (done every 5000 injected
;       photons as safeguard against crashes). 
;       Then the read-in is repeated this time stopping at the selected
;       step. The whole table of output numbers is read in and the
;       relevant columns (depending on selected depth) are extracted.
;
; EXAMPLE:
;       readcyclo,energy,inspec,outspec,'slab_b0.04_t1e-3_T05.0.out',$
;                 spawnspec=spawnspec,depth=3,step=5
;
;       Read in the results for output step 5 from file 
;       slab_b0.04_t1e-3_T05.0.out at the next to highest optical depth 
;
; MODIFICATION HISTORY:
;       Version 1.0, PK, 1999-10-18:  
;           First version 
;       Version 1.1, PK, 1999-10-19:  
;           Added tau & chatty keywords, better documentation
;       Version 1.2, PK, 2000-01-14:  
;           Corrected column identification according to email from
;           R. Araya of 2000-01-12 (spawnspec <-> outspec)
;
;       Peter Kretschmar, peter.kretschmar@astro.uni-tuebingen.de
;
;-


IF (NOT keyword_set(depth)) THEN depth=4

;
; The number of data points per spectrum is currently 81 
; +2 'empty' lines repeating the first and last spectral
; bin, because R. Araya could use this in his plotting tools.
; In addition, the last spectral channel is always empty.
;

if (keyword_set(lines_per_block) eq 0) then lines_per_block = 298
skip_lines_at_start = 0
skip_lines_at_end   = 0

; number of bins for the various output arrays
nbins = lines_per_block - skip_lines_at_start - skip_lines_at_end

; local variables
dummyline=''
tau = fltarr(4)

;
; First pass: figure out the number of times the MC code produced
;             output spectra (every 5000 injected photons)
; 
step_count=0
openr,lun,/get_lun,filename

WHILE NOT EOF(lun) DO BEGIN
    readf,lun,dummyline
    IF (strpos(dummyline,'_spw') NE -1) THEN BEGIN
        step_count = step_count+1
    ENDIF

    IF (strpos(dummyline,'Sample optical depths =') NE -1) THEN BEGIN
        eqpos  = strpos(dummyline,'=')
        taustr = strmid(dummyline,eqpos+1,100)
        reads,taustr,tau
    ENDIF

    
ENDWHILE

free_lun,lun

IF keyword_set(chatty) THEN BEGIN
    print,format='(a,a)',$
      'Reading from file ',filename
    print,format='(a,i2,a)',$
      'The file contains ',step_count,' result tables'
    print,format='(a,4(e10.4,1x))',$
      'Sample optical depths used: ',tau
ENDIF

;
; default: use last produced result
;
IF (NOT keyword_set(step)) THEN step=step_count

IF ( (step LT 0) OR (step GT step_count) ) THEN BEGIN
  print,format='(a,i2,a)',$ 
  'Impossible step requested: ',step,'!'
  RETURN
END


; 
; Second pass: skip spectra until right step is reached
;
step_count=0
openr,lun,/get_lun,filename

WHILE (NOT EOF(lun)) DO BEGIN
    readf,lun,dummyline
    IF (strpos(dummyline,'_spw') NE -1) THEN BEGIN
        step_count = step_count+1
    ENDIF

    IF (step_count EQ step) THEN BEGIN

        IF keyword_set(chatty) THEN print,format='(a,i2,a,i1,a,e10.4)', $
          'Reading result table ',step_count,' at depth ',depth, $
          ' corresponding to tau = ',tau(depth-1)
;
; skip over $ symbol    
;
        readf,lun,dummyline  

;
; The actual result consists of a table with 10 columns and 4*83=332 lines.
; Each 'block' of 83 lines describes the spectra obtained for one of four
; angular bins, with the bins corresponding to mu = cos(theta) ranging
; from 0.00-0.25, 0.25-0.50, 0.50-0.75 and 0.75-1.00.
; The columns are:
;  1) energy in MeV
;  2) input photon spectrum
;  3) outgoing spectrum for opt. depth 1 (lowest) 
;  4) spawned spectrum  for opt. depth 1 
;  5) outgoing spectrum for opt. depth 2  
;  6) spawned spectrum  for opt. depth 2 
;  7) outgoing spectrum for opt. depth 3  
;  8) spawned spectrum  for opt. depth 3 
;  9) outgoing spectrum for opt. depth 4 (highest) 
; 10) spawned spectrum  for opt. depth 4 
; Note: the first and the last two lines of each spectrum are always 'zero'
; 
; read all 10*332 values in the table
;

        if (keyword_set(nangles) eq 0) then nangles = 4

        dummyfltarr=fltarr(10,nangles*lines_per_block)
        readf,lun,dummyfltarr 

        energy=fltarr(nbins)
        selectlines = indgen(nbins) + skip_lines_at_start

;
; calculate energy as mean of lower+upper bound 
; 
        energy(*) = 0.5*( dummyfltarr(0,selectlines) + $
                          dummyfltarr(0,selectlines+1) )
        IF keyword_set(kev) THEN energy=energy*1000.0

        inspec  = fltarr(nangles,nbins)
        outspec = fltarr(nangles,nbins)
        spawnspec = fltarr(nangles,nbins)

;
; extract input outgoing and spawned spectra as function of angular bin
;
        FOR anglebin = 1,nangles DO BEGIN
            selectlines = indgen(nbins) + (anglebin-1)*lines_per_block + $
                          skip_lines_at_start
;;            print,form='(a,i4,a,i4)',$
;;              'selectlines: ',selectlines(0),' -- ',$
;;               selectlines(nbins-1)

            inspec(anglebin-1,*)  = dummyfltarr(1,selectlines)
            outspec(anglebin-1,*) = dummyfltarr((depth-1)*2+2,selectlines) 
            IF keyword_set(spawnspec) THEN $
              spawnspec(anglebin-1,*) = dummyfltarr((depth-1)*2+3,selectlines) 


            IF keyword_set(relative) THEN BEGIN
                outspec(anglebin-1,*) = outspec(anglebin-1,*) / $
                                        inspec(anglebin-1,*)
                spawnspec(anglebin-1,*) = spawnspec(anglebin-1,*) / $
                                          inspec(anglebin-1,*)
            ENDIF

        ENDFOR
;
; Data is read -> return to calling level
;
        free_lun,lun
        RETURN
    ENDIF
        
ENDWHILE


free_lun,lun
RETURN

END







