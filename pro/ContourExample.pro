;-*- idl -*-
; * Example for using color contour plots, note no data is read into this routine!

LOADCT,39 ;Load color table "rainbow+white"
;Define names for colors
Red=254
Orange=209
Yellow=192
Green=151
Cyan=104
Blue=55
Purple=32
Black=0
White=255

;*****************************************************
;* Initialize some useful general purpose parameters *
;*****************************************************
ps = 0					;If ps=0 output to the screen, if ps=1 then output to a postscript file
if ps then begin
foreground = black
background = white
set_plot,'ps'
endif else begin
set_plot,'win'
Device, Decomposed=0	;Required for correct color display on your monitor
foreground = white
background = black
endelse

winnum=0
!p.font = 1 ;True Type Font instead of Vector Font (-1)
;!P.THICK = 3	;Makes output look better for publication
;!X.THICK = 4
;!Y.THICK = 4
;!Z.THICK = 4
!P.MULTI = 0	;One plot per page
!Y.STYLE = 1	;Bug in IDL -> required for plot axis commands to
!X.STYLE = 1	;work properly

colorlist=intarr(5)								;Handy standard list of colors for contour plots
colorlist=[foreground,blue,yellow,orange,red]
levellist=[.1,1, 10, 25,50]						;Corresponding criteria for above colors
legendlist=['Counts','1','2-10','11-25','26-50','> 50']	;Text to use for legend
bin1chan=1										;For 2-d histogram # of channels per bin
bin2chan=1										;For 2-d histogram # of channels per bin

;******************************************************************************************
;* The x variable is EcNN/xs.hitA (cathode/anode) and the y variable is xs.hitA (anode).  *
;* I multiplied the x variable by 100 so that I don't lose too much information when I    *
;* "ROUND" the variable.  The built-in function HIST_2D input must be of byte, integer,   *
;* or longword type, and must contain no negative elements.  The values I am working with *
;* are floats, hence the use of "ROUND."                                                  *
;******************************************************************************************

if ps then begin
	DEVICE, /ENCAPSULATED,/COLOR, FILENAME = string(swiftNT,'Plots\NIM\AvgDOIfullphotopeak.eps'),/INCHES, YSIZE = 7.5, XSIZE=10.3,BITS_PER_PIXEL=8,SET_FONT='Times', /TT_FONT, Preview=2 ;Note use of ENCAPSULATED keyword.
endif else begin
	WINDOW,winnum, XSIZE=1200, YSIZE=900,TITLE='C/A for full Photopeak'
	winnum=winnum+1
endelse

Z2=HIST_2D(ROUND(EcNN/xs.hitA*100),ROUND(xs.hitA),bin1=bin1chan,bin2=bin2chan)
CONTOUR,Z2,LEVELS=levellist,C_COLORS = colorlist,/FILL,$
	xtitle='Cathode/Anode',ytitle='Anode Energy (keV)',title='Full Photopeak',charsize=2,$
	yrange=[50/bin2chan,160/bin2chan],xrange=[0,150/bin1chan]
LEGEND,legendlist,/fill,psym=[3,8,8,8,8,8],colors = [background,colorlist],char=.75,$
		textcolors=[foreground,foreground,foreground,foreground,foreground,foreground],/RIGHT

if ps then DEVICE,/CLOSE

END