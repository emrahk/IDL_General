Pro init_linecolors,col,do_color=do_color,test=test,print=print,dev=dev,$
    table=table
; +
; PROJECT:
; HESSI
; NAME:
; INIT_COLORS
; CALLED PROCEDURES: LINECOLORS
; PURPOSE:
;  Works with the program LINECOLORS, which provides the user with
;  a distinct set of basic colors.  Init_linecolors calls linecolors with
;  no arguments, initializes the structure col, which has 
;  the fourteen basic colors established by linecolors and the color white
; INSTRUCTIONS
;  in your program call init_linecolors,col,/do_color
;  the program will return the structure col, which you can
;  then use in plotting commands.  EX.
;    plot,x,y,color=col.blue (col.blue will equal 10, the linecolors
;      value for blue) 
;  for a grayscale plot you can use the 14 colors to simplify your
;   plot commands: 
;     call init_linecolors,col
;     plot, x,y,color=col.blue (each 'color' in the structure col has
;     a different shade of gray)
;   you can additionally specify other color tables when not using the 
;   do_color = 1 setting by using the keyword table:
;    call init_linecolors,col,table=1
;    plot,x,y,color=col.blue (table 1 is the blue/white table, each 'color'
;    in the structure col will be a shade of the blue/white table)
; OPTIONAL INPUT KEYWORD PARAMETERS:
;   do_color - a keyword which determines whether init_linecolors will
;   return the stark color values given by linecolors, or whether
;   init_linecolors will return values coresponding to the 256 color
;   map B-W linear (which will approximate grayscaling when the 
;   plot is printed).  Values are:
;    1 - Color (will use stark colors)
;    0 - Psuedograyscale (will use 256 color range)
;   table - sets the idl color table you wish to use with linecolors
;   the default table is 0 (b-w linear) for do_color=0 (when using do_color=1,
;   linecolors always uses the 13 basic colors, so the table keyword is not
;   very useful for /do_color).  Use the test and print keywords to help
;   produce pictures of your new color table
;   test - plots each color on the screen so you can see what  the 
;    colors will look like, use /test or test = 1
;   print - prints the test plot in Postscript, creating an idl.ps file
;   dev - sets the device type [DEFAULT DEVICE IS X]
;    use exact idl specifications for dev (i.e., dev='tek' or dev='x', etc.
;    as the program will use your exact text (primarily to be
;    used in conjunction with the test keyword)
;
; OUTPUT:  col - a structure of 15 colors in the form col.color, where
; color = a number from 0 - 13 representing the colors black, maroon, etc.
; which are established by linecolors, color 14 = white, which is set to
; 255
; SIDE EFFECTS:
;  1) Will affect the color table in your IDL session, if you are
;  using other color plotting procedures, the display may change
;  color as you move around the desktop
;  RESTRICTIONS:
;  1) using /do_color will always give you the basic colors
;  2) if you set the table keyword, you won't get basic colors because, the
;    table keyword only works for the grayscale colors which are beyond the 
;    basic colors set by linecolors
;
;  MODIFICATION HISTORY
;   Written by Eric Carzon, July 1994, HUGHES/STX
; -
; 

if keyword_set(do_color) then do_color = do_color else do_color = 0
if (not keyword_set(dev)) then dev = 'X' else dev = dev

col = {colors, black:0,maroon:0,red:0,pink:0,orange:0,yellow:0,$
      olive:0,green:0,dark_gr:0,cyan:0,blue:0,dark_bl:0,magenta:0,$
      purple:0, white:0}
           
if (do_color eq 1) then begin
  if (keyword_set(table)) then linecolors,table=table else linecolors
               col.black = 0                                           
               col.maroon = 1                                          
               col.red = 2                                             
               col.pink = 3                                            
               col.orange = 4                                          
               col.yellow = 5                                          
               col.olive = 6                                           
               col.green = 7                                           
               col.dark_gr = 8                                         
               col.cyan = 9                                            
               col.blue = 10                                           
               col.dark_bl = 11                                        
               col.magenta = 12                                        
               col.purple = 13                                         
               col.white= 255
endif else begin 
  if (keyword_set(table)) then linecolors,table=table else linecolors,table=0
            col.black = 45	
            col.maroon = 150	
            col.red = 90	
            col.pink = 190	
            col.orange = 170	
            col.yellow = 210  
            col.olive = 100	
            col.green = 85	
            col.dark_gr = 60	
            col.cyan = 125	
            col.blue = 	75	
            col.dark_bl = 55	
            col.magenta = 110	
            col.purple = 85	
            col.white = 255
endelse                        

test_colors:

if (keyword_set(test)) then begin

if (keyword_set(print)) then begin
          nxsize = 22
          nysize = 16
          set_plot,'ps',/copy
          device,color=do_color,/landscape,bits=8,xoff=3,yoff=25,$
          xsize=nxsize,ysize=nysize,/bold,/times
endif

polyfill,/normal,[0,0,1,1,0],[0,1,1,0,0],color=col.white
if (do_color eq 2) then xt = 'Grayscale colors' else xt = 'Linecolors colors'
plot,/noerase,/nodata,/normal,[.2,.8],[.1,.9],color=col.black,$
    title='Testing Linecolors: available stark or pseudogray colors',xtitle=xt
xyouts,/normal,.4,.85,'black (00)------------',color=col.black,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.85,.90,.90,.85,.85],color=col.black
xyouts,/normal,.4,.80,'maroon (01)-----------',color=col.maroon,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.80,.85,.85,.80,.80],color=col.maroon
xyouts,/normal,.4,.75,'red (02)--------------',color=col.red,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.75,.80,.80,.75,.75],color=col.red
xyouts,/normal,.4,.70,'pink (03)-------------',color=col.pink,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.70,.75,.75,.70,.70],color=col.pink  
xyouts,/normal,.4,.65,'orange (04)-----------',color=col.orange,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.65,.70,.70,.65,.65],color=col.orange
xyouts,/normal,.4,.60,'yellow (05)-----------',color=col.yellow,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.60,.65,.65,.60,.60],color=col.yellow
xyouts,/normal,.4,.55,'olive (06)------------',color=col.olive,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.55,.60,.60,.55,.55],color=col.olive
xyouts,/normal,.4,.50,'green (07)------------',color=col.green,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.50,.55,.55,.50,.50],color=col.green
xyouts,/normal,.4,.45,'dark_gr (08)----------',color=col.dark_gr,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.45,.50,.50,.45,.45],color=col.dark_gr
xyouts,/normal,.4,.40,'cyan (09)-------------',color=col.cyan,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.40,.45,.45,.40,.40],color=col.cyan  
xyouts,/normal,.4,.35,'blue (10)-------------',color=col.blue,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.35,.40,.40,.35,.35],color=col.blue 
xyouts,/normal,.4,.30,'dark_bl (11)----------',color=col.dark_bl,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.30,.35,.35,.30,.30],color=col.dark_bl
xyouts,/normal,.4,.25,'magenta (12)----------',color=col.magenta,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.25,.30,.30,.25,.25],color=col.magenta
xyouts,/normal,.4,.20,'purple (13)-----------',color=col.purple,charsize=1.2,charthick=2
polyfill,/normal,[.6,.6,.8,.8,.6],[.20,.25,.25,.20,.20],color=col.purple

endif

if (keyword_set(print)) then begin
  psplot,color=do_color
  device,/close
  print,'Printed Linecolors Test Table in Postscript'
  set_plot,dev
endif
 
the_end:                       
return 
end
