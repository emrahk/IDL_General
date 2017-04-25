;+
; NAME:
;       WOBJECT
; PURPOSE:
;      create template widget window with buttons
; CALLING SEQUENCE:
;      wobject,popts,pvalues,topts,doneb,plotb,base,draw,label,$
;            xsize=xsize,ysize=ysize
; INPUTS:
;      popts   = string array of button names (e.g. ['CAT', 'MOUSE','DOG'])
;      pvalues = string array of button values
;      topts   = array of tool options (e.g, ['LOG', 'CONTOUR'])
; OUTPUTS     
;      doneb   = widget id of done button
;      plotb   = widget id of plot buttons
;      base    = widget id of main base
;      draw    = id of draw widget
;      label   = id of draw label
;      tbase   = widget id of base holding tool buttons
; KEYWORDS:
;      xsize,ysize = usual widget sizing parameters
; RESTRICTIONS:
;      This is a simple object that must be realized as part of a main
;      application. No error checking is performed, so you have to know
;      what you are doing.
; MODIFICATION HISTORY:     
;      DMZ (ARC) Jun'92
;-

pro wobject,popts,pvalues,topts,doneb,plotb,base,draw,label,done,$
            tbase=tbase,pbase=pbase,$
            xsize=xsize,ysize=ysize,title=title

device,get_screen_size=sc
xfac=(sc(0)/1280.) 
yfac=(sc(1)/1024.)

if n_elements(title) eq 0 then title=''
if n_elements(xsize) eq 0 then xsize=512*xfac
if n_elements(ysize) eq 0 then ysize=512*yfac

base=widget_base(title=title,/column)
row1=widget_base(base,/row)
r1c1=widget_base(row1,/column)
draw=widget_draw(r1c1,xsize=xsize,ysize=ysize,retain=2,/button_events)
label=widget_text(r1c1,ysize=10*yfac,/frame,/scroll)

;-- plot options

r1c2=widget_base(row1,/column)
pbase=widget_base(r1c2,/column)

npb=n_elements(pvalues) & plotb=lonarr(npb)
xmenu,popts,pbase,buttons=plotb,/nonexclusive,/column,$
 title='PLOT OPTIONS',uvalue=pvalues

;-- tools

tbase=widget_base(title='TOOLS',r1c2,/column,/frame)   

xpdmenu,topts,tbase,/column,title='TOOLS'


;-- done button

r1c2r2r3=widget_base(r1c2,/column)   

done=widget_button(r1c2r2r3,value=doneb(0),uvalue=doneb(1),/no_release,/frame)

return & end

