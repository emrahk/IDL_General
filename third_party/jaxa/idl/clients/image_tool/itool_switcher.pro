PRO itool_switcher, target_tool

;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_SWITCHER
;
; PURPOSE: 
;       Switch tools in Image Tool (from curr_tool to prev_tool)
;
; CATEGORY:
;       Image Tool
; 
; SYNTAX: 
;       itool_switcher
;
; OUTPUTS:
;       None.
;
; HISTORY:
;       Version 1, August 21, 1997, Liyun Wang, NASA/GSFC. Written
;       Modified, 12-Jan-2006, Zarro (L-3Com/GSFC) - added check for
;        invalid unused target widget base
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
@image_tool_com   

   IF N_ELEMENTS(target_tool) EQ 0 THEN target_tool = prev_tool

   IF target_tool GT N_ELEMENTS(tools.uvalue) THEN target_tool = 0

   if not widget_valid(tools(target_tool).base) then return

   CASE (tools(curr_tool).uvalue) OF
;---------------------------------------------------------------------------
;     Do some clean up work before leaving current tool
;---------------------------------------------------------------------------
      'lftool': limbfit_cleanup
      'magnifier': itool_magnify_cleanup
      'profiler': itool_magnify_cleanup
      'ptool': BEGIN
         IF NOT exit_ok THEN BEGIN
            exit_ok = xanswer(['Warning!!!', $
                               'Not all pointing values are changed.', $
                               'Do you wish to quit Pointing Tool any way?'], $
                              /beep, /center,/suppress)
            IF NOT exit_ok THEN RETURN
         ENDIF
      END
      ELSE:
   ENDCASE

   WIDGET_CONTROL, tools(curr_tool).base, map=0
   WIDGET_CONTROL, tools(target_tool).base, map=1
   prev_tool = curr_tool
   curr_tool = target_tool
   mesg = ''
   mesg_general = $
      'Press and drag the left button to select a subimage. Press and '+$
      'drag the right button to move a selected region box.'
   CASE (tools(curr_tool).uvalue) OF
;---------------------------------------------------------------------------
;     Do some initial setup for the newly switched tool
;---------------------------------------------------------------------------
      'ptool': BEGIN
         pt_refresh_base
         mesg = 'Press the "Go" button to begin positioning the raster '+$
            'or FOV; press "Accept" or "Cancel" when done.'
         WIDGET_CONTROL, comment_id, set_value=mesg
      END 
      'lftool': BEGIN
         WIDGET_CONTROL, draw_id, draw_motion=1
         WIDGET_CONTROL, draw_icon, draw_button=0
         make_manual_fit
         mesg = 'Click the left button to select enough points on the '+$
            'limb. Press the "Accept" or "Cancel" button when done.' 
         WIDGET_CONTROL, comment_id, set_value=mesg
      END
      'overlay': BEGIN
         mesg = ['Click the right mouse button over any images on the image '+$
                 'stack to load it onto the Overlayer.', mesg_general]
         WIDGET_CONTROL, comment_id, set_value=mesg
      END 
      'magnifier': BEGIN
         mesg = 'Move the mouse cursor over the image to magnify. Click '+$
            'right button to quit Magnifier.'
         WIDGET_CONTROL, comment_id, set_value=mesg
         itool_magnify_run
      END
      'profiler': BEGIN
         mesg = 'Move the mouse cursor over the image to see image profile; '+$
            'click left button to toggle row/column. Click right button to '+$
            'quit Profiler.'
         WIDGET_CONTROL, comment_id, set_value=mesg
         itool_profiler_run
      END
      ELSE:
   ENDCASE
END

