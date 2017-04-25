
; Routine to make files goes_get_chianti_temp.pro and goes_get_chianti_em.pro
; using GOES responses and CHIANTI spectra for use of coronal and photospheric
; abundances in creating T and EM from GOES data. Contains 8 routines.
;
;------------------------------------------------------------------------
; This version assumes Linux/UNIX for system call to 'date' to get today, 
; and puts files in /tmp. I think it's otherwise architecture-independent.
;------------------------------------------------------------------------
;
; Type ".run make_goes_chianti_response" and then 
;
;        "make_goes_chianti_response"
;
; within SOLARSOFT and wait 10 hours while 202 CHIANTI spectra are generated 
; (the ch....genx files can be deleted after the program finishes), 
; then convolved with responses. The output routines are written to /tmp. 
;
; TO ADD A NEW SATELLITE:
; - change nsat, add the gbar values to gbshort and gblong arrays at beginning 
;   and calibration data at end to the goes_tf_coeff
; - change nsat in goes_tf 
; - change nsat in the master routine at the end of the program
; - remove any file named goes_tf_coeff.dat in the active directory
; - make sure that the "correction" factors [0.70,0.85] used to make
;   recent good fluxes consistent with bad old GOES-7 fluxes still apply
;   (scl89 factor in goes_chianti_tem, goes_tem).
; The calibration tables are plots of response versus wavelength. There
; are edges in the spectra at wavelengths in the "edges" variable, the
; table may or may not be out of order but the goes_tf_coeff re-orders them.
;
; Stephen White 2005 February white@astro.umd.edu
; Stephen White 2012 January: switched to the chianti.ioneq ionization
;                             equilibrium file in Chianti 7.0

;------------------------ today ---------------------------------------

pro today, mmddyy

 mmddyy = ''
 spawn,'date +%D',mmddyy
 mmddyy=mmddyy[0]

end

;------------------------ chianti_version -----------------------------
;+
; PROJECT:
;     CHIANTI
;
; PURPOSE:
;     Return CHIANTI version
;
; CALLING SEQUENCE:
;       chianti_version, version 
;
;-

pro chianti_version, vers

 pwd = GET_ENVIRON( 'SSW_CHIANTI' )
 get_lun, lun
 tmp = ''
 openr,lun,pwd+'/dbase/VERSION'
 readf,lun,tmp
 close, lun
 vers=strtrim(tmp,2)
 if (strlen(vers) lt 2) then vers = 'XXX'

end

;------------------------ generate_spectra.pro ------------------------
;+
; PROJECT:
;     GOES
;
; PURPOSE:
;     Generate CHIANTI spectra for calculation of GOES responses.
;
; CATEGORY:
;       GOES
;
; CALLING SEQUENCE:
;       generate_spectra [, /photospheric ]
;
; INPUTS:
;       Set /PHOTOSPHERIC for photospheric abundances, default is coronal
;
; OUTPUTS:
;       Individual SAVEGEN files containing spectra SPC for each of 62 
;       temperatures, labelled ch<VERS>_cor_3e10_1e27_<LOGT>.genx or
;       ch<VERS>_pho_3e10_1e27_<LOGT>.genx
;
; PROCEDURE:
;     Calls MAKE_CHIANTI_SPEC 
;
; MODIFICATION HISTORY:
;     SW 2005 Jan
;-
;
; --------------------------------------------------------------------------
;

pro generate_spectra, photospheric=photospheric

; extracted commands from ch_ss to run outside widget

; inputs
int_xrange=[0.01,20]          ; wavelength range, Angstrom
ang=0.01 & inst=0.03          ; wavelength bin size, resolution
density=3.e10
iso_logem=27.0
; ioneq_name=!xuvtop+'/ioneq/mazzotta_etal_ext.ioneq'
print,'Using the new chianti.ioneq'
ioneq_name=!xuvtop+'/ioneq/chianti.ioneq'
min_abund=4.00e-11
xrange=int_xrange         ; wavelength range for spectrum
chianti_version, vers

for i=0,100 do begin       ; start temperature loop

   iso_logt=6.0+i*0.02
   
   ; cal to ch_synthetic to generate line list
   
   ch_synthetic, int_xrange(0), int_xrange(1), $
      output=tran, $
      err_msg=err_msg, msg=msg, $
      density=density, $
      all=1, $
      LOGT_ISOTHERMAL=iso_logt, $
      logem_isothermal=iso_logem, $
      ioneq_name=ioneq_name
   
   ; then call make_chianti_spec to add lines to continuum
   

   if not keyword_set(photospheric) then begin

     abund_name=!xuvtop+'/abundance/sun_coronal_ext.abund'
     delvarx, lambda     ; clear lambda array, will be returned by routine
     make_chianti_spec,tran, lambda, spc, BIN_SIZE=ang,$
        INSTR_FWHM=inst, wrange=xrange, $
        ALL=1, continuum=1, $
        ABUND_NAME=ABUND_NAME, $
        MIN_ABUND=MIN_ABUND, $
        err_msg=err_msg, /VERBOSE
     save_file='ch'+vers+'_cor_3e10_1e27_'+string(iso_logt,format='(f4.2)')+'.genx'
     savegen, struct=spc, file=save_file
     
   endif else begin
     ; repeat for photospheric abundance: line list the same, change abundance file
  
     abund_name=!xuvtop+'/abundance/sun_photospheric.abund'
     delvarx, lambda     ; clear lambda array, will be returned by routine
     make_chianti_spec,tran, lambda, spc, BIN_SIZE=ang,$
        INSTR_FWHM=inst, wrange=xrange, $
        ALL=1, continuum=1, $
        ABUND_NAME=ABUND_NAME, $
        MIN_ABUND=MIN_ABUND, $
        err_msg=err_msg, /VERBOSE
     save_file='ch'+vers+'_pho_3e10_1e27_'+string(iso_logt,format='(f4.2)')+'.genx'
     savegen, struct=spc, file=save_file
   endelse
     
end      ; end temperature loop

end

;------------------------ goes_tf_coeff.pro ---------------------------

;+ 
; NAME:    GOES_TF_COEFF 
;   Richard/Roger's goes_tf_coeff with GOES 11, 12 calibration added
;   using reports supplied by Rodney Viereck, NOAA, and minor
;   corrections to typos in GOES 10 array
;   [ Note:  Some input values deleted by RJT due to errors in original! ] 
; 
; PURPOSE: 
; This procedure returns absorption-edge wavelenghts, polynomial coefficients 
;  of fits to the log10 measured transfer-functions, and G-bar values for all 
;  available GOES XRS soft X-ray spectrometers (up to GOES-10).  Note that 
;  the returned coefficients are identical for GOES-1 through GOES-5, though 
;  individual G-bar values are given for each satellite (except GOES-3, for 
;  which data are not available; GOES-2 values are returned for it). 
; 
; CATEGORY: 
;  GOES, SPECTRAL ANALYSIS 
; 
; CALLING SEQUENCE: 
;  goes_tf_coeff,date='1988/11/22',edge=e,coeff=c,gbshort=s,gblong=l 
;             [ ,/new , file='C:\Data\goes_tf_coeff.sav' ] 
; 
; INPUTS:  None. 
; 
; KEYWORD PARAMETERS: 
;  DATE          Time in ANYTIM format, used for GOES-6 which had a change 
;                  in its value of GBLONG on 1983 June 28. [ def = after ] 
;  EDGE          Wavelength edges for both channels [in units of A]. 
;  COEFF         Coefficients for polynomial fits to transfer functions. 
;  GBSHORT       Conversion parameters (G-bar) for short channels. 
;  GBLONG        Conversion parameters (G-bar) for long channels. 
;  NEW           Saves results, if set. Otherwise, results are restored. 
;  FILE          File used to store/restore results. 
;                  [ def = 'C:\Data\goes_tf_coeff.sav' ] 
; OUTPUTS: 
;  Arrays in keyword format, so that the output order does not matter. 
; 
; PROCEDURE: 
;  All of the original GOES transfer function values [in Amp/(Watt/meter^2)] are 
;  taken from VERSION 6 of GOES_TRANSFER, and are said to be from R.F. Donnelly, 
;  R.N. Grubb, & F.C. Cowley (1977), NOAA Tech.Memo. ERL SEL-48 (for GOES-1) and 
;  from Howard Garcia, private communications to Richard Schwartz (for GOES-2 
;  through GOES-10).  However, Roger J. Thomas has deleted a number of these  
;  values which were clearly in error, as indicated below. 
; 
;  These transfer functions allow one to integrate over a solar spectrum to 
;  get the response of the GOES detectors.  Reported GOES values of solar 
;  X-ray fluxes (in units Watt/meter^2) have been converted from the actual 
;  measurements (in units of Amp) by means of the wavelength-averaged transfer 
;  function constants, here called GBSHORT and GBLONG, for the 0.5-4.0 and 
;  1.0-8.0 Angstrom channels, respectively. 
; 
; EDGE is in the form [W1,W2,W3], COEFF is in the form [SatIndex,Segment,Param]. 
; GBSHORT & GBLONG are in the form [GOES1value, GOES2value, ..., GOES10value]. 
; Transfer Functions are defined in five wavelength segments, as follows: 
;   Seg 0    wave lt W1              TF_short = 10^(poly(wave,coeff(sat-1,0,*))) 
;   Seg 1    wave ge W1 and lt W2    TF_short = 10^(poly(wave,coeff(sat-1,1,*))) 
;   Seg 2    wave ge W2              TF_short = 10^(poly(wave,coeff(sat-1,2,*))) 
;   Seg 3    wave lt W3              TF_long  = 10^(poly(wave,coeff(sat-1,3,*))) 
;   Seg 4    wave ge W3              TF_long  = 10^(poly(wave,coeff(sat-1,4,*))) 
; 
; COMMON BLOCKS:  None. 
; 
; MODIFICATION HISTORY: 
;  Roger.J.Thomas@nasa.gov, 2003 July 25. 
;  Based heavily on VERSION 6 of GOES_TRANSFER written by Richard A. Schwartz  
;  SDAC/GSFC/HSTX 1998 August 03.  But the GOES-6 conversion date was corrected  
;  from 1993 June 28 to 1983 June 28.  Also, a number of Transfer-Function values 
;  in GOES_TRANSFER were found to be in error; they have been deleted here. 
;  All such changes from GOES_TRANSFER are summarized below. 
; 
;  GOES-6 date-test is changed from 4.5722880e+08 to 1.416096e8. 
;  The following Transfer Function values have been deleted: 
; 
;                               Wave-Dependant Transfer Function Values 
;                               ---------------------------------------    
;     SatNum  Chan   Wavelength   Original    RJT-Estimate    Action: 
;      1-5     S       0.7        2.03e-6       4.11e-6       Deleted 
;      6,7     S       6.2        3.70e-8       2.11e-8       Deleted 
;      6,7     S       6.4        2.80e-8       9.61e-9       Deleted 
;       6      L       3.8-       5.63e-6       5.74e-6       Deleted 
;       6      L       3.8+       3.92e-6       4.00e-6       Deleted 
;       7      L      16.0        3.40e-11      5.00e-12      Deleted 
;      10      S       7.0        1.70e-11      7.28e-10      Deleted 
;
; S. White, 2004: added GOES 12.
; S. White, 2009: added GOES 14.
; S. White, 2013: added GOES 15.
;- 

pro goes_tf_coeff, date=date, edge=edge, coeff=coeff,  $ 
      gbshort=gbshort, gblong=gblong , new=new, file=file 
 
if n_elements(file) eq 0 then file='goes_tf_coeff.sav' 

if not keyword_set(new) then begin 
  restore,file 
  goto,next 
  endif 
 
nsat=15
;  Approximate wavelength edges (in Angstrom) for all GOES satellites: 
edge=[0.355,2.585,3.865] 
; SLIGHTLY DIFFERENT for 10, 12
 
;  G-bar values in units of Amp/(Watt/meter^2) for all GOES satellites: 
; integration procedure for gbars, need to tiptoe around jumps
; sort ws,ts,wl,tl into wavelength before applying following
; gbars=int_tabulated(ws[0:3],ts[0:3],/double)+int_tabulated(ws[4:27],ts[4:27],/double)+int_tabulated(ws[28:50],ts[28:50],/double)
; gbarl=int_tabulated(wl[0:19],tl[0:19],/double)+int_tabulated(wl[20:51],tl[20:51],/double)
; gbshort=gbars/2.5 & gblong=gbarl/7., assumes averaging over 0.5-3.0 and 1-8 A
; values for GOES 15 calculated from these formulae, no official values
 
gbshort = 1e-5*[1.27,1.25,1.25,1.73,1.74,1.74,1.68,1.580,1.607,1.631,1.608,1.595,1.560,1.560,1.593] 
gblonga = 1e-6*[4.09,3.98,3.98,4.56,4.84,5.32,4.48,4.165,3.990,3.824,4.377,4.090,4.167,4.167,3.991] 
gblongb = gblonga & gblongb[5]=4.43e-6      ; Before & after for GOES-6 
 
;  Transfer function coefficients for all GOES satellites: 
coeff=dblarr(nsat,5,7) & wsm=dblarr(55,nsat) & wlm=wsm & tsm=wsm & tlm=wsm 
 
;  Transfer function measurements for GOES-1 through GOES-5: 
ws=[.1+.1*findgen(35),3.6+.2*findgen(8),5.5,6,7,8,.35839,.35841,2.5869,2.5871] 
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4),3.869,3.871] 
ts= 1.e-6*[ .162, .621, 1.38, 1.01, 1.8, 2.87, 2.03, 5.61, 7.73,       $ 
  9.24,  11.0, 12.9, 14.7, 16.3, 17.1, 18.0, 18.6, 18.9, 19.0,         $ 
  18.8, 18.5, 18.0, 17.1, 16.4,  15.1, 11.3, 11.2, 11.0, 10.7, 10.4,   $ 
  9.89, 9.36, 8.77, 8.14, 7.5, 6.68, 5.54, 4.38, 3.25, 2.39,1.70, 1.17,$ 
  .781, .233, .0539, .00131, .00001, 1.79, .789, 14.5, 11.3] 
tl= 1.e-6*[.021, .140, .418, .887, 1.54, 2.34, 3.24, 4.11,             $ 
  4.87, 5.49, 5.92, 6.18, 6.29, 6.31, 6.25, 6.14, 6.01, 5.85, 5.68,    $ 
  4.02, 4.12, 4.20, 4.24, 4.24, 4.19, 4.09, 3.96, 3.81, 3.62, 3.42,    $ 
  3.21, 2.99, 2.54, 2.07, 1.66, 1.31, .992, .732, .527, .368, .249,    $ 
  .163, .102, .0624, .0369, .0210, .00416, .00068, .00009, .00001,     $ 
  5.63, 3.92] 
v=where(abs(ws-0.7) gt .01) & ws=ws(v) & ts=ts(v)    ; Correction by RJT 
os=sort(ws) & ol=sort(wl)                            ; Sort data 
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol) 
for n=0,4 do begin 
  wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl    ; Load array 
  endfor 
 
;  Transfer function measurements for GOES-6: 
ws=[.1+.1*findgen(35),3.6+.2*findgen(15),.35839,.35841,2.5869,2.5871] 
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4),3.869,3.871] 
ts= [1.25e-7,6.20e-7, $ 
  1.33e-6,9.94e-7,1.79e-6,2.88e-6,4.24e-6,5.82e-6,7.56e-6,9.40e-6, $ 
  1.13e-5,1.30e-5,1.46e-5,1.60e-5,1.68e-5,1.77e-5,1.83e-5,1.85e-5, $ 
  1.86e-5,1.84e-5,1.80e-5,1.76e-5,1.67e-5,1.61e-5,1.47e-5,1.10e-5, $ 
  1.09e-5,1.06e-5,1.03e-5,9.92e-6,9.47e-6,8.93e-6,8.39e-6,7.77e-6, $ 
  7.18e-6,6.49e-6,5.27e-6,4.12e-6,3.11e-6,2.27e-6,1.59e-6,1.08e-6, $ 
  7.07e-7,5.06e-7,3.06e-7,1.74e-7,1.10e-7,4.60e-8,3.70e-8,2.80e-8, $ 
  0.97e-6*[1.79,.789,14.5,11.3]] 
tl= [1.99e-8,1.42e-7, $ 
  4.27e-7,9.21e-7,1.57e-6,2.37e-6,3.26e-6,4.15e-6,4.95e-6,5.58e-6, $ 
  6.04e-6,6.31e-6,6.43e-6,6.45e-6,6.40e-6,6.29e-6,6.16e-6,6.00e-6, $ 
  5.83e-6,4.09e-6,4.22e-6,4.31e-6,4.35e-6,4.35e-6,4.30e-6,4.20e-6, $ 
  4.08e-6,3.92e-6,3.74e-6,3.54e-6,3.32e-6,3.11e-6,2.65e-6,2.20e-6, $ 
  1.77e-6,1.39e-6,1.06e-6,7.86e-7,5.67e-7,4.00e-7,2.74e-7,1.79e-7, $ 
  1.15e-7,7.07e-8,4.22e-8,2.43e-8,4.99e-9,8.3e-10,1.1e-10,1.1e-11, $ 
  5.63e-6, 3.92e-6] 
v=where(ws lt 6.1)           & ws=ws(v) & ts=ts(v)   ; Correction by RJT 
v=where(abs(wl-3.87) gt .01) & wl=wl(v) & tl=tl(v)   ; Correction by RJT 
os=sort(ws) & ol=sort(wl)                            ; Sort data 
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol) 
wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl & n=n+1 ; Load array 
 
;  Transfer function measurements for GOES-7: 
ws=[.1+.1*findgen(35),3.6+.2*findgen(15),.35839,.35841,2.5869,2.5871] 
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4),3.869,3.871] 
ts= [1.23e-7,6.12e-7, $ 
  1.31e-6,9.80e-7,1.77e-6,2.84e-6,4.18e-6,5.74e-6,7.46e-6,9.27e-6, $ 
  1.11e-5,1.29e-5,1.45e-5,1.58e-5,1.66e-5,1.75e-5,1.81e-5,1.83e-5, $ 
  1.83e-5,1.82e-5,1.78e-5,1.74e-5,1.64e-5,1.59e-5,1.46e-5,1.09e-5, $ 
  1.08e-5,1.04e-5,1.02e-5,9.81e-6,9.37e-6,8.83e-6,8.30e-6,7.68e-6, $ 
  7.11e-6,6.43e-6,5.22e-6,4.08e-6,3.09e-6,2.26e-6,1.58e-6,1.08e-6, $ 
  7.04e-7,5.04e-7,3.06e-7,1.74e-7,1.10e-7,4.61e-8,3.70e-8,2.80e-8, $ 
  0.95e-6*[1.79,.789,14.5,11.3]] 
tl= [2.09e-8,1.50e-7, $ 
  4.48e-7,9.67e-7,1.64e-6,2.49e-6,3.42e-6,4.35e-6,5.19e-6,5.85e-6, $ 
  6.32e-6,6.60e-6,6.72e-6,6.73e-6,6.67e-6,6.54e-6,6.39e-6,6.22e-6, $ 
  6.03e-6,4.22e-6,4.34e-6,4.42e-6,4.45e-6,4.43e-6,4.35e-6,4.24e-6, $ 
  4.10e-6,3.92e-6,3.72e-6,3.49e-6,3.25e-6,3.03e-6,2.54e-6,2.08e-6, $ 
  1.64e-6,1.26e-6,9.33e-7,6.67e-7,4.73e-7,3.24e-7,2.14e-7,1.34e-7, $ 
  8.32e-8,4.90e-8,2.79e-8,1.53e-8,2.72e-9,3.8e-10,4.3e-11,3.4e-11, $ 
  [5.63e-6, 3.92e-6]*1.05] 
v=where(ws lt 6.1)           & ws=ws(v) & ts=ts(v)   ; Correction by RJT 
v=where(abs(wl-16.0) gt .01) & wl=wl(v) & tl=tl(v)   ; Correction by RJT 
os=sort(ws) & ol=sort(wl)                            ; Sort data 
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol) 
wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl & n=n+1 ; Load array 
 
;  Transfer function measurements for GOES-8: 
ws=[.1+.1*findgen(36),3.8+.2*findgen(14)] 
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4)] 
ts= [1.19E-7, 5.90E-7, $ 
  1.27E-6, 9.47E-7, 1.71E-6, 2.74E-6, 4.04E-6, 5.54E-6, 7.19E-6, 8.94E-6, $ 
  1.07E-5, 1.24E-5, 1.39E-5, 1.52E-5, 1.60E-5, 1.68E-5, 1.74E-5, 1.76E-5, $ 
  1.76E-5, 1.74E-5, 1.70E-5, 1.66E-5, 1.57E-5, 1.51E-5, 1.38E-5, 1.03E-5, $ 
  1.02E-5, 9.84E-6, 9.58E-6, 9.22E-6, 8.78E-6, 8.25E-6, 7.72E-6, 7.13E-6, $ 
  6.57E-6, 5.92E-6, 4.76E-6, 3.69E-6, 2.76E-6, 2.00E-6, 1.38E-6, 9.28E-7, $ 
  5.97E-7, 3.58E-7, 2.17E-7, 1.23E-7, 6.62E-8, 3.55E-8, 1.62E-8, 7.39E-9] 
tl= [1.82E-8, 1.31E-7, $ 
  3.92E-7, 8.46E-7, 1.44E-6, 2.18E-6, 3.00E-6, 3.81E-6, 4.55E-6, 5.13E-6, $ 
  5.55E-6, 5.80E-6, 5.92E-6, 5.94E-6, 5.89E-6, 5.80E-6, 5.69E-6, 5.55E-6, $ 
  5.40E-6, 3.79E-6, 3.92E-6, 4.01E-6, 4.06E-6, 4.06E-6, 4.02E-6, 3.94E-6, $ 
  3.84E-6, 3.70E-6, 3.54E-6, 3.36E-6, 3.16E-6, 2.97E-6, 2.56E-6, 2.15E-6, $ 
  1.74E-6, 1.39E-6, 1.07E-6, 8.06E-7, 5.90E-7, 4.24E-7, 2.95E-7, 1.97E-7, $ 
  1.29E-7, 8.16E-8, 4.99E-8, 2.96E-8, 6.55E-9, 1.19E-9, 1.8E-10, 1.9E-11] 
os=sort(ws) & ol=sort(wl)                            ; Sort data 
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol) 
wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl & n=n+1 ; Load array 
 
;  Transfer function measurements for GOES-9: 
ws=[.1+.1*findgen(36),3.8+.2*findgen(14)] 
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4)] 
ts= [1.19E-7, 5.89E-7, $ 
  1.26E-6, 9.45E-7, 1.70E-6, 2.74E-6, 4.03E-6, 5.53E-6, 7.18E-6, 8.93E-6, $ 
  1.07E-5, 1.24E-5, 1.39E-5, 1.52E-5, 1.60E-5, 1.68E-5, 1.74E-5, 1.76E-5, $ 
  1.76E-5, 1.75E-5, 1.71E-5, 1.67E-5, 1.58E-5, 1.52E-5, 1.40E-5, 1.04E-5, $ 
  1.03E-5, 9.98E-6, 9.73E-6, 9.38E-6, 8.95E-6, 8.43E-6, 7.91E-6, 7.32E-6, $ 
  6.77E-6, 6.11E-6, 4.95E-6, 3.86E-6, 2.91E-6, 2.12E-6, 1.48E-6, 1.01E-6, $ 
  6.55E-7, 3.98E-7, 2.44E-7, 1.41E-7, 7.67E-8, 4.18E-8, 1.95E-8, 9.06E-9] 
tl= [1.74E-8, 1.24E-7, $ 
  3.73E-7, 8.05E-7, 1.37E-6, 2.07E-6, 2.85E-6, 3.63E-6, 4.33E-6, 4.89E-6, $ 
  5.29E-6, 5.53E-6, 5.64E-6, 5.66E-6, 5.62E-6, 5.53E-6, 5.42E-6, 5.29E-6, $ 
  5.15E-6, 3.62E-6, 3.74E-6, 3.83E-6, 3.88E-6, 3.88E-6, 3.85E-6, 3.78E-6, $ 
  3.68E-6, 3.55E-6, 3.40E-6, 3.23E-6, 3.04E-6, 2.86E-6, 2.47E-6, 2.08E-6, $ 
  1.69E-6, 1.35E-6, 1.04E-6, 7.91E-7, 5.82E-7, 4.20E-7, 2.94E-7, 1.98E-7, $ 
  1.30E-7, 8.27E-8, 5.09E-8, 3.04E-8, 6.89E-9, 1.28E-9, 1.9E-10, 2.2E-11 ] 
os=sort(ws) & ol=sort(wl)                            ; Sort data 
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol) 
wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl & n=n+1 ; Load array 
 
;  Transfer function measurements for GOES-10: 
ws=[.1+.1*findgen(35),3.6+.2*findgen(8),5.5,6,7,8,.35798,.35801,2.5889,2.5901]  
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4),3.869,3.8701] 
ts= [ $ 
  1.21e-7, 6.01e-7, 1.29e-6, 9.63e-7, 1.73e-6, 2.79e-6, 4.10e-6, 5.64e-6, $ 
  7.32e-6, 9.10e-6, 1.09e-5, 1.26e-5, 1.42e-5, 1.55e-5, 1.62e-5, 1.71e-5, $ 
  1.77e-5, 1.79e-5, 1.79e-5, 1.78e-5, 1.73e-5, 1.70e-5, 1.60e-5, 1.55e-5, $ 
  1.42e-5, 1.06e-5, 1.04e-5, 1.01e-5, 9.83e-6, 9.47e-6, 9.02e-6,          $ 
  8.49e-6, 7.96e-6, 7.36e-6, 6.79e-6, 6.12e-6, 4.94e-6, 3.85e-6, 2.85e-6, $ 
  2.10e-6, 1.46e-6, 9.84e-7, 6.37e-7, 1.81e-7, 3.92e-8, 8.17e-10,4.24e-12,$ 
  1.62e-6, 7.30e-7, 1.37e-5, 1.06e-5] 
tl= [1.76e-8, 1.26e-7, $ 
  3.77e-7, 8.14e-7, 1.38e-6, 2.09e-6, 2.88e-6, 3.67e-6, 4.37e-6, 4.93e-6, $ 
  5.33e-6, 5.56e-6, 5.67e-6, 5.68e-6, 5.63e-6, 5.53e-6, 5.41e-6, 5.26e-6, $ 
  5.11e-6, 3.58e-6, 3.68e-6, 3.76e-6, 3.78e-6, 3.77e-6, 3.71e-6, 3.62e-6, $ 
  3.51e-6, 3.36e-6, 3.19e-6, 3.01e-6, 2.81e-6, 2.62e-6, 2.21e-6, 1.82e-6, $ 
  1.45e-6, 1.12e-6, 8.38e-7, 6.13e-7, 4.34e-7, 3.00e-7, 2.01e-7, 1.28e-7, $ 
  8.04e-8, 4.81e-8, 2.79e-8, 1.56e-8, 2.92e-9, 4.38e-10,5.25e-11,4.51e-12,$ 
  5.05e-6, 3.48e-6 ] 
v=where(abs(ws-7.0) gt .01) & ws=ws(v) & ts=ts(v)    ; Correction by RJT 
os=sort(ws) & ol=sort(wl)                            ; Sort data 
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol) 
wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl & n=n+1 ; Load array 10 
 
;  Transfer function measurements for GOES-11:
ws=[.1+.1*findgen(35),3.6+.2*findgen(8),5.5,6,7,8,.35798,.35801,2.5889,2.5901]
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4),3.869,3.8701]
ts= [ $
  1.20e-7, 5.95e-7, 1.28e-6, 9.54e-7, 1.72e-6, 2.77e-6, 4.07e-6, 5.59e-6, $
  7.25e-6, 9.01e-6, 1.08e-5, 1.25e-5, 1.40e-5, 1.53e-5, 1.61e-5, 1.69e-5, $
  1.75e-5, 1.77e-5, 1.77e-5, 1.76e-5, 1.71e-5, 1.68e-5, 1.58e-5, 1.53e-5, $
  1.40e-5, 1.04e-5, 1.03e-5, 9.94e-6, 9.67e-6, 9.31e-6, 8.87e-6,          $
  8.34e-6, 7.81e-6, 7.21e-6, 6.65e-6, 5.99e-6, 4.83e-6, 3.74e-6, 2.80e-6, $
  2.03e-6, 1.41e-6, 9.45e-7, 6.09e-7, 1.71e-7, 3.65e-8, 7.32e-10,3.61e-12,$
  1.61e-6, 7.13e-7, 1.35e-5, 1.05e-5]
tl= [1.96e-8, 1.40e-7, $
  4.21e-7, 9.08e-7, 1.54e-6, 2.34e-6, 3.22e-6, 4.09e-6, 4.88e-6, 5.51e-6, $
  5.95e-6, 6.22e-6, 6.34e-6, 6.36e-6, 6.31e-6, 6.20e-6, 6.07e-6, 5.92e-6, $
  5.75e-6, 4.04e-6, 4.17e-6, 4.26e-6, 4.30e-6, 4.29e-6, 4.24e-6, 4.15e-6, $
  4.03e-6, 3.87e-6, 3.70e-6, 3.50e-6, 3.28e-6, 3.07e-6, 2.62e-6, 2.18e-6, $
  1.75e-6, 1.38e-6, 1.05e-6, 7.80e-7, 5.63e-7, 3.98e-7, 2.72e-7, 1.79e-7, $
  1.15e-7, 7.06e-8, 4.22e-8, 2.44e-8, 5.02e-9, 8.37e-10,1.13e-10,1.11e-11,$
  5.69e-6, 3.92e-6 ]
v=where(abs(ws-7.0) gt .01) & ws=ws(v) & ts=ts(v)    ; Correction by RJT
os=sort(ws) & ol=sort(wl)                            ; Sort data
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol)
wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl & n=n+1 ; Load array 11

;  Transfer function measurements for GOES-12:
ws=[.1+.1*findgen(35),3.6+.2*findgen(8),5.5,6,7,8,.35799,.35801,2.5889,2.5901] 
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4),3.8699,3.8701]
ts = [ $
  1.18e-7, 5.88e-7, 1.26e-6, 9.42e-7, 1.70e-6, 2.73e-6, 4.02e-6, 5.52e-6, $
  7.16e-6, 8.90e-6, 1.07e-5, 1.23e-5, 1.39e-5, 1.51e-5, 1.59e-5, 1.67e-5, $
  1.73e-5, 1.75e-5, 1.75e-5, 1.74e-5, 1.69e-5, 1.66e-5, 1.57e-5, 1.51e-5, $
  1.38e-5, 1.03e-5, 1.02e-5, 9.86e-6, 9.60e-6, 9.25e-6, 8.82e-6,          $
  8.30e-6, 7.78e-6, 7.19e-6, 6.63e-6, 5.98e-6, 4.83e-6, 3.75e-6, 2.82e-6, $
  2.05e-6, 1.42e-6, 9.58e-7, 6.20e-7, 1.76e-7, 3.80e-8, 7.88e-10,4.06e-12,$
  1.59e-6, 7.04e-7, 1.34e-5, 1.04e-5]
tl = [ 1.84e-8, 1.32e-7, $
  3.94e-7, 8.51e-7, 1.45e-6, 2.19e-6, 3.01e-6, 3.83e-6, 4.57e-6, 5.16e-6, $
  5.58e-6, 5.83e-6, 5.94e-6, 5.96e-6, 5.91e-6, 5.81e-6, 5.69e-6, 5.54e-6, $
  5.39e-6, 3.78e-6, 3.90e-6, 3.98e-6, 4.02e-6, 4.01e-6, 3.96e-6, 3.88e-6, $
  3.76e-6, 3.62e-6, 3.45e-6, 3.26e-6, 3.06e-6, 2.86e-6, 2.44e-6, 2.03e-6, $
  1.63e-6, 1.28e-6, 9.70e-7, 7.21e-7, 5.19e-7, 3.66e-7, 2.50e-7, 1.63e-7, $
  1.05e-7, 6.43e-8, 3.82e-8, 2.20e-8, 4.49e-9, 7.40e-10,9.87e-11,9.58e-12,$
  5.33e-6, 3.67e-6]
os=sort(ws) & ol=sort(wl)                            ; Sort data
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol)
wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl & n=n+1 ; Load array 12

;  Transfer function measurements for GOES-13: dummy values, copy of GOES 14
ws=[.1+.1*findgen(35),3.6+.2*findgen(8),5.5,6,7,8,.35799,.35801,2.5889,2.5901] 
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4),3.8699,3.8701]
ts = [ $
 1.167e-07,5.798e-07,1.244e-06,9.296e-07,1.674e-06,2.694e-06,3.963e-06,5.443e-06, $
 7.065e-06,8.780e-06,1.053e-05,1.217e-05,1.367e-05,1.493e-05,1.566e-05,1.649e-05, $
 1.705e-05,1.725e-05,1.727e-05,1.711e-05,1.667e-05,1.632e-05,1.540e-05,1.485e-05, $
 1.359e-05,1.012e-05,1.000e-05,9.660e-06,9.398e-06,9.045e-06,8.613e-06, $
 8.092e-06,7.578e-06,6.995e-06,6.446e-06,5.804e-06,4.671e-06,3.619e-06,2.708e-06, $
 1.957e-06,1.355e-06,9.081e-07,5.841e-07,1.630e-07,3.461e-08,6.831e-10,3.294e-12, $
 1.564e-06,6.948e-07,1.310e-05,1.020e-05 ]
tl = [ 1.864e-08,1.336e-07, $
 4.004e-07,8.640e-07,1.469e-06,2.223e-06,3.059e-06,3.894e-06,4.643e-06,5.238e-06, $
 5.664e-06,5.918e-06,6.038e-06,6.051e-06,6.002e-06,5.903e-06,5.779e-06,5.633e-06, $
 5.476e-06,3.841e-06,3.966e-06,4.050e-06,4.088e-06,4.086e-06,4.036e-06,3.952e-06, $
 3.836e-06,3.689e-06,3.520e-06,3.330e-06,3.124e-06,2.925e-06,2.498e-06,2.078e-06, $
 1.671e-06,1.314e-06,9.998e-07,7.448e-07,5.376e-07,3.799e-07,2.601e-07,1.708e-07, $
 1.098e-07,6.766e-08,4.040e-08,2.338e-08,4.824e-09,8.066e-10,1.093e-10,1.080e-11, $
 5.419e-06,3.730e-06 ]
os=sort(ws) & ol=sort(wl)                            ; Sort data
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol)
wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl & n=n+1 ; Load array 13

;  Transfer function measurements for GOES-14:
; no copy of the calibration document: Boeing (new manufacturer) are
; protecting any potential competitive advantage. Data from tables
; suppled by Rodney Viereck
; wavelength values are the same, just need to re-order tables
; to move .358, 2.59 pairs to end of ws, 3.87 pair to end of wl
ws=[.1+.1*findgen(35),3.6+.2*findgen(8),5.5,6,7,8,.35799,.35801,2.5889,2.5901] 
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4),3.8699,3.8701]
ts = [ $
 1.167e-07,5.798e-07,1.244e-06,9.296e-07,1.674e-06,2.694e-06,3.963e-06,5.443e-06, $
 7.065e-06,8.780e-06,1.053e-05,1.217e-05,1.367e-05,1.493e-05,1.566e-05,1.649e-05, $
 1.705e-05,1.725e-05,1.727e-05,1.711e-05,1.667e-05,1.632e-05,1.540e-05,1.485e-05, $
 1.359e-05,1.012e-05,1.000e-05,9.660e-06,9.398e-06,9.045e-06,8.613e-06, $
 8.092e-06,7.578e-06,6.995e-06,6.446e-06,5.804e-06,4.671e-06,3.619e-06,2.708e-06, $
 1.957e-06,1.355e-06,9.081e-07,5.841e-07,1.630e-07,3.461e-08,6.831e-10,3.294e-12, $
 1.564e-06,6.948e-07,1.310e-05,1.020e-05 ]
tl = [ 1.864e-08,1.336e-07, $
 4.004e-07,8.640e-07,1.469e-06,2.223e-06,3.059e-06,3.894e-06,4.643e-06,5.238e-06, $
 5.664e-06,5.918e-06,6.038e-06,6.051e-06,6.002e-06,5.903e-06,5.779e-06,5.633e-06, $
 5.476e-06,3.841e-06,3.966e-06,4.050e-06,4.088e-06,4.086e-06,4.036e-06,3.952e-06, $
 3.836e-06,3.689e-06,3.520e-06,3.330e-06,3.124e-06,2.925e-06,2.498e-06,2.078e-06, $
 1.671e-06,1.314e-06,9.998e-07,7.448e-07,5.376e-07,3.799e-07,2.601e-07,1.708e-07, $
 1.098e-07,6.766e-08,4.040e-08,2.338e-08,4.824e-09,8.066e-10,1.093e-10,1.080e-11, $
 5.419e-06,3.730e-06 ]
os=sort(ws) & ol=sort(wl)                            ; Sort data
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol)
wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl & n=n+1 ; Load array 14

; Transfer function measurements for GOES-15:
; data suppled by Rodney Viereck 2013 Feb
; wavelength values are the same, just need to re-order tables
; to move .358, 2.59 pairs to end of ws, 3.87 pair to end of wl
ws=[.1+.1*findgen(35),3.6+.2*findgen(8),5.5,6,7,8,.35799,.35801,2.5889,2.5901] 
wl=[.2+.2*findgen(32),6.8+.4*findgen(14),13+findgen(4),3.8699,3.8701]
ts = [ $
   1.171e-07,5.818e-07,1.249e-06,9.328e-07,1.680e-06,2.703e-06,3.976e-06,$
   5.462e-06,7.092e-06,8.815e-06,1.058e-05,1.223e-05,1.374e-05,1.501e-05,$
   1.576e-05,1.660e-05,1.718e-05,1.740e-05,1.744e-05,1.729e-05,1.687e-05,$
   1.654e-05,1.563e-05,1.509e-05,1.384e-05,1.033e-05,1.022e-05,9.902e-06,$
   9.656e-06,9.317e-06,8.897e-06,8.385e-06,7.876e-06,7.296e-06,6.747e-06,$
   6.100e-06,4.951e-06,3.873e-06,2.928e-06,2.140e-06,1.501e-06,1.020e-06,$
   6.665e-07,1.944e-07,4.356e-08,9.851e-10,5.716e-12,1.569e-06,6.971e-07,$
   1.337e-05,1.041e-05]
tl = [ $
   1.756e-08,1.258e-07,3.772e-07,8.139e-07,1.384e-06,2.094e-06,2.883e-06,$
   3.669e-06,4.376e-06,4.939e-06,5.341e-06,5.583e-06,5.698e-06,5.713e-06,$
   5.670e-06,5.581e-06,5.467e-06,5.334e-06,5.190e-06,3.644e-06,3.767e-06,$
   3.852e-06,3.894e-06,3.898e-06,3.857e-06,3.784e-06,3.680e-06,3.547e-06,$
   3.392e-06,3.217e-06,3.027e-06,2.842e-06,2.442e-06,2.046e-06,1.659e-06,$
   1.316e-06,1.012e-06,7.619e-07,5.566e-07,3.985e-07,2.767e-07,1.845e-07,$
   1.206e-07,7.566e-08,4.606e-08,2.720e-08,5.952e-09,1.063e-09,1.552e-10,$
   1.671e-11,5.138e-06,3.536e-06]
os=sort(ws) & ol=sort(wl)                            ; Sort data
ws=ws(os) & wl=wl(ol) & ts=ts(os) & tl=tl(ol)
wsm(0,n)=ws & wlm(0,n)=wl & tsm(0,n)=ts & tlm(0,n)=tl & n=n+1 ; Load array 15

;--------------------------------------------------------------------------
v=where(tsm ne 0) & tsm(v)=alog10(tsm(v)) 
v=where(tlm ne 0) & tlm(v)=alog10(tlm(v))    ; Start polynomial fitting 
 
e1=.3584 & e2=2.587 & e3=3.870               ; Measurement wavelength edges 
for n=4,nsat-1 do begin 
  w=wsm(*,n) & if n ge 9 then begin & e1=.3580 & e2=2.589 & endif 
  v=where(w gt 0  and w le e1) & x=w(v) & y=tsm(v,n) ; 1st segment of short 
  c=poly_fit(x,y,2,/d) & coeff(n,0,0:2)=c(*) 
  v=where(w gt e1 and w le e2) & x=w(v) & y=tsm(v,n) ; 2nd segment of short 
  c=poly_fit(x,y,4,/d) & coeff(n,1,0:4)=c(*) 
  v=where(w gt e2)             & x=w(v) & y=tsm(v,n) ; 3rd segment of short 
  c=poly_fit(x,y,4,/d) & coeff(n,2,0:4)=c(*) 
 w=wlm(*,n) 
  v=where(w gt 0  and w le e3) & x=w(v) & y=tlm(v,n) ; 1st segment of long 
  c=poly_fit(x,y,6,/d) & coeff(n,3,0:6)=c(*) 
  v=where(w gt e3)             & x=w(v) & y=tlm(v,n) ; 2nd segment of long 
  c=poly_fit(x,y,4,/d) & coeff(n,4,0:4)=c(*) 
 endfor 
 
for n=0,3 do coeff(n,*,*)=coeff(4,*,*) 
 
save,file=file,edge,coeff,gbshort,gblonga,gblongb    ; Save results 
print,'  Results saved in  '+file 
 
next: 
if anytim(fcheck(date,2e8),/sec) ge 1.416096e8 then gblong=gblonga $ 
                                               else gblong=gblongb 
end

;------------------------ goes_tf.pro ---------------------------

;+ 
; NAME:    GOES_TF 
; 
; PURPOSE: 
; This procedure returns the fitted Transfer Functions for one pair of 
; GOES XRS soft X-ray spectrometers, depending on which satellite is 
; selected (the default is GOES-1).  Note that the returned functions 
; are identical for GOES-1 through GOES-5, though individual G-bar values 
; are given for each satellite in the GOES series (except GOES-3, for 
; which data are not available; GOES-2 values are returned for it). 
; The Transfer Function fits must first be computed by GOES_TF_COEFF. 
; 
; CATEGORY: 
;  GOES, SPECTRAL ANALYSIS 
; 
; CALLING SEQUENCE: 
;  goes_tf, sat_number, date='1988/11/22', wavescale=w, $ 
;         tfshort=ts, tflong=tl, gbshort=gs, gblong=gl, $ 
;         file='C:\Data\goes_tf_coeff.sav' 
; 
; 
; INPUTS:  SAT_NUMBER    GOES satellite number to be used. [ default = 1 ] 
; 
; KEYWORD PARAMETERS: 
;  WAVESCALE     The wavelength scale [in A] for both Transfer Functions. 
;                 (If not provided, a default wavelength set is returned.) 
;  TFSHORT       Transfer function [in Amp/(Watt/meter^2)] for short channel. 
;  TFLONG        Transfer function [in Amp/(Watt/meter^2)] for long channel. 
;  GBSHORT       Conversion parameter (G-bar) for short channel. 
;  GBLONG        Conversion parameter (G-bar) for long channel. 
;  FILE          Filename in which results of GOES_TF_COEFF are stored 
;                   [ def = 'C:\Data\goes_tf_coeff.sav' ] 
;  DATE          Time in ANYTIM format, used for GOES-6 which had a change 
;                   in its value of GBLONG on 1983 June 28. [ def = after ] 
; OUTPUTS: 
;  In keyword format, so that the output order does not matter. 
; 
; PROCEDURE: 
; Transfer Functions are defined in five wavelength segments, as follows: 
;   Seg 0    wave lt W1              TF_short = 10^(poly(wave,coeff(sat-1,0,*))) 
;   Seg 1    wave ge W1 and lt W2    TF_short = 10^(poly(wave,coeff(sat-1,1,*))) 
;   Seg 2    wave ge W2              TF_short = 10^(poly(wave,coeff(sat-1,2,*))) 
;   Seg 3    wave lt W3              TF_long  = 10^(poly(wave,coeff(sat-1,3,*))) 
;   Seg 4    wave ge W3              TF_long  = 10^(poly(wave,coeff(sat-1,4,*))) 
; 
;  where  W1,W2,W3, & COEFF  are restored from a file created by GOES_TF_COEFF. 
; 
; COMMON BLOCKS:  None. 
; 
; MODIFICATION HISTORY: 
;  Roger.J.Thomas@nasa.gov, 2003 July 25. 
;  S White: added GOES 12 June 2004
;  S White: added GOES 15 Feb  2013
;- 
 
pro goes_tf, satnum, date=date, wavescale=w, file=file, $ 
         tfshort=ts, tflong=tl, gbshort=gs,  gblong=gl 
 
; Which version of GOES? 
if n_elements(satnum) eq 0  then satnum=8   ; Default is GOES-8 
if satnum lt 1 or satnum gt 15 then begin 
  print,'Only satellite numbers 1 - 15 are presently supported!' 
  goto,exit 
  endif 
 
if n_elements(w) eq 0 then w=dindgen(9991)/100+.1 ; Default [.1-100A, dw=.01A] 
 
goes_tf_coeff,e=e,c=c,gbs=gs,gbl=gl,date=date,file=file ; Get TF coeffs 
n=satnum-1 & c=c(n,*,*) & gs=gs(n) & gl=gl(n)    ; for requested satellite 
ts=w & tl=w & c=reform(c) 
v=where(w lt e(0))               & ts(v)=poly(w(v),c(0,*)) ; 1st seg short 
v=where(w ge e(0) and w lt e(1)) & ts(v)=poly(w(v),c(1,*)) ; 2nd 
v=where(w gt e(1))               & ts(v)=poly(w(v),c(2,*)) ; 3rd 
v=where(w lt e(2))               & tl(v)=poly(w(v),c(3,*)) ; 1st seg long 
v=where(w ge e(2))               & tl(v)=poly(w(v),c(4,*)) ; 2nd 
 
ts=10^(ts>(-222)) & tl=10^(tl>(-222)) 
 
exit: 
end

;------------------------ fold_spec_resp.pro ---------------------------

;+
; PROJECT:
;     GOES
;
; PURPOSE:
;     Generate GOES responses by folding CHIANTI spectra with wavelength 
;     responses of individual satellites.
;
; CALLING SEQUENCE:
;       fold_spec_resp , NSAT [, /PLOTSPEC ]
;
; INPUTS:
;       NSAT = number of GOES satellites
;       Set /PLOTSPEC if you want results plotted as they are derived
;
; OUTPUTS:
;       Individual save files containing temperature responses etc in files
;       idlsave.fit_coeffs_.02_GOES_<SAT> for each of 12 SATs.
;
; PROCEDURE:
;     Calls MAKE_CHIANTI_SPEC 
;
; MODIFICATION HISTORY:
;     SW 2005 Jan
;-
;
pro fold_spec_resp, nsat, plotspec=plotspec

; get chianti version
chianti_version, vers

dosave=1         ; save in IDL save set?
if not keyword_set(plotspec) then plotspec=0

; make sure it can find goes_tf_coeff.dat
if not (file_exist('goes_tf_coeff.dat')) then $
   goes_tf_coeff, /new , file='goes_tf_coeff.dat'

for sat=1,nsat do begin ; GOES satellite number

 ; extract wavelength scale
 
 fl=findfile('ch'+vers+'_pho_3e10_1e27_*genx')
 nf=n_elements(fl)
 restgen, file=fl[0],struct=spc
 
 ; extract transfer curves for GOES
 
 print,sat
 goes_tf, sat, wavescale=spc.lambda, tfshort=ts, tflong=tl, gbshort=gs, $
    gblong=gl, file='goes_tf_coeff.dat'
 
 ; integrate line and continuum contributions and compare
 
 fshort_pho=dblarr(nf) & flong_pho=fshort_pho
 for i=0,nf-1 do begin
    restgen, file=fl[i],struct=spc
    if (plotspec) then begin
       plot,spc.lambda,ts*spc.spectrum,psym=10
       oplot,spc.lambda,tl*spc.spectrum,psym=10
    endif
    ; integrate continuum
    fshort_pho[i]=int_tabulated(spc.lambda,ts*spc.spectrum)/gs
    flong_pho[i]=int_tabulated(spc.lambda,tl*spc.spectrum)/gl
 end
 
 fl=findfile('ch'+vers+'_cor_3e10_1e27_*genx')
 fshort_cor=dblarr(nf) & flong_cor=fshort_cor
 for i=0,nf-1 do begin
    restgen, file=fl[i],struct=spc
    if (plotspec) then begin
       plot,spc.lambda,ts*spc.spectrum,psym=10
       oplot,spc.lambda,tl*spc.spectrum,psym=10
    endif
    ; integrate continuum
    fshort_cor[i]=int_tabulated(spc.lambda,ts*spc.spectrum)/gs
    flong_cor[i]=int_tabulated(spc.lambda,tl*spc.spectrum)/gl
 end
 
 plot,flong_cor,fshort_cor
 oplot,flong_pho,fshort_pho,linestyle=2
 
 temp=6.0+0.02*indgen(nf)
 plot,temp,fshort_cor/flong_cor,xrange=[6.5,7.5]
 oplot,temp,fshort_pho/flong_pho
 
 ; plot T vs R as in Thomas Starr Crannell
 plot,fshort_cor/flong_cor,temp,xrange=[0.001,1.0],yrange=[6.0,8.0]
 oplot,fshort_pho/flong_pho,temp,linestyle=1
 ratfac=.01*(1+indgen(51))
 tfac=alog10(1.e6*(3.15+77.2*ratfac-164.*ratfac^2+205.*ratfac^3))
 oplot,ratfac,tfac,linestyle=2
 
 ; to convert back to the TSC formalism, we note:
 ; - divide by 10^27 which is column EM assumed by CHIANTI
 ; - divide by 1.496e13 ^ 2 to convert to solar distance
 ; no factor for integration over wavelength in Angstroms: unit is per A
 ; multiply by 1.e-3 to convert from ergs/cm^2/s to Watts/cm^2
 
 cvac=1.d-27*1.d-3/((1.496d13)^2)
 b4_cor=cvac*double(fshort_cor[30:80])*1.d55
 b8_cor=cvac*double(flong_cor[30:80])*1.d55
 b4_pho=cvac*double(fshort_pho[30:80])*1.d55
 b8_pho=cvac*double(flong_pho[30:80])*1.d55
 r_cor=b4_cor/b8_cor
 r_pho=b4_pho/b8_pho
 
 ltemp=10^(0.02*(30+indgen(51)))
 
 plot,ltemp,r_cor,xtitle='Temp',ytitle='b4/b8'
 oplot,ltemp,r_pho,linestyle=2
 
 ; weight errors by R value
 cor_tcor=poly_fit(r_cor,ltemp,3,yfit=yfit)
 plot,r_cor,ltemp & oplot,r_cor,yfit,linestyle=2
 pho_tcor=poly_fit(r_pho,ltemp,3,yfit=yfit)
 plot,r_pho,ltemp & oplot,r_pho,yfit,linestyle=2
 
 cor_b8cor=poly_fit(ltemp,b8_cor,3,yfit=yfit)
 plot,ltemp,b8_cor & oplot,ltemp,yfit,linestyle=2
 pho_b8cor=poly_fit(ltemp,b8_pho,3,yfit=yfit)
 plot,ltemp,b8_pho & oplot,ltemp,yfit,linestyle=2
 
 if (dosave) then save,$
    filename='idlsave.fit_coeffs_.02_GOES_'+strtrim(string(sat),2),$
    cor_tcor, pho_tcor, cor_b8cor, pho_b8cor,$
    ltemp, b4_cor, b4_pho, b8_cor, b8_pho, $
    fshort_cor, fshort_pho, flong_cor, flong_pho
 
end ; loop over satellites

end

;-------------------------- tables_02_to_pro ------------------------

;+
; PROJECT:
;     GOES
;
; PURPOSE:
;     Generate goes_get_chianti_temp.pro and goes_get_chianti_em.pro in /tmp
;
; CATEGORY:
;       GOES
;
; CALLING SEQUENCE:
;       tables_.02_to_pro, nsat
;
; INPUTS:
;       NSAT = number of satellites
;
; OUTPUTS:
;       Routines goes_get_chianti_temp.pro and goes_get_chianti_em.pro
;       ARE WRITTEN TO /TMP FOR SAFETY
;
; MODIFICATION HISTORY:
;     SW 2005 Jan
;-
;
pro tables_02_to_pro, nsat

print,''
print,'Writing routines /tmp/goes_get_chianti_temp.pro, /tmp/goes_get_chianti_em.pro'
print,''

openw,1,'/tmp/goes_get_chianti_temp.pro'
openw,2,'/tmp/goes_get_chianti_em.pro'

; print headers
chianti_version, vers
today, date

;----------------------------- goes_get_chianti_temp header --------------

printf,1,';+'
printf,1,'; Project:'
printf,1,';     SDAC'
printf,1,'; Name:'
printf,1,';     GOES_GET_CHIANTI_TEMP'
printf,1,';'
printf,1,'; Usage:'
printf,1,';     goes_get_chianti_temp, ratio, temperature, sat=goes, /photospheric, r_cor=r_cor, r_pho=r_pho'
printf,1,';'
printf,1,';Purpose:'
printf,1,';     Called by GOES_CHIANTI_TEM to derive temperature and emission measures.'
printf,1,';     This procedures computes the temperature of solar plasma from the'
printf,1,';     ratio B4/B8 of the GOES 0.5-4 and 1-8 Angstrom fluxes'
printf,1,';     using CHIANTI spectral models with coronal or photospheric abundances'
printf,1,';     All background subtraction, smoothing, etc, is done outside (before)'
printf,1,';     this routine. Default abundances are coronal.'
printf,1,';     WARNING: fluxes are asssumed to be TRUE fluxes, so corrections'
printf,1,';     such as the (0.70,0.85) scaling of GOES 8-12 must be applied before'
printf,1,';     use of this routine. GOES_CHIANTI_TEM applies these corrections.'
printf,1,';'
printf,1,';Category:'
printf,1,';     GOES, SPECTRA'
printf,1,';'
printf,1,';Method:'
printf,1,';     From the ratio the temperature is computed'
printf,1,';     from a spline fit from a lookup table for 101 temperatures logT=.02 apart.'
printf,1,';'
printf,1,';Inputs:'
printf,1,';     RATIO - Ratio of GOES channel fluxes, B4/B8'
printf,1,';'
printf,1,';Keywords:'
printf,1,';     sat  - GOES satellite number, needed to get the correct response'
printf,1,';     photospheric - use photospheric abundances rather than the default'
printf,1,';             coronal abundances'
printf,1,';'
printf,1,';Outputs:'
printf,1,';     TEMP - GOES temperature derived from GOES_GET_CHIANTI_TEMP in units of MK'
printf,1,';     R_COR, R_PHO: coefficients for spline fits'
printf,1,';'
printf,1,';Common Blocks:'
printf,1,';     None.'
printf,1,';'
printf,1,';Needed Files:'
printf,1,';     None'
printf,1,';'
printf,1,'; MODIFICATION HISTORY:'
printf,1,';     Stephen White, 24-Mar-2004: Initial version based on CHIANTI 4.2'
printf,1,';     This routine created '+date+' using CHIANTI version '+vers
printf,1,';'
printf,1,'; Contact     : Richard.Schwartz@gsfc.nasa.gov'
printf,1,';'
printf,1,';-'
printf,1,';-------------------------------------------------------------------------'
printf,1,''
printf,1,'pro goes_get_chianti_temp, r, temp, sat=sat, photospheric=photospheric'
printf,1,''
printf,1,'; interpolate tables of temp versus b4/b8 to get temp for given ratio'
printf,1,'; using findex data values are responses to CHIANTI spectra for coronal'
printf,1,'; and photospheric abundance'
printf,1,'; default is coronal abundance'
printf,1,''
printf,1,'r_cor=fltarr('+strtrim(string(nsat),2)+',101)     ; ratio vs temp for each of '+strtrim(string(nsat),2)+' GOES satellites'
printf,1,''

;----------------------------- goes_get_chianti_em header --------------

printf,2,';+'
printf,2,'; Project:'
printf,2,';     SDAC'
printf,2,'; Name:'
printf,2,';     GOES_GET_CHIANTI_EM'
printf,2,';'
printf,2,'; Usage:'
printf,2,';     goes_get_chianti_em, fl, temperature, emission_meas, sat=goes, /photospheric'
printf,2,';'
printf,2,';Purpose:'
printf,2,';     Called by GOES_CHIANTI_TEM to derive temperature and emission measures.'
printf,2,';     This procedures computes the emission measure of solar plasma from the'
printf,2,';     temperature derived from the B4/B8 ratio together with the flux B8 in the'
printf,2,';     1-8 Angstrom channel using CHIANTI spectral models with coronal or'
printf,2,';     photospheric abundances'
printf,2,';     WARNING: fluxes are asssumed to be TRUE fluxes, so corrections'
printf,2,';     such as the (0.70,0.85) scaling of GOES 8-12 must be applied before'
printf,2,';     use of this routine. GOES_CHIANTI_TEM applies these corrections.'
printf,2,';'
printf,2,';Category:'
printf,2,';     GOES, SPECTRA'
printf,2,';'
printf,2,';Method:'
printf,2,';     From the temperature the emission measure per unit B8 flux is computed'
printf,2,';     from a spline fit from a lookup table for 101 temperatures logT=.02 apart'
printf,2,';'
printf,2,';Inputs:'
printf,2,';     FL - GOES long wavelength flux in Watts/meter^2'
printf,2,';     TEMP - GOES temperature derived from GOES_GET_CHIANTI_TEMP in units of MK'
printf,2,';'
printf,2,';Keywords:'
printf,2,';     sat  - GOES satellite number, needed to get the correct response'
printf,2,';     photospheric - use photospheric abundances rather than the default'
printf,2,';             coronal abundnaces'
printf,2,';'
printf,2,';Outputs:'
printf,2,';     Emission_meas - Emission measure in units of cm-3 (i.e., NOT scaled)'
printf,2,';'
printf,2,';Common Blocks:'
printf,2,';     None.'
printf,2,';'
printf,2,';Needed Files:'
printf,2,';     None'
printf,2,';'
printf,2,'; MODIFICATION HISTORY:'
printf,2,';     Stephen White, 24-Mar-2004: Initial version based on CHIANTI 4.2'
printf,2,';     This routine created '+date+' using CHIANTI version '+vers
printf,2,';'
printf,2,'; Contact     : Richard.Schwartz@gsfc.nasa.gov'
printf,2,';'
printf,2,';-'
printf,2,';-------------------------------------------------------------------------'
printf,2,''
printf,2,'pro goes_get_chianti_em, b8, temp, em, sat=sat, photospheric=photospheric'
printf,2,''
printf,2,'; interpolate tables of b8 vs temp to determine emission measure'
printf,2,'; in units of cm^-3. Data values are responses to CHIANTI spectra for'
printf,2,'; coronal and photospheric abundance'
printf,2,''
printf,2,'b8_cor=fltarr('+strtrim(string(nsat),2)+',101)     ; responses for 101 temps for each of '+strtrim(string(nsat),2)+' GOES satellites'
printf,2,''

; ------------------------------- end of headers -------------------------

for sat=1,nsat do begin
   restore,'idlsave.fit_coeffs_.02_GOES_'+strtrim(string(sat),2)
   ; produce ratios
   r_cor = FSHORT_COR/FLONG_COR
   r_pho = FSHORT_PHO/FLONG_PHO
   printf,1,'r_cor['+strtrim(string(sat-1),2)+',*]=[',r_cor[0:7],"$",$
      format='(a13,8(e8.2,","),a1)'
   printf,1,"   ",r_cor[8:16],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_cor[17:25],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_cor[26:34],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_cor[35:43],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_cor[44:52],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_cor[53:61],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_cor[62:70],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_cor[71:79],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_cor[80:88],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_cor[89:97],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_cor[98:100],format = '(a3,2(e8.2,","),e8.2,"]")'
end
   
printf,1,''
printf,1,'r_pho=fltarr('+strtrim(string(nsat),2)+',101)'
printf,1,''
for sat=1,nsat do begin
   restore,'idlsave.fit_coeffs_.02_GOES_'+strtrim(string(sat),2)
   ; produce ratios
   r_cor = FSHORT_COR/FLONG_COR
   r_pho = FSHORT_PHO/FLONG_PHO
   printf,1,'r_pho['+strtrim(string(sat-1),2)+',*]=[',r_pho[0:7],"$",$
      format='(a13,8(e8.2,","),a1)'
   printf,1,"   ",r_pho[8:16],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_pho[17:25],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_pho[26:34],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_pho[35:43],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_pho[44:52],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_pho[53:61],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_pho[62:70],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_pho[71:79],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_pho[80:88],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_pho[89:97],"$",format='(a3,9(e8.2,","),a1)'
   printf,1,"   ",r_pho[98:100],format = '(a3,2(e8.2,","),e8.2,"]")'
end

for sat=1,nsat do begin
   restore,'idlsave.fit_coeffs_.02_GOES_'+strtrim(string(sat),2)
   ; produce ratios
   b8_cor = double(flong_cor)*1.d-27*1.d-3/((1.496d13)^2)*1.d55
   printf,2,'b8_cor['+strtrim(string(sat-1),2)+',*]=[',b8_cor[0:7],"$",$
      format='(a14,8(e8.2,","),a1)'
   printf,2,"    ",b8_cor[8:16],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_cor[17:25],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_cor[26:34],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_cor[35:43],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_cor[44:52],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_cor[53:61],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_cor[62:70],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_cor[71:79],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_cor[80:88],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_cor[89:97],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_cor[98:100],format = '(a4,2(e8.2,","),e8.2,"]")'
end

printf,2,''
printf,2,'b8_pho=fltarr('+strtrim(string(nsat),2)+',101)'
printf,2,''
for sat=1,nsat do begin
   restore,'idlsave.fit_coeffs_.02_GOES_'+strtrim(string(sat),2)
   ; produce ratios
   b8_pho = double(flong_pho)*1.d-27*1.d-3/((1.496d13)^2)*1.d55
   printf,2,'b8_pho['+strtrim(string(sat-1),2)+',*]=[',b8_pho[0:7],"$",$
      format='(a14,8(e8.2,","),a1)'
   printf,2,"    ",b8_pho[8:16],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_pho[17:25],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_pho[26:34],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_pho[35:43],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_pho[44:52],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_pho[53:61],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_pho[62:70],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_pho[71:79],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_pho[80:88],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_pho[89:97],"$",format='(a4,9(e8.2,","),a1)'
   printf,2,"    ",b8_pho[98:100],format = '(a4,2(e8.2,","),e8.2,"]")'
end

;----------------------------- goes_get_chianti_temp header --------------

printf,1,''
printf,1,'if keyword_set(sat) then gsat=fix(sat-1)>0<'+string(nsat-1,format='(i2)')+' else gsat=8-1 ; subtract 1 to get array index'
printf,1,'if keyword_set(photospheric) then rdat=reform(r_pho[gsat,*]) else rdat=reform(r_cor[gsat,*])'
printf,1,''
printf,1,'; simplest version: linear interpolation is not as good as it needs to be:'
printf,1,'; inx=findex(rdat,r)'
printf,1,"; if (inx[0] gt 0.0) then print,'Quick: ',10^(inx[0]*0.05) else temp=1.0"
printf,1,''
printf,1,'; do spline fit instead'
printf,1,''
printf,1,'logtemp=findgen(101)*0.02       ; temp in MK as in goes_tem'
printf,1,'int_ftn=spl_init(rdat,logtemp,/double)'
printf,1,'; make sure ratio is within fitted range'
printf,1,'temp=10.d0^(spl_interp(rdat,logtemp,int_ftn,(r>min(rdat))<max(rdat),/double))'
printf,1,''
printf,1,"; print,'Spline result: ',temp"
printf,1,''
printf,1,'end'

;----------------------------- goes_get_chianti_em header --------------

printf,2,''
printf,2,'if keyword_set(sat) then gsat=fix(sat-1)>0<'+string(nsat-1,format='(i2)')+' else gsat=8-1 ; subtract 1 to get array index'
printf,2,'if keyword_set(photospheric) then b8dat=reform(b8_pho[gsat,*]) else b8dat=reform(b8_cor[gsat,*])'
printf,2,''
printf,2,'; do spline fit'
printf,2,''
printf,2,'logtemp=findgen(101)*0.02d0     ; temp in MK as in goes_tem'
printf,2,'b8_ftn=spl_init(logtemp,b8dat,/double)'
printf,2,'denom=spl_interp(logtemp,b8dat,b8_ftn,alog10(temp),/double)'
printf,2,'; print,denom'
printf,2,"; print,'Spline result: ',temp"
printf,2,'; assume that B8 = flux is in W/m^2, calibrate accordingly'
printf,2,'em=1.d55*b8/denom'
printf,2,''
printf,2,'end'
;----------------------------- end goes_get_chianti_em header --------------

close,1
close,2

print,'Finished writing routines.'
print,''

end

;------------------------------ master routine -----------------------------

pro make_goes_chianti_response

 ; generate spectra
 generate_spectra        ; coronal
 generate_spectra, /photospheric 

 ; fold spectra with GOES responses for each satellite
 nsat=15             ; current number of satellites in goes_tf_coeff
 fold_spec_resp, nsat

 ; create new routines
 tables_02_to_pro, nsat

end
