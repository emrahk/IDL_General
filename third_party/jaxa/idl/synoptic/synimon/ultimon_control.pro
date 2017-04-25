; Project     : The ULTIMATE IDL Object
;
; Name        : ULTIMON_CONTROL
;
; Purpose     : Used by ULTIMON__DEFINE for dynamic data handling.
;
; Category    : Ancillary Synoptic Objects
;
; Syntax      : N/A
;
; Example     : 
;
; Notes       :
;
; History     : Written 18-AUG-2007 (My birthday!), Paul Higgins, (ARG/TCD)
;
; Tutorial    : Not yet. For now take a look at the configuration section of 
;               [http://solarmonitor.org/solmon_tutorial.html]
;
; Contact     : P.A. Higgins: era {at} msn {dot} com
;               P. Gallagher: peter.gallagher {at} tcd {dot} ie
;-->
;----------------------------------------------------------------------------->

;-------------------------------------------------------->

function ultimon_Control

var = { ultimon_control }

var.data[ *, * ] = 1.

;--<< Map header variables. >>

var.ut = ''
var.obs = ''

var.instrument = 'ultimon'
var.filter = ''
var.timerange = [ anytim( strjoin([anytim(systim(),/date,/vms),'23:59:59.999'],' '),/vms ) ]
var.header = strarr(2,13)

RETURN, var

END

;-------------------------------------------------------->