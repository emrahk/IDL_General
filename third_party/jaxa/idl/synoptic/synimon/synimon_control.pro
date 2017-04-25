; =========================================================================
;+
; Project     : The General IDL SYNoptic IMage Object (SYNIMON)
;
; Name        : SYNIMON_CONTROL
;
; Purpose     : Used by SYNIMON__DEFINE for dynamic data handling.
;
; Category    : Ancillary Synoptic Objects
;
; Syntax      : N/A
;
; Example     : 
;
; Notes       :
;
; History     : 18-AUG-2007 Written (My birthday!), Paul Higgins, (ARG/TCD)
;               14-OCT-2008 Changed object name from SYNIMON to SYNIMON, Paul Higgins, (ARG/TCD)
;
; Tutorial    : Not yet. For now take a look at the configuration section of 
;               http://solarmonitor.org/solmon/
;
; Contact     : P.A. Higgins: pohuigin {at} gmail {dot} com
;               P. Gallagher: peter.gallagher {at} tcd {dot} ie
;-
; =========================================================================

;-------------------------------------------------------->

function SYNIMON_Control

var = { SYNIMON_control }

var.data[ *, * ] = 1.

;--<< Map header variables. >>

var.ut = ''
var.obs = ''

var.instrument = 'SYNIMON'
var.filter = ''
var.timerange = [ anytim( strjoin([anytim(systim(),/date,/vms),'23:59:59.999'],' '),/vms ),'']
var.header = strarr(2,13)

RETURN, var

END

;-------------------------------------------------------->