;+
; Name: tick_label_exp
; 
; Purpose:  Forces exponential axis labeling. 
; 
; Category    : Graphics
;  
; Method: This function will be called by the IDL plot routine when you set x... or ytickformat='tick_label_exp' to
;   force exponential axis labeling.
;   It is defined with three positional parameters that are required by IDL for a tick formatting function.
;   This was needed because IDL's internal algorithm for tick labeling sometimes selects exponential axis tick labeling 
;   and sometimes selects number axis tick labeling (resulting in awkward long labels sometimes, like 10.00000).
;   
; Example:
;   plot,(1. + indgen(1000))/10000., /ylog, ytickformat='tick_label_exp' 
;   plot,(1. + indgen(1000))/10000., /ylog ; without tick_label_exp, labels are 0.0001, 0.0010, 0.0100, 0.1000
;   
; Written: Kim Tolbert 9-Sep-2014.  Extracted and modified from a routine by Stein Vidar Hagfors Haugan posted on
;   Coyote's Guid to IDL Programming (https://www.idlcoyote.com/tips/exponents.html)
;   
; Modifications:
; 
;-

FUNCTION tick_label_exp, axis, index, number

     ; A special case.
     IF number EQ 0 THEN RETURN, '0' 

     ; Assuming multiples of 10 with format.
     ex = trim(String(number, Format='(e8.0)')) 
     pt = StrPos(ex, '.')

     first = StrMid(ex, 0, pt)
     sign = StrMid(ex, pt+2, 1)
     thisExponent = StrMid(ex, pt+3)

     ; Shave off leading zero in exponent
     WHILE StrMid(thisExponent, 0, 1) EQ '0' DO thisExponent = StrMid(thisExponent, 1)

     ; Fix for sign and missing zero problem.
     IF (Long(thisExponent) EQ 0) THEN BEGIN
        sign = ''
        thisExponent = '0'
     ENDIF

     ; Make the exponent a superscript.
     ; if first character is 1, leave it off.  Otherwise set label to first character + 'x' + exponent, e.g. 2x10^3
     prefix = first eq '1' ? '' : first + 'x'
     IF sign EQ '-' THEN BEGIN
        RETURN, prefix + '10!U' + sign + thisExponent + '!N' 
     ENDIF ELSE BEGIN             
        RETURN, prefix + '10!U' + thisExponent + '!N'
     ENDELSE
     
   END