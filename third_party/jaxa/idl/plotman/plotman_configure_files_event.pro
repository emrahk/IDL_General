; Modifications:
;   13-Aug-2003, Mimi. Call plotman_ps_form instead of ps_form so we can control local defaults settings

pro plotman_configure_files_event, event

widget_control, event.top, get_uvalue=state, /no_copy

widget_control, state.widgets.w_message, set_value=' '

plotobj = state.plotman_obj
output_control = plotobj -> get(/output_control)

   ; What kind of file to configure?

WIDGET_CONTROL, event.id, GET_UVALUE=whichFile
CASE whichFile OF
; changed call to plotman_ps_form, mimster@stars.gsfc.nasa.gov
   'confps': BEGIN
   	  geom = widget_info (event.top, /geom)
      newkeywords = PLOTMAN_PS_FORM(geom.xoffset+50, geom.yoffset+50, $
         DEFAULTS=output_control.ps, Parent=event.top, $
         LocalDefaults=output_control.pslocal, Cancel=cancel, Create=create)
      IF NOT cancel THEN output_control.ps = newkeywords
      IF create THEN WIDGET_CONTROL, state.widgets.psID, SEND_EVENT={ID:state.widgets.psID, $
         TOP:event.top, HANDLER:0L}
      END

   'confpsprint': BEGIN
   	  geom = widget_info (event.top, /geom)
      newkeywords = PLOTMAN_PS_FORM(geom.xoffset+50, geom.yoffset+50, $
         DEFAULTS=output_control.psprint, Parent=event.top, $
         LocalDefaults=output_control.pslocal, Cancel=cancel, Create=create)
      IF NOT cancel THEN output_control.psprint = newkeywords
      IF create THEN WIDGET_CONTROL, state.widgets.psID, SEND_EVENT={ID:state.widgets.psID, $
         TOP:event.top, HANDLER:0L}
      END

   'confpng': BEGIN
      config = output_control.png
      newConfiguration = plotman_fileform('PNG', config, $
         Cancel=cancel, Create=create, Parent=event.top)
      IF NOT cancel THEN output_control.png = newConfiguration
      IF create THEN WIDGET_CONTROL, state.widgets.pngID, SEND_EVENT={ID:state.widgets.pngID, $
         TOP:event.top, HANDLER:0L}
      END

   'conftiff': BEGIN
      config = output_control.tiff
      newConfiguration = plotman_fileform('TIFF', config, $
         Cancel=cancel, Create=create, Parent=event.top)
      IF NOT cancel THEN output_control.tiff = newConfiguration
      IF create THEN WIDGET_CONTROL, state.widgets.tiffID, SEND_EVENT={ID:state.widgets.tiffID, $
         TOP:event.top, HANDLER:0L}
      END

   'confjpeg': BEGIN
      config = output_control.jpeg
      newConfiguration = plotman_fileform('JPEG', config, $
         Cancel=cancel, Create=create, Parent=event.top)
      IF NOT cancel THEN output_control.jpeg = newConfiguration
      IF create THEN WIDGET_CONTROL, state.widgets.jpegID, SEND_EVENT={ID:state.widgets.jpegID, $
         TOP:event.top, HANDLER:0L}
      END
ENDCASE

plotobj -> set, output_control=output_control

WIDGET_CONTROL, event.top, SET_UVALUE=state, /NO_COPY
END ; of XWINDOW_CONFIGURE_FILES event handler ***********************************
