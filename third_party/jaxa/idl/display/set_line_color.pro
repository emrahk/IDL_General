;+
; PROJECT:
;       SOHO - SUMER
;
; NAME:
;       SET_LINE_COLOR
;
; PURPOSE: 
;       Define 11 different colors for the first 11 color indices
;
; EXPLANATION:
;       This routine assigns 11 different colors to the first 11 color
;       indices. These color indices correspond to the following colors:
;
;           'black',  'white',  'yellow',  'red',     'green', 
;           'blue',   'orange', 'purple',  'magenta', 'brown', 
;           'turquoise'
;
;       The appearance of the actual color will depends on how many
;       colors are available in your display device. Generally
;       speaking, it will appear pretty close if more than 200 colors
;       are available.
;
; CALLING SEQUENCE: 
;       SET_LINE_COLOR
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       LIST - List (on the screen) numbers and names of line color defined 
;
; PREVIOUS HISTORY:
;       Written April 18, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, GSFC/ARC, April 18, 1995
;       Version 2, September 1, 1995, Liyun Wang, GSFC/ARC
;          Added LIST keyword
;
; VERSION:
;       Version 2, September 1, 1995
;-
;
PRO SET_LINE_COLOR, list=list,count=count

   colornames = ['black',  'white',  'yellow',  'red',     'green', $
                 'blue',   'orange', 'purple',  'magenta', 'brown', $
                 'turquoise']

   count=n_elements(colornames)
   IF KEYWORD_SET(list) THEN BEGIN
      FOR i=0, N_ELEMENTS(colornames)-1 DO BEGIN
         PRINT, FORMAT='(i2, 3x, a)', i, colornames(i)
      ENDFOR
      RETURN
   ENDIF
   
   FOR i = 0, N_ELEMENTS(colornames)-1 DO linecolor, i, colornames(i),/disable
   
   RETURN
END

