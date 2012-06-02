PRO TRIPP_SETSIMPAR,multiple=multiple, amp01=amp01,period01=period01,toffset=toffset,   $
                   exptime=exptime,cycletime=cycletime,nr_datapts=nr_datapts, $
	           noise=noise, tnoise=tnoise, seed=seed, stdev=stdev,        $
                   degree=degree, clearmax=clearmax, clearmin=clearmin,       $
                   preclear=preclear,smoothed=smoothed,                       $
		   vorlage=vorlage,                                           $   
    period02=period02,period03=period03,period04=period04,period05=period05,  $
    period06=period06,period07=period07,period08=period08,period09=period09,period10=period10, $
    amp02=amp02,amp03=amp03,amp04=amp04,amp05=amp05,                          $
    amp06=amp06,amp07=amp07,amp08=amp08,amp09=amp09,amp10=amp10   
;+
; NAME:                 
;                       TRIPP_SETSIMPAR
;
;
;
; PURPOSE:              
;                       think up all the default parameters needed for
;                       lightcurve simulation
;
;
;
;
; CATEGORY:            
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
   
  on_error,2                    ;Return to caller if an error occurs

;; ---------------------------------------------------------
;; --- SET DEFAULT PARAMETERS
;;
IF EXIST(period01) AND NOT EXIST(amp01) THEN amp01 = 1.
IF NOT EXIST(period01)   THEN amp01      = 0.
IF NOT EXIST(period01)   THEN period01   = 200. 
IF NOT EXIST(exptime)    THEN exptime    = 10.
IF NOT EXIST(cycletime)  THEN cycletime  = exptime*1.5
IF NOT EXIST(toffset)    THEN toffset    = 0.
IF NOT EXIST(nr_datapts) THEN nr_datapts = 500
IF NOT EXIST(noise) AND EXIST(vorlage) THEN stdev = 1.
IF NOT EXIST(noise)      THEN noise      = 0.
IF NOT EXIST(tnoise)     THEN tnoise     = 0.
IF NOT EXIST(degree)     THEN degree     = -1
IF NOT EXIST(clearmin)   THEN clearmin   = -1000000.0
IF NOT EXIST(clearmax)   THEN clearmax   =  1000000.
IF NOT EXIST(preclear)   THEN preclear   = -1
IF NOT EXIST(smoothed)   THEN smoothed   = 0
IF NOT EXIST(vorlage)    THEN vorlage    = "nein"
IF NOT EXIST(amp02)      THEN amp02      = amp01
IF NOT EXIST(amp03)      THEN amp03      = amp02
IF NOT EXIST(amp04)      THEN amp04      = amp03
IF NOT EXIST(amp05)      THEN amp05      = amp04
IF NOT EXIST(amp06)      THEN amp06      = amp05
IF NOT EXIST(amp07)      THEN amp07      = amp06
IF NOT EXIST(amp08)      THEN amp08      = amp07
IF NOT EXIST(amp09)      THEN amp09      = amp08
IF NOT EXIST(amp10)      THEN amp10      = amp09
IF NOT EXIST(period02)   THEN amp02      = 0.
IF NOT EXIST(period03)   THEN amp03      = 0.
IF NOT EXIST(period04)   THEN amp04      = 0.
IF NOT EXIST(period05)   THEN amp05      = 0.
IF NOT EXIST(period06)   THEN amp06      = 0.
IF NOT EXIST(period07)   THEN amp07      = 0.
IF NOT EXIST(period08)   THEN amp08      = 0.
IF NOT EXIST(period09)   THEN amp09      = 0.
IF NOT EXIST(period10)   THEN amp10      = 0.
IF NOT EXIST(period02)   THEN period02   = period01
IF NOT EXIST(period03)   THEN period03   = period01
IF NOT EXIST(period04)   THEN period04   = period01
IF NOT EXIST(period05)   THEN period05   = period01
IF NOT EXIST(period06)   THEN period06   = period01
IF NOT EXIST(period07)   THEN period07   = period01
IF NOT EXIST(period08)   THEN period08   = period01
IF NOT EXIST(period09)   THEN period09   = period01
IF NOT EXIST(period10)   THEN period10   = period01
;IF NOT EXIST(seed)       THEN seed       = 0.3  better leave seed undefined

IF NOT EXIST(multiple) THEN multiple = 100   
;; ---------------------------------------------------------
;; --- END
;;
END



