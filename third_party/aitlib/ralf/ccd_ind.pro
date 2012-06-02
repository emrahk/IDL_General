FUNCTION CCD_IND,num
;+
; NAME:
;	CCD_IND
;
; PURPOSE:
;	Create an array of indices from [0,num-1] with
;	random positions in the array.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_IFIT( num )
;
; INPUTS:
;	NUM : Number of indices.
; 
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;		
; OPTIONAL KEYWORDS:
;	NONE.
;
; OUTPUTS:
;	Array with indices.
;
; OPTIONAL OUTPUT PARAMETERS:
;       NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;-


on_error,2                      ;Return to caller if an error occurs

index=intarr(num)

for i=0,num-1 do begin
   repeat new=long(RANDOMU(seed)*num) $
   until index(new) eq 0

   index(new)=i
endfor


RETURN,index
END
