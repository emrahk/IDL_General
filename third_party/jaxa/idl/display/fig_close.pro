pro fig_close,io,fignr,ref
;+
; Name        : FIG_CLOSE 
;
; Purpose     : Finish a plot in a postscript-file of a figure
;
; Category    : Graphics, Utility 
;
; Explanation : Draws figure label, closes postscript file, and
;		choses a suitable plotfilename 
;
; Syntax      : IDL> fig_close,io,fignr,ref,plotname,plotfile
;
; Examples    : IDL> io	 =1	;creates postscript file 
;		IDL> form=0	;landscape format
;               IDL> char=0.8	;smaller character size 
;		IDL> fignr='1'  ;figure number
;               IDL> plotname='f'
;		IDL> ref=' (Aschwanden et al. 1998)'  ;label at bottom of Fig.	
;		IDL> plotname='f'
;               IDL> fig_open,io,form,char,fignr,plotname
;               IDL> plot,randomu(seed,100)
;		IDL> fig_close,io,fignr,ref
;		IDL> $lpr plotfile
;
; Inputs      : io	-  selection of plot option
;			   io=0 	screen (X-window)
;			   io=1		postscript file *.ps
;			   io=2		encapsulated postscript file
;			   io=3		color postscript file
;
;		fignr	-  string concatenated with name of plotfile 
;
;		ref	-  text string going into figure label
;
;		plotname - string for plotfile name 
;
; Outputs     : plotfile - full name of plotfile 
;
; History     : 1998-Oct-09, written. aschwand@sag.lmsal.com
;		2000-Jan-24, common fig_open_setplot,original_device -> set_plot,original_device
;		2000-Jan-26, filenaming is moved to routine FIG_OPEN (device-independent)
;               31-Jul-2000  setting original_device disabled if ps-file was produced previously

;-

common  fig_open_setplot,original_device,plotfile

figure	='Figure '+fignr+' : '+ref
nlen	=strlen(figure)
if (ref ne '') then xyouts,0.5-0.0035*nlen,0.0,figure,size=0.8,/normal

if (io ge 1) then begin
 device,/close
 print,'plotfile = ',plotfile+' created!' 
 if (original_device ne '') then set_plot,original_device
endif
end

