pro event_movie2, times, outimg, data=data, $
   outsize=outsize, charsize=charsize, zbuff=zbuff, $
   goes=goes, femgrid=femgrid, color=color, twindow=twindow, $
   gcolor=gcolor, ncolor=ncolor, scolor=scolor, ticks=ticks, tcolor=tcolor, $
   default=default, summary=summary, status=status, reverse=reverse, $
   debug=debug
;+
;   Name: event_movie
;
;   Purpose: form a 3D plot movie from UT events (via evt_grid)
;
;   Input Parameters:
;      times - event times (any SSW format, index structures, etc.)
;
;   Output Parameters:
;     outimg - movie cube of plots with events overlayed
;
;   Keyword Parameters:
;      data - if set and 3D, concatentate data to plot
;      goes - if set, use plot goes (time window around events)
;      charsize - if set, character size
;      color - color for event lines
;      gcolor - (goes only - goes grid color)
;      ncolor - (fem only - color for night/day )
;      scolor - (fem only - color for SAA)
;
;   Calling Sequence:
;      Two Primary Uses:
;      1. IDL> utplot [any user utplot...]		; overlay on user plot
;	  IDL> event_movie,times [,data=d3D]    
;
;      2. IDL>event_movie,times, outmovie, [data=d3D] , /goes 	; GOES overlay 
;         IDL>event_movie,times, outmovie, /default    ; same w/ std colors and yohoh fem
;
;   Calling Examples:
;      IDL> event_movie, index, gmovie, /goes  ; goes plot using index times
;      IDL> event_movie, index, gmovie, data=data, ,/goes ; same but
;                                                         ; concatentate data
;   History:
;      25-oct-1995 (SLF) - movie production
;       6-Nov-1995 (SLF) - cleaned up, defaults, ...
;      17-nov-1995 (SLF) - auto scale goes
;      12-Apr-1999 (S.L.Freeland) - more generic->SSW, $
;                            defaults->event_movie_defaults.pro
;      24-Apr-1999 (S.L.Freeland) - fix a color problem
;	18-Dec-2002, William Thompson, GSFC, Changed !COLOR to !P.COLOR
;
;   Warnings:
;     Temporarily sets graphics device to 6
;   
;   Restrictions:
;      For now, 'plot_goes' requires at least one Yohkoh instrument in path
;  
;-
savesys,/aplot                          ; save plot variable status
summary=keyword_set(summary)
default=keyword_set(default)
reverse=keyword_set(reverse)
nt=n_elements(times)
dtemp=!d.name
debug=keyword_set(debug)

tsecs= max(int2secarr(anytim2ints(times)))  
if n_elements(default) ne 0 then $
   event_movie_defaults,0, zbuff=zbuff, goes=goes, color=color, $
		 tcolor=tcolor, gcolor=gcolor
delvarx,goes

plotgoes=keyword_set(goes)
femgrid=keyword_set(femgrid) or keyword_set(ncolor) or keyword_set(scolor)
ticks=keyword_set(ticks) or keyword_set(tcolor)
if not keyword_set(color) then color=150

if not keyword_set(twindow) then twindow=30      ; +/- minutes for plot

; overplots may be from existing window
isx=!d.name eq 'X' and !d.window ne -1
usex=isx and (1-plotgoes)                        ; use current X window plot
usez=!d.name eq 'Z' and (1-plotgoes)

dx=data_chk(data,/nx)
dy=data_chk(data,/ny)

case 1 of 
   data_chk(outsize,/def):                     ; user supplied

   dx gt 0: outsize=[dx,dx/3]                  ; aspect = 3:1
   else: outsize=[256,128]                     ; 
endcase

;stop,'outimg'
outimg=make_array(outsize(0),outsize(1),nt,/byte)

; save status
stemp=!p.charsize

zbuff=keyword_set(zbuff)
; user current X window?

case 1 of
   usez:
   usex: begin
      savesys,/aplot
      xdat=tvrd()                                         ; use current X plot ?
   endcase
   else:  wdef,xx,outsize(0),outsize(1),zbuffer=zbuff ; make x/z window
endcase

; if not supplied, scale character size according to Y size
if keyword_set(charsize) then csize=charsize else $
   charsize=.5  + ( (outsize(1)/128) * .1) < 2.

!p.charsize=charsize

set_plot,(['x','z'])(zbuff)

if default then begin
   tvlct,r0,g0,b0,/get
   linecolors
   tvlct,r1,g1,b1,/get   
   tvlct,[r0(0),r1(1:14),r0(15:*)], [g0(0),g1(1:14),g0(15:*)],[b0(0),b1(1:14),b0(15:*)]
endif

device,get_graphics=gtemp
device,set_graphics=3

status=1-plotgoes
xxcolor=([([!p.color,5])(default),100])(reverse)
bkcolor=([([0,11])(default),!p.color-10])(keyword_set(reverse))
!p.color=xxcolor

help,reverse,xxcolor,bkcolor

case 1 of 
   usez: 
   usex: begin   
            tv,xdat 
            restsys,/aplot
   endcase
   plotgoes: begin
      plot_goes, status=status, $
      timegrid(times(0), min=-(twindow),/string), $
      timegrid(times(nt-1), min=twindow,/string),/xstyle, $
      background=bkcolor,  color=xxcolor,  gcolor=gcolor, $
      five_minute=(tsecs gt 2.*86400.),/lo
      endcase
   else:
endcase


if not status then return		;*** unstructured exit, NO GOES data

; overlay Yohkoh ephemeris on request   ; slf, 12-apr - use exe for compile...
if femgrid then $
    exestat=execute("fem_grid, /fillsaa, /fillnight, ncolor=ncolor, scolor=scolor")

fname='event_' + str_replace(ex2fid(anytim2ex(times(0)),/sec),'.','_') + '_'

; overlay event TICKS on request
if n_elements(tcolor) eq 0 then tcolor=color
tcolor=200

if keyword_set(ticks) then evt_grid,times, color=tcolor, thick=2, $
   /quiet,tickpos=.85

; source XOR destination		; so movie "erases" previous line
device,set_graphics=6   

; for each event time...
if summary then nt=1
for i=0,nt-1 do begin
   evt_grid,times(i),lines=0, color=tcolor,thick=2,/quiet           ; mark event
   if i ne 0 then $
   evt_grid,times(i-1),lines=0,color=tcolor,thick=2,/quiet         ; erase last
   im=tvrd()                                               ; read image
   outimg(0,0,i)=im                                        ; fill movie
endfor

if debug then stop
if summary then outimg=temporary(outimg(*,*,0))
if keyword_set(data) then outimg=[[data],[temporary(outimg)]]

; -----------  restore status ------------
!p.charsize=stemp
device,set_graphics=gtemp
set_plot,dtemp
; ----------------------------------------

restsys,/aplot                                  ; restore status
return
end
