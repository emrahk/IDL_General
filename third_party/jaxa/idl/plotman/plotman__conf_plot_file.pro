;+
; Name: PLOTMAN::CONF_PLOT_FILE
; Purpose: Configure parameters for output plot file
; Method:  Plotman stores a configuration structure for each type of output in output_control.
;   This method provides a widget interface to change the settings in the output_control.xx
;   structure for the xx file type.
;
; Keyword Arguments:
;   ps- if set, configure PostScript file output
;   print - if set, configure PostScript file output for printing
;   png - if set, configure PNG file output
;   tiff - if set, configure TIFF file output
;   jpeg - if set, configure JPEG file output
;
; Written: Kim Tolbert 2000?
; Modifications:
; 13-Aug-2003, Mimi. Call plotman_ps_form instead of ps_form so we can control local defaults settings
; 21-Nov-2008, Kim.  Converted from a routine (plotman_configure_files_event) to a method with arguments
;  to select what to do (was in event structure before) 
;-
pro plotman::conf_plot_file, ps=ps, print=print, png=png, tiff=tiff, jpeg=jpeg

w = self -> get(/widgets)
widget_control, w.w_message, set_value=' '

output_control = self -> get(/output_control)

; What kind of file to configure?
ps = keyword_set(ps)
png = keyword_set(png)
tiff = keyword_set(tiff)
jpeg = keyword_set(jpeg)
printplot = keyword_set(print)

CASE 1 OF

   ps: BEGIN
   	  geom = widget_info (w.plot_base, /geom)
      newkeywords = PLOTMAN_PS_FORM(geom.xoffset+50, geom.yoffset+50, $
         DEFAULTS=output_control.ps, Parent=w.plot_base, $
         LocalDefaults=output_control.pslocal, Cancel=cancel, Create=create)
      IF NOT cancel THEN begin
        output_control.ps = newkeywords
        self -> set, output_control=output_control
        IF create THEN self -> create_plot_file,/ps
      endif
      END

   printplot: BEGIN
   	  geom = widget_info (w.plot_base, /geom)
      newkeywords = PLOTMAN_PS_FORM(geom.xoffset+50, geom.yoffset+50, $
         DEFAULTS=output_control.psprint, Parent=w.plot_base, $
         LocalDefaults=output_control.pslocal, Cancel=cancel, Create=create)
      IF NOT cancel THEN begin
        output_control.psprint = newkeywords
        self -> set, output_control=output_control
        IF create THEN self -> create_plot_file,/print
      endif
      END

   png: BEGIN
      config = output_control.png
      newConfiguration = plotman_fileform('PNG', config, $
         Cancel=cancel, Create=create, Parent=w.plot_base)
      IF NOT cancel THEN begin
        output_control.png = newConfiguration
        self -> set, output_control=output_control
        IF create THEN self -> create_plot_file,/png
      endif
      END

   tiff: BEGIN
      config = output_control.tiff
      newConfiguration = plotman_fileform('TIFF', config, $
         Cancel=cancel, Create=create, Parent=w.plot_base)
      IF NOT cancel THEN begin
        output_control.tiff = newConfiguration
        self -> set, output_control=output_control
        IF create THEN self -> create_plot_file,/tiff
      endif
      END

   jpeg: BEGIN
      config = output_control.jpeg
      newConfiguration = plotman_fileform('JPEG', config, $
         Cancel=cancel, Create=create, Parent=w.plot_base)
      IF NOT cancel THEN begin
        output_control.jpeg = newConfiguration
        self -> set, output_control=output_control
        IF create THEN self -> create_plot_file,/jpeg
      endif
      END
ENDCASE

END 
