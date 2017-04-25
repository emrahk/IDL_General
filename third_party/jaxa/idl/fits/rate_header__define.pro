;---------------------------------------------------------------------------
; Document name: rate_header__define.pro
; Created by:    Sandhia Bansal, September 01, 2004
;
; Last Modified:
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       HESSI IMAGE CONTROL STRUCTURE DEFINITION
;
; PURPOSE:
;       Defines the RATE header structure to store required keywords for rate header.
;
; CATEGORY:
;       HESSI / Imaging
;
; CALLING SEQUENCE:
;       var = {rate_struct}
;
; EXAMPLES:
;       r = {rate_struct}
;       help, r, /structure
;
; SEE ALSO:
;       http://hessi.ssl.berkeley.edu/software/reference.html
;       rate_header
;
; HISTORY:
;
;   24-Sep-2004   Sandhia Bansal    Added author field to the structure.
;   16-Nov-2004   Sandhia Bansal    Added new fields - fitFuntion and area,
;                                     backapp, deadapp, vignapp, observer, and
;                                     timversn.
;-


PRO rate_header__define

struct = { rate_header, $
           telescope: '', $
           instrument: '', $
           filter: '', $
           object: '', $
           ra: 0.0, $
           dec: 0.0, $
           ranom: 0.0, $
           decnom: 0.0, $
           origin: '', $
           timeunit: 'd', $
           timeref: 'LOCAL', $
           tassign: 'SATELLITE', $
           tierrela: 0.0, $
           tierabso: 0.0, $
           ontime: 0.0, $
           mjdref: 0L, $
           timesys: 'MJD', $
           timezero: 0.0D, $
           tstarti:  0, $
           tstartf:  0.0D, $
           tstopi:   0, $
           tstopf:   0.0D, $
           telapse: 0.0, $
           equinox: 2000.0, $
           radecsys: 'FK5', $
           hduclass: 'OGIP', $
           hduclas1: 'SPECTRUM', $
           hduclas2: 'TOTAL', $
           hduvers: '1.3.0', $
           ancrfile: '', $
           areascal: 1.0, $
           backfile: '', $
           backscal: 1.0, $
           corrfile: '', $
           corrscal: 1.0, $
           exposure: 1.0, $
           grouping: 0, $
           quality: 0, $
           detchans: 0, $
           chantype: '', $
           vignet: 0.0, $
           detnam: '', $
           npixsou: 0.0, $
           clockcor: '', $
           poisserr: '', $
           fitFunction: '', $
           area: 0.0, $
           backapp: 'F', $
           deadapp: 'T', $
           vignapp: 'F', $
           observer: 'unknown', $
           timversn: 'OGIP/93-003', $
           version: '', $
           author: '' }
END

;---------------------------------------------------------------------------
; End of 'rate_header__define.pro'.
;---------------------------------------------------------------------------

