pro fig_open,io,form,char,fignr,plotname,unit
;+
; Name        : FIG_OPEN
;
; Purpose     : Set device parameters to start a display or postscript-file
;		of a Figure
;
; Explanation : Controls setting of plot parameters regarding window size,
;		format, fonts, so that identical displays are produced
;		on the screen and in postscript files.
;
; Syntax      : IDL> fig_open,io,form,char 
;
; Examples    : IDL> io	 =1	;creates postscript file 
;		IDL> form=0	;landscape format
;               IDL> char=0.8	;smaller character size 
;		IDL> fignr='1'  ;figure number
;		IDL> plotname='f'
;		IDL> ref=' (Aschwanden et al. 1998)'  ;label at bottom of Fig.	
;               IDL> fig_open,io,form,char,fignr,plotname 
;               IDL> plot,randomu(seed,100)
;		IDL> fig_close,io,fignr,ref
;
; Inputs      : io	-  selection of plot option
;			   io=0 	screen (X-window)
;			   io=1		postscript file *.ps
;			   io=2		encapsulated postscript file
;			   io=3		color postscript file
;
;		form	-  plot format 
;			   form=0	landscape format
;			   form=1	portrait format
;
;		char	-  character size = !p.charsize
;
;               plotname - string for plotfile name
;
; History     : 1990, written
;		 9-OCT-1998, contribution to STEREO package, aschwand@lmsal.com
;		21-Jan-2000, devicename=!d.name, set_plot,devicename 
;		24-Jan-2000, common fig_open_setplot,original_device --> fig_close 
;			     set_plot='X' in unix, set_plot='WIN' for microsoft windows
;			     original_devicename is reset after producing ps-file in fig_close.pro
;		26-Jan-2000, add plotfilename as keyword to device 
;			     no device-dependent renaming required after creating idl.ps
;		31-Jul-2000  setting original_device disabled if ps-file was produced previously
;		26-Jan-2001  use free window unit   window,0-->window,/free
;-

common  fig_open_setplot,original_device,plotfile
if not(exist(unit)) then unit=next_window(/user)

filetype=''
if (io eq 1) then filetype='.ps'
if (io eq 2) then filetype='.eps'
if (io eq 3) then filetype='_col.ps'
plotfile=plotname+fignr+filetype

original_device=''
if (!d.name ne 'ps') then begin
 original_device=!d.name
 if (io eq 0) then begin
  set_plot,original_device		;'x' for x-windows, 'win' for microsoft 
  clearplot
 endif
endif
if (io ge  1) then set_plot,'ps'   
if (io ge  1) then device,filename=plotfile   
if (form mod 2 eq 0) then begin
 if (io le  0) and (form eq 0) then window,unit,xsize=640,ysize=512,retain=2
 if (io le  0) and (form eq 2) then window,unit,xsize=640*1.5,ysize=512*1.5,retain=2
 if (io le  0) and (form eq 4) then window,unit,xsize=640*2,ysize=512*2,retain=2
 if (io le  0) and (form eq 6) then window,unit,xsize=640*0.5,ysize=512*0.5,retain=2
 if (io eq  1) then device,/helvetica,/landscape,bits_per_pixel=8
 if (io eq  2) then device,/helvetica,/landscape,bits_per_pixel=8,/encapsulated
 if (io eq  3) then device,/helvetica,/landscape,/color,bits_per_pixel=8
endif
if (form eq 1) then begin
 if (io le  0) then window,unit,xsize=640,ysize=800,retain=2
 if (io eq  1) then device,/helvetica,/portrait,bits_per_pixel=8,$
	xsize=21.5-1.0,ysize=27.7-1.0,xoffset=1.0,yoffset=1.0
 if (io eq  2) then device,/helvetica,/portrait,bits_per_pixel=8,/encapsulated,$
	xsize=21.5-1.0,ysize=27.7-1.0,xoffset=1.0,yoffset=1.0
 if (io eq  3) then device,/helvetica,/portrait,/color,bits_per_pixel=8,$
	xsize=21.5-1.0,ysize=27.7-1.0,xoffset=1.0,yoffset=1.0
endif
if (io le  0) then !p.font=-1
if (io ge  1) then !p.font=0
!p.charsize=char
end
