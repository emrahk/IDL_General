pro bsc_struct, BSC_Index = BSC_Index,  $
                     FIT_BSC = FIT_BSC,  $
                     BSC_RoadMap = BSC_RoadMap,  $
                     BSC_Version = BSC_Version
   
   
;+
;       NAME:
;               BSC_STRUCT
;       PURPOSE:
;               Define the following BSC specific database structures
;                       * BSC_Index_Rec            
;                       * BSC_Roadmap_Rec          
;                       * FIT_BSC_Rec
;
;       CALLING SEQUENCE:
;               BSC_STRUCT
;       HISTORY:
;               written by Mons Morrison, R. Bentley, J. Mariska and D. Zarro, Fall 92
;       11-sep-93, JRL + DMZ, Added .valid_ans, .nstart and .nend fields (see **)
;        2-Oct-93 (MDM) - Changed the FIT structure a fair amount
;       13-Oct-93 (MDM) - Changed the FIT field from Num_inter to Num_iter
;        8-Nov-93 (MDM) - Changed comments
;        3-Feb-94 (MDM) - Added .SPACECRAFT to .BSC structure
;                       - Made a new FIT structure with .ION_MULT
;                       - Archived FIT_2041_BSC_Rec to BSC_OLD_STRUCT.INC
;        3-Feb-94 (MDM) - Added .DENSITY to .FIT
;        8-Aug-94 (MDM) - Added .DISPC and .U_DISPC to .FIT
;
;-
   
   
BSC_Index = { BSC_Index_Rec,              $
      index_version : FIX('2022'x),  $       ;
                                             ; 00- Index structure version
      spare1: BYTARR(2),  $                  ; 02 -Padding byte
      blockID: BYTE(0),  $                   ; 10- BCS Block ID                                              From BD
                                             ;      =0: Normal Queue Data Block
                                             ;      =1: Fast Queue Data Block
                                             ;      =2: Micro Dump Block (fixed extraction)
                                             ;          Reformatter forces this mode whenever the
                                             ;          CPU is disabled
                                             ;      =3: Cal Data Block (fixed extraction)
                                             ;      =4: Queue data where the modeID in the
                                             ;          header is not recognized.
                                             ;      =5: Normal or fast queue data which have fill
                                             ;          data (garabage).  Avoid this value to avoid
                                             ;          these datasets when making light curves.
      ModeID: BYTE(0),  $                    ; 11- Mode ID (Grouper Plan)                                    From BD
                                             ;       For "Normal" and "Fast" queue data
                                             ;       (BlockID = 0 or 1) this value is the
                                             ;       ModeID used in conjunction with the
                                             ;       grouper plan.
                                             ;
                                             ;       If the mode ID is not recognized, then
                                             ;       it is set to 255, and the mode header
                                             ;       is put out with the beginning of the 
                                             ;       data.
                                             ;
                                             ;       For "Cal Mode" (BlockID = 3)
                                             ;       this holds the channel number as
                                             ;       derived from PHA_CONTROL with a
                                             ;       1.5 major frame delay
                                             ;               b4:7 = first 256 bytes
                                             ;               b0:3 = last 256 bytes
                                             ;       Value = 1,2,3,4
                                             ;       Value = 0 if unknown (data dropouts)
      DP_Flags: BYTE(0),  $                  ; 12- DP Flags received by BCS                                  From BD
                                             ;       b0      = Radiation Belt monitor (set = yes)
                                             ;       b1,2    = 0,0: No flare
                                             ;               = 1,0: Normal Flare
                                             ;               = 1,1: Great Flare
                                             ;               = 0,1: BCS MEM Mode
                                             ;       b3,4    = 0,0: Low (1 kps)
                                             ;               = 1,0: Med (4 kps)
                                             ;               = 0,1: Hi (32 kps)
                                             ;               = 1,1: Hi (32 kps)
                                             ;       b5      = BCS-OUT after flare (set = enable)
                                             ;       b6      = BCS-OUT after night (set = enable)
                                             ;       b7      = Currently BCS-OUT mode 
      BCS_Status: BYTE(0),  $                ; 13- BCS Status                                                From BD
                                             ;       b0 = SAA Threshold exceeded (set = yes)
                                             ;       b1 = Flare threshold exceeded (set = yes)
                                             ;       b2 = HVU's turned off by BVS SAA algorithm
                                             ;       b3 = Fe XXVI thershold exceeded
                                             ;       b4 = BCS is in night state
                                             ;       b5 = BCS is in SAA state
                                             ;       b6 = Status of data in queue (set = hi)
                                             ;       b7 = Status of BCS flare flag (set = hi)
                                             ;
      chan: BYTE(0),  $                      ; 14- channel number                                            User In
                                             ;       1 = Fe XXVI
                                             ;       2 = Fe XXV
                                             ;       3 = Ca XIX
                                             ;       4 = S XV
      spare2: BYTE(0),  $                    ; 15 -Padding byte
      actim: LONG(0),  $                     ; 16- Accumulation time in ms                                   User In
      interval: LONG(0),  $                  ; 20- End time - start time in ms                               Derived
                                             ;     (matches "actim" if no missing data)
      cnt_thresh: LONG(0),  $                ; 24- Count threshold used to control accumulation (millisec)   User In
                                             ;       0 = no threshold set (use actim)
                                             ;
      dgi: BYTE(0),  $                       ; 28- Data Gather Interval (125 msec units)                     From BD
      spare3: BYTE(0),  $                    ; 29 -Padding byte
      nBin: FIX(0),  $                       ; 30- Number of bins for selected channel                       Defined
      nSpec: FIX(0),  $                      ; 32- Number of spectra in accumulation                         Derived
                                             ;
                                             ;
      spare4: BYTARR(2),  $                  ; 34 -Padding byte
      total_cnts: FLOAT(0),  $               ; 36- Total counts in the selected channel for actim            Derived
      max_cps: FLOAT(0),  $                  ; 40- Maximum counts per second of limited counts from          Derived
                                             ;     dp_sync for the channel
      dp_sync_dpf: BYTE(0),  $               ; 44- DP_SYNC data presence flag                                Derived
                                             ;       0 = did not check, unknown
                                             ;       1 = full data over accumulation interval
                                             ;       2 = partial data over accumulation interval
                                             ;       3 = interpolated
                                             ;       4 = derived by fitting
      spare5: BYTARR(3),  $                  ; 45 -Padding byte
      sc_pntg: LONARR(3),  $                 ; 48- Average spacecraft pointing offset from Sun center?       From PN
                                             ;     (copy of ADS value from PNT file, 0.1 arc sec per unit)
                                             ;       (0) = E/W (W is positive?)
                                             ;       (1) = N/S (N is positive)
                                             ;       (2) = roll
      sc_pntg_dev: FLTARR(3),  $             ; 60- RMS deviation of above over the accumulation interval     Derived
      sc_pntg_dpf: BYTE(0),  $               ; 72- Pointing data availability flag                           Derived
                                             ;       0 = did not check, unknown
                                             ;       1 = full data over accumulation interval
                                             ;       2 = partial data over accumulation interval
                                             ;       3 = ?
      spare6: BYTE(0),  $                    ; 73 -Padding byte
      offset: INTARR(2),  $                  ; 74- Source location in heliocentric coordinates               User In
                                             ;     (arc second units)
                                             ;       (0) = E/W (W is positive?)
                                             ;       (1) = N/S (N is positive)
      offset_dpf: BYTE(0),  $                ; 78- Offset data presence flag                                 User In
                                             ;       0 = none
                                             ;       1 = SXT PFI
                                             ;       2 = SCT FFI manual pointing
                                             ;       3 = H alpha manual pointing
                                             ;       4 = HXI
                                             ;       5 = ...
                                             ;
      despike_ans: BYTE(0),  $               ; 79-                                                           User In
      deadtime_ans: BYTE(0),  $              ; 80- deadtime correction answer                                User In
                                             ;       0 = no correction done
                                             ;       1 = using ?? routine
                                             ;       2 = ...
      curve_ans: BYTE(0),  $                 ; 81-                                                           User In
      linearity_ans: BYTE(0),  $             ; 82-                                                           User In
      waveDisp_ans: BYTE(0),  $              ; 83-                                                           User In
      narrowLine_ans: BYTE(0),  $            ; 84-                                                           User In
      pntg_ans: BYTE(0),  $                  ; 85-                                                           User In
      offset_ans: BYTE(0),  $                ; 86-                                                           User In
      rebin_ans: BYTE(0),  $                 ; 87-                                                           User In
      physUnits_ans: BYTE(0),  $             ; 88-                                                           User In
                                             ;
                                             ;
      valid_ans: BYTE(0),  $                 ; 89 -1 means valid bins have been extracted. 0 is raw data     User In
      nstart: BYTE(0),  $                    ; 90 -First Valid Bin in raw data      (if changed, then update FIT_RAN
      nend: BYTE(0),  $                      ; 91 -Last Valid Bin in raw data                                       
                                             ;
                                             ;
      length: FIX(0),  $                     ; 92- The number of points in the spectra.  It might not
                                             ;     match the "nbin" field for the cases where the spectra
                                             ;     is "stretched" and new bins are created
      dataRecTypes: FIX(0),  $               ; 94- Type of data the is included in the data portion
                                             ;       b0 = counts (spectra)                           .COUNTS
                                             ;       b1 = bin address                                .BIN
                                             ;       b2 = uncertainty of counts (units?)             .ERROR
                                             ;       b3 = Unused (shuffled .fit to .flux_fit)        .JUNK
                                             ;       b4 = wavelength array                           .WAVE (start va
                                             ;       b5 = flux calibrated data                       .FLUX
                                             ;       b6 = Actual wavelength array (from FIT_BSC)     .WAVE_FIT
                                             ;       b7 = fitted spectra                             .FLUX_FIT
                                             ;       b8 = fitted spectrum for a secondary component  .FLUX_FIT2
                                             ;
      calfil_vers: BYTE(0),  $               ;102- version number of BCS CALFIL used to correct spectra
      spare7: BYTARR(1),  $                  ;103 -Padding byte                                                     
                                             ;
      st$spacecraft: BYTARR(3),  $           ;104- Identification of the spacecraft from
                                             ;       which the data originated
                                             ;       Valid Options are:
                                             ;               SMM, P78, HIN, YOH (Yohkoh, Solar-A),
                                             ;               Gnd (Ground testing)
      spare: BYTARR(17) }                    ;107- Spare bytes
   
   
   
FIT_BSC = { FIT_BSC_Rec,              $
      index_version : FIX('2042'x),  $       ;
                                             ;
      z: FIX(0),  $                          ;  2- Atomic Number
      st$elem: BYTARR(16),  $                ;  4- Element (string)
      chan: BYTE(0),  $                      ; 20- channel number    
                                             ;       1 = Fe XXVI
                                             ;       2 = Fe XXV
                                             ;       3 = Ca XIX
                                             ;       4 = S XV
      st$spacecraft: BYTARR(3),  $           ; 21- Identification of the spacecraft from
                                             ;       which the data originated
                                             ;       Valid Options are:
                                             ;               SMM, P78, HIN, YOH (Yohkoh, Solar-A),
                                             ;               Gnd (Ground testing)
                                             ;
                                             ;-------------------- Fitting Specific parameters --------------------
                                             ;
      Fit_level: FIX(0),  $                  ; 24- Level of Fitting (0=No fit, 1=First guess)
      Fit_attempt: FIX(0),  $                ; 26- Next highest level attempted (if fit_attempt gt fit_level, fittin
      Chi2: FLOAT(0),  $                     ; 28- Total Chi^2
      NFree: FIX(0),  $                      ; 32- Number of degrees of freedom
      Nparams: FIX(0),  $                    ; 34- Number of parameters allowed to vary
      Num_iter: FIX(0),  $                   ; 36- Number of iterations
      Ncomp_req : FIX(1),  $                 ; 38- Number of components requested in fit (1 or 2)
      Ncomp_fit: FIX(0),  $                  ; 40- Number of components actually fit (1 or 2)
      Fit_model: FIX(0),  $                  ; 42- Fit model (0=no contraints or links)
      Fit_flags: INTARR(10),  $              ; 44- Fit flags (e.g. fit_flag(i) = -1 ---> i'th parameter was not vari
                                             ;                                =  0 ---> i'th parameter was fit
                                             ;                                =  j ---> i'th parameter was linked to
      Fit_range: INTARR(2,3)+(-1),  $        ; 64- Fit range = indicies of wavelength ranges used in fit and chi2 ca
                                             ;    (up to 3 ranges for each of 2 components)
      spare1: BYTARR(4),  $                  ; 76- Padding
                                             ;
                                             ;-------------------- Fitting parameters --------------------
                                             ;
      Te6: FLOAT(0),  $                      ; 80- (1)  Electron Temperature main component (MK)
      Td6: FLOAT(0),  $                      ; 84- (2)  Doppler  Temperature main component (MK)
      EM50: FLOAT(0),  $                     ; 88- (3)  Emission measure of main component  (cm-3)
      wshift: FLOAT(0),  $                   ; 92- (4)  Source position wavelength shift (Ang)
      cnorm : FLOAT(1),  $                   ; 96- (5)  Continuum normalization factor 
      Te6_s: FLOAT(0),  $                    ;100- (6)  Electron Temperature of 2nd component (MK)
      Td6_s: FLOAT(0),  $                    ;104- (7)  Doppler  Temperature of 2nd component (MK)
      EM50_s: FLOAT(0),  $                   ;108- (8)  Emission measure of 2nd component (cm-3)
      Vel: FLOAT(0),  $                      ;112- (9)  Velocity 2nd relative to 1st (km/s, negative is blueshift)
      spare2: FLOAT(0),  $                   ;116-(10) Reserved for future use
                                             ;
                                             ;-------------------- Uncertainties in Fitting parameters -------------
                                             ;
      u_Te6: FLOAT(0),  $                    ;120- (1)  Electron Temperature main component (MK)
      u_Td6: FLOAT(0),  $                    ;124- (2)  Doppler  Temperature main component (MK)
      u_EM50: FLOAT(0),  $                   ;128- (3)  Emission measure of main component (cm-3)
      u_wshift: FLOAT(0),  $                 ;132- (4)  Source position wavelength shift (Ang)
      u_cnorm : FLOAT(1),  $                 ;136- (5)  Continuum normalization factor 
      u_Te6_s: FLOAT(0),  $                  ;140- (6)  Electron Temperature of 2nd component (MK)
      u_Td6_s: FLOAT(0),  $                  ;144- (7)  Doppler  Temperature of 2nd component (MK)
      u_EM50_s: FLOAT(0),  $                 ;148- (8)  Emission measure of 2nd component (cm-3)
      u_Vel: FLOAT(0),  $                    ;152- (9)  Velocity 2nd relative to 1st (km/s, negative is blue)
      spare3: FLOAT(0),  $                   ;156-(10) Reserved for future use
                                             ;
                                             ;-------------------- Spectral Calculation parameters -----------------
                                             ;
      Ashift: FLOAT(0),  $                   ;160- Bulk wavelength shift of spectrum in atomic calculation (A)
      elem_num: FLOAT(0),  $                 ;164- Number of Abundance table used
      abun: FLOAT(0),  $                     ;168- Abundance used [N(Z)/N(H)]
      st$abun_info: BYTARR(32),  $           ;172- Text describing abundance
      Utdoppw: FLOAT(0),  $                  ;204- User supplied Gaussian broadening (A)
      ioncal: BYTE(0),  $                    ;208- Number of ionization balance calculation
      atocal: BYTE(0),  $                    ;209- Number of atomic parameter file
      spare4: BYTARR(2),  $                  ;210- Pad to end on 4 byte boundary
      st$ion_info: BYTARR(32),  $            ;212- Text describing ionization balance calculation
      st$ion_file: BYTARR(20),  $            ;244- File containing ionization balance calculation
      st$ato_info: BYTARR(60),  $            ;264- Text describing atomic data calculation
      st$ato_file: BYTARR(20),  $            ;324- File containing atomic data parameters
      nocont: BYTE(0),  $                    ;344- 1 if No continuum calculation
      noline: BYTE(0),  $                    ;345- 1 if No line calculation
                                             ;
      spare5: BYTARR(2),  $                  ;346- Pad to end on 4 byte boundary
      ion_mult: FLTARR(10)+(1),  $           ;348- Multiplier factor applied to the ionization balance
                                             ;       ion_mult(0) applies to H+
                                             ;               (1) applies to H
                                             ;               (2) to He
                                             ;               (3) to Li, etc.
                                             ;       (i.e., the subscript = number of electrons of the ion)
      density: FLOAT(0),  $                  ;388- Density used to compute the theory spectrum
                                             ;     Units are cm-3
                                             ;
      dispc: FLOAT(0),  $                    ;392- Multiplicative correction factor
                                             ;     applied to nominal wavelength 
                                             ;     dispersion in BCS detector 
                                             ;     CAL FILE
      u_dispc: FLOAT(0) }                    ;396- Uncertainty on DISPC
   
   
   
BSC_RoadMap = { BSC_RoadMap_Rec,              $
                                             ;     For a full description of the fields,
                                             ;     look at the Index_Rec definition
      ByteSkip: LONG(0),  $                  ; 00- Offset in bytes from the beginning of
                                             ;     of the data file for the beginning
                                             ;     of the data set index structure.
                                             ;
      time: LONG(0),  $                      ; 04- Start time (millisec of day)
      day: FIX(0),  $                        ; 08- Start day (since 1-jan-1979)
      chan: BYTE(0),  $                      ; 10- Channel number
      spare1: BYTE(0),  $                    ; 11 -Padding byte
      actim: LONG(0),  $                     ; 12-   Accumulation time in ms
      nBin: FIX(0),  $                       ; 16- Number of bins for selected channel
                                             ;
      spare2: BYTARR(2),  $                  ; 18 -Padding byte
      total_cnts: FLOAT(0),  $               ; 20- Total counts in the selected channel for actim
      max_cps: FLOAT(0),  $                  ; 24- Maximum counts per second of limited counts from dp_sync for
                                             ;       the channel
      DP_Flags: BYTE(0),  $                  ; 28- DP Flags received by BCS
      spare3: BYTARR(3),  $                  ; 29 -Padding byte
                                             ;
      length: FIX(0),  $                     ; 32- The number of points in the spectra. 
      dataRecTypes: FIX(0),  $               ; 34- Type of data the is included in the data portion
      spare: BYTARR(12) }                    ; 36- Spare bytes
   
   
   
BSC_Version = { BSC_Version_Rec,              $
      roadmap : FIX('20E1'x),  $             ;
                                             ; 00- The version number of the Roadmap
                                             ;     This value is not contained in the
                                             ;     roadmap structure to save space.  It is
                                             ;     saved in the "File Header Record"
      data : FIX('20E1'x),  $                ;
                                             ;     This structure is not written to any files
      spare: BYTARR(12) }                    ;     (need for automatic conversion to IDL format)
   
   
   
  
  
end
