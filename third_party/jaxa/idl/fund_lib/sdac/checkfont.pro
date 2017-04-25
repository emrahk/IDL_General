;+
; PROJECT     : SDAC
;                   
; NAME:
;       CHECKFONT
;
; PURPOSE:
;       This function changes the default widget hardware font to be one of the user's 
;	choosing.
;       If no hardware font matches are found, then a font widget appears
;	for the user to select from.
;
; CATEGORY:
;       widget font
;
; CALLING SEQUENCE:
;       var = CHECKFONT([FONT=font, message=message])
;
; CALLED BY:
;       none
;
; CALLS TO:
;       PICKFONT  (xfont clone)
;
; INPUTS:
;       none
;
; OPTIONAL INPUTS:
;
;	FONT	:   string or string array listing the hardware font to be 
;		    set as the widget default font. Wildcards are allowed. 
;	MESSAGE = message to be displayed by the view window.
;
; OUTPUTS:
;       Returns the selected font as a string.
;
; OPTIONAL OUTPUTS:
;       none
;
; COMMON BLOCKS:
;       none
;
; SIDE EFFECTS:
;       The size of the selected font will effect vector drawn fonts.
;       A temporary pixmap window is created.
;
; RESTRICTIONS:
;       Need X window device.
;
; PROCEDURE:
;       Search the hardware fonts for a match with the user's input.
;       Switch the default widget font to the resulting match.
;
; MODIFICATION HISTORY:
;       oct-1993, Elaine Einfalt (HSTX)
;-


function checkfont, font=font, message=message

if n_elements(font) eq 0 then font = ''
if n_elements(message) eq 0 then message = $
        'The quick brown fox jumped over the lazy dog.' + $
        '!C!CABCDEFG abcdefg 01234567'                   

;
; If no window currently exists then create a window,
; or else the DEVICE,FONT command will create one, but won't delete it later.
;

 if !d.window eq -1 then begin                   ; if no windows are existing
     window,/free, xsize=1, ysize=1, /pixmap         	; make window
     temp_window = !d.window                            ; remember window
 endif

 floop 	 = n_elements(font)			; number of different searches
 got_one = 0
 counter = 0

;
; Search the hardware fonts for a font that matches the user's input.
;

 while (counter lt floop) and not(got_one) do begin
   ;
   ; 1) see if any system hardware fonts fit the font designation.
   ; 2) return those matches in string or string array DEFNAMES,
   ; 3) and, the number of matches are returned in in DEF_NUM.
   ;

   device, font=font(counter), get_fontname=defnames, get_fontnum=def_num

   if def_num gt 0 then got_one = 1 	; there is at least one font match
   counter = counter + 1
 endwhile

; 
; If any of the font matches were found, then change font to the first match.  
; If no matches were found, the user may interactively select from XFONT.
;

 if def_num ne 0 then begin    			; found a font match
    widget_control, default_font=defnames(0)	; change widget
 endif else begin
	   defnames = pickfont(message=message) 

	   if (defnames ne '') then widget_control, default_font=defnames(0)
 endelse

 if (n_elements(temp_window) ne 0) then wdelete, temp_window 	; kill temp

                   
return, defnames(0)
end

