FUNCTION Exponent, axis, index, number

    ; this function heps creating
    ; exponential axis marks rather than
    ; 0.000X.

 ; INPUTS
 ; axis: comes from the plotting routine, not used
 ; index: comes from the plotting routine, not used
 ; number: comes from the plotting routine, used to create correct exponents
 ; 
 ; RETURNS
 ; list of text exponents to be plotted
 ; 
 ; USES
 ;
 ; NONE
 ;
 ; USED BY
 ;
 ; all plotting algorithms
 ;
 ; copied from Coyote IDL
 ;


     ; A special case.
     IF number EQ 0 THEN RETURN, '0' 

     ; Assuming multiples of 10 with format.
     ex = String(number, Format='(e8.0)') 
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
     IF sign EQ '-' THEN BEGIN
        RETURN, first + 'x10!U' + sign + thisExponent + '!N' 
     ENDIF ELSE BEGIN             
        RETURN, first + 'x10!U' + thisExponent + '!N'
     ENDELSE
     
  END
