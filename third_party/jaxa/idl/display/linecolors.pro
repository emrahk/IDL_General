;+
;
; file LINECOLORS.PRO
;
; Create a color table with "n" distinct color indices at the low end of
; the table and the index at !D.TABLE_SIZE-1 with the colors defined below.
;
;	Where: the first color index will be black
;	       'n' is the number of distinct colors hard coded below
;	       and, the last color index is white
;
; INDEX NUMBER   COLOR PRODUCED (if use default colors)
; 	0		black
;	1		maroon
;	2               red
;	3		pink
;	4		orange
;	5		yellow
;	6		olive
;	7		green
;	8		dark green
;	9		cyan
;	10		blue
;	11		dark blue
;	12              magenta
;	13              purple
;
; General color table stuff:
;	Each color available is made up of the values found in three arrays.
;	These array represent how much RED, GREEN, and BLUE color to use.
;	A value of zero means don't use any of that color.
;	A value of 255 means use the maximum amount of that color.
; 	These arrays are considered your 'color guns'.
;
;	How large your 'color gun' arrays can be is determined by your system.
;	!D.N_COLORS system variable hold the max number of colors you can have.
; 	!D.TABLE_SIZE is the maximum number of indices you may use.
;	You may not have all 255 colors.
;	So for each 'color index' you must decide how much RED, GREEN and
;		BLUE you want.
;	The combination of these three 'color gun' arrays will be the color
;		that appears in the individual 'color index'.
;
;
; CALLING SEQUENCE:
;       LINECOLORS 	is the simplest form. It produces a color table with
;			the colors listed above and loads it. All you do is
;			call it and use the plot keyword COLOR=x.
;			Where x is the index number from above.
;
;	LINECOLORS [,MYCOL_R=mycol_g, MYCOL_G=mycol_g, MYCOL_B=mycol_b,
;		     LINE_R=line_g, LINE_G=line_g, LINE_B=line_b,
;		     table=table,  /NOLOAD, /NOTOP, /NOSQUEEZE, USED=used,
;                    /image, /help, error=error]
;
; INPUT:
;	MYCOL_R : If present, an array (convert to byte) containing the
;		  red gun values (0-255) to overwrite the common array COLORS
;		  This array is expanded or compressed to fit. Will override
;		  the TABLE keyword value.
;	MYCOL_G : Same as above for green.
;	MYCOL_B : Same as above for blue.
;       IMAGE   : If set, the distinct colors are placed at the top of the
;                 color array (easier for imaging) instead of at the bottom
;                 easier for plotting). 
;	TABLE  : The number of an IDL User Library Color Table, to be loaded.
;		 It will be this table that is compressed into the indices
;		 remaining after MYCOL_R,_G,_B or the defaults arrays.
;	NOLOAD : If set, don't do a TVLCT in this program.
;		 This new color table will not be active until doing a TVLCT
;	NOTOP  : If set, don't put white in the index at !D.TABLE_SIZE-1
;		 Not all original color tables will have white at the top.
;       NOSQUEEZE: If set, don't squeeze the current color table into
;		   the indices not taken by the distinct colors. The bottom
;		   colors of the original table will be overwritten the
;		   rest will remain as they were. Ignored if the keywords
;		   MYCOL_R, MYCOL_G, MYCOL_B are set.
;       SQUEEZE:  opposite of NOSQUEEZE (this is the default)
;       HELP:     If set and device='x', display a colorbar with indices
;		  (!d.window is reset to original window number)
;
; OUTPUT:
;	LINE_R : If present, returns the red color gun values for this new
;		 color table. This array is the same as found in the IDL
;		 common array R_CURR, upon returning.
;	LINE_G : Same as above for green.
;	LINE_B : Same as above for blue.
;
;       USED   : If present, returns the number of indices used by the
;		 distinct colors at the low end of the color table.
;		 Doesn't include the overwritting of the top index to white,
;		 or any value of MYCOL_R, MYCOL_G, MYCOL_B.
;
;       also see the explaination of x_CURR below.
;       ERROR  : 0/1 means no error / error
;
;
; COMMON:
;     COMMON COLORS, R_ORIG, G_ORIG, B_ORIG, R_CURR, G_CURR, B_CURR
;	This IDL common contains the current color table.
;
; SIDE EFFECTS:
;	The color table side will be determined by the current device
;	If the device is not 'X' or 'WIN', an informational message will be printed.
;

; RESTRICTIONS:
;	The output graphic device must accept the LOADCT calls, if
;	/TABLE is set or if no previous table has been loaded.
;       The output graphic device must accept the TVLCT call, unless
;	the /NOLOAD keyword is set.
;
; PROCEDURE:
;	Some time before you do your plot command, call this routine.
;
;          LINECOLOR
;
;	If you use the /NOLOAD keyword, then upon returning you will need
;	to load the new created color table with TVLCT, <red>,<green>,<blue>
;
;	   LINECOLORS, LINE_R=LINE_R, LINE_G=LINE_G, LINE_B=LINE_B, /NOLOAD
;	   TVLCT, LINE_R, LINE_G, LINE_B
;
;
;	To postscript printer :
;		SET_PLOT,'PS',/copy  ; prints plot the postscript file
;
;		DEVICE, [FILENAME=filename]		; black and white print
;		  or
;		DEVICE, [FILENAME=filename], /color     ; color print
;
;	To plot, use the desired color index, by using the plotting
;	   keyword COLOR=index.
;	You may want to first plot the axises in white then over plot the
;	   data in a distinct color.
;
;             plot, x, y,  /nodata ...             ; titles and axes
;						   ; color defaults to the
;						   ; largest index. In our
;						   ; color table this is white
;						   ; Black for prints.
;
; 	      oplot, x, y, color=n ...		   ; Plot the data. 'n' is
;						   ; the color index of choice
;
;       If you were printing then you'll need to close the output file,
;	   and print.
;
;             DEVICE,/CLOSE
;	      PSPLOT, FILENAME=filename           ; for black and white
;	      PSPLOT, FILENAME=filename, /color	  ; for color print
;
;       An example:
;			pro brian, color=color   ; color is 0 for b/w
;						 ;          1 for color
;
;   			linecolors
;  			set_plot,'ps',/copy
;			if not(color) then device,file='brain.ps' $
;  			else device,file='brain.ps', color=color
;
;  			plot, indgen(100), /nodata
;  			oplot, (indgen(100)-10)>0, color=1
;  			oplot, (indgen(100)-20)>0, color=3
;  			oplot, (indgen(100)-30)>0, color=5
;  			oplot, (indgen(100)-40)>0, color=7
;  			oplot, (indgen(100)-50)>0, color=9
;
;  			device,/close
;  			if not(color) then psplot,filename='brain.ps' $
;  			else psplot,filename='brain.ps',/color
;
;			return  & end
;
; MODIFICATION HISTORY:
;	Elaine Einfalt (HSTX)
;	MAY 93 - If mycol_r,g,b arrays are passes they are added
;		 after the distinct colors, not instead.
;       23-sep-94 (SLF) - added HELP keyword (display color bar with indices)
;		2-Aug-2000, Kim Tolbert - everywhere it checks for X, make it also check for WIN
;       17-May-2004 - Einfalt - merged the ssw and the eit ops versions, by adding
;                     the /image keyword, which if set, will put the line colors at
;		      the top of the array, not bottom.
;       14-Mar-2005 - S.L.Freeland - added the historically documented but missing NOSQUEEZE keyword
;                     to the routine def; kept undocumented but defined SQUEEZE for backward-compat.
;-

pro linecolors, mycol_r=mycol_r, mycol_g=mycol_g, mycol_b=mycol_b, $
		line_r=line_r, line_g=line_g, line_b=line_b, table=table, $
		noload=noload, notop=notop, squeeze=squeeze, nosqueeze=nosqueeze, used=used, $
                image=image, error=error, help=help

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

error = 0
nosqueeze=keyword_set(nosqueeze)
squeeze=1-nosqueeze or keyword_set(squeeze) ; default

;
; First, does user want an IDL User Library Color Table loaded.
; If not, and no table has been loaded this session or table size is wrong,
; then load one now.  Loading a table assigns the real !D.TABLE_SIZE value.
;
  if n_elements(table) ne 0 then loadct, table, /silent	; User's table choice

  if ( ( (!d.name eq 'X') or (!d.name eq 'WIN') ) and (!d.window eq -1)) or  $  	; need a window, or
     (n_elements(r_orig) ne !d.table_size)          $   ; changed device
	 then loadct, 0, /silent  ; black and white linear


;
; Second, define the distinct colors that will be used for plot lines
; These color may be expanded or changed simply by adding to or altering
; the 'color gun' arrays values.
;

  distinct_r = [0,128,255,255,255,255,128,  0,  0,  0,  0,  0,255,128]
  distinct_g = [0,  0,  0,  0,128,255,128,255,128,255,  0,  0,  0,  0]
  distinct_b = [0,  0,  0,128,  0,  0,  0,  0,  0,255,255,128,255,128]

  ;
  ; Will that many colors fit into the available indices?
  ;

  used = n_elements(distinct_r) > n_elements(distinct_g) > $
	 n_elements(distinct_b)
  must_have = used + (1-keyword_set(notop))	; remember about the
						; possible top white

  if !d.table_size lt must_have then begin
     message, 'Error - color table NOT loaded. Only ' + $
		strtrim(!d.table_size,2) + ' indices where available.', /info
     error = 1
     return
  endif

  if keyword_set(image) then begin
      image = 1
      if not(keyword_set(notop)) then used = must_have
  endif else image = 0

;
; Third, overwrite current color table with new colors.
;

  r_temp = r_curr
  g_temp = g_curr
  b_temp = b_curr

  ;
  ; The distinct colors are placed at the bottom of the table or the top
  ;

  place = (!d.table_size - used)  * image   ; will be 0 if not image

  r_temp(place) = distinct_r  
  g_temp(place) = distinct_g  
  b_temp(place) = distinct_b


  ;
  ; Does the user have a set of color gun arrays that they want loaded?
  ;

  remain = !d.table_size - used		; space left after distinct colors
  n_orig = n_elements(r_orig)           ; Common arrays are same size

  ;
  ; If user did not pass a color gun array and NOSQUEEZE was not set, then
  ;    then squeeze original color table into remaining indices.
  ; If use passed a color gun array, then expand or squeeze their array to
  ;    fit in remaining indices (NOSQUEEZE is ignored).
  ;

  start = used * (1-image)		; will be 0 if not image

  if (size(mycol_r))(0) eq 0 then begin  	; no colors passed by user
     if not keyword_set(nosqueeze) then $	; if allowed to squeeze
	r_temp(start) = congrid(reform(r_orig, n_orig, 1), remain, 1)
  endif else $					; fit in user's colors
      r_temp(start) = congrid(reform(mycol_r, (size(mycol_r))(1), 1), remain, 1)

  if (size(mycol_g))(0) eq 0 then begin		; no colors passed by user
     if not keyword_set(nosqueeze) then $	; if allowed to squeeze
	g_temp(start) = congrid(reform(g_orig, n_orig, 1), remain, 1)
  endif else $ 					; fit in user's colors
      g_temp(start) = congrid(reform(mycol_g, (size(mycol_g))(1), 1), remain, 1)

  if (size(mycol_b))(0) eq 0 then begin  	; no colors passed by user
     if not keyword_set(nosqueeze) then $	; if allowed to squeeze
	b_temp(start) = congrid(reform(b_orig, n_orig, 1), remain, 1)
  endif else $ 		      			; fit in user's colors
      b_temp(start) = congrid(reform(mycol_b, (size(mycol_b))(1), 1), remain, 1)

  ;
  ; Overwrite common's color table in favor of this new matrix.
  ;

  r_curr = r_temp   &   g_curr = g_temp   &   b_curr = b_temp


  if not keyword_set(notop) then begin
  ;
  ; Unless the user specifically said not to, make last color index white.
  ;
      r_curr(!d.table_size - 1) = 255
      g_curr(!d.table_size - 1) = 255
      b_curr(!d.table_size - 1) = 255
  endif

;
; Now load this new color table, if the user wants it.
; If /NOLOAD was set, then the user will load the color table later.
;

  if not keyword_set(noload) then begin

 	tvlct, r_curr, g_curr, b_curr
	r_orig = r_curr   &   g_orig = g_curr   &   b_orig = b_curr

  endif

;
; Allow user access to arrays without requiring the common block.
;
  line_r = r_curr  &  line_g = g_curr  &  line_b = b_curr


;
; If not 'X' or 'WIN' then tell the user what they have just done.
;

  if !d.name ne 'X' and !d.name ne 'WIN' then message, /info, strtrim(!d.table_size,2) + $
			 ' color table indices set for ' + !d.name + ' device.'

; slf - added HELP keyword and function
if keyword_set(help) and ( (!d.name eq 'X') or (!d.name eq 'WIN') ) then begin
   bar=rebin(indgen(used),32*used,used*4,/sample)
   wtemp=!d.window
   wdef,zz,/ur,image=bar
   tv,bar
   xyouts,indgen(used)*32+8, 32,strtrim(sindgen(used),2),/device,size=1.5,charthick=2.
   if wtemp ne -1 then wset,wtemp
endif

return
end
