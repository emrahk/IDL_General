;; =============================================================================
;+
; NAME:
;       ZOOM_PLOT_EVENTS
;
; PURPOSE:
;
;       Event handler for 'zoom_plot.pro'.
;       This event handler ONLY responds to button down events from the
;       draw widget. If it gets a DOWN event, it does three things: (1) sets
;       the static and dynamic corners of the arrow box, (2) changes the
;       event handler for the draw widget to ZOOM_PLOT_DRAWBOX and turns on MOTION
;       events, and (3) update the user's color table vectors.
;
; AUTHOR:
;
;   'zoom_plot.pro' is based on 'zplot.pro' by
;
;   FANNING SOFTWARE CONSULTING
;   David Fanning, Ph.D.
;   1645 Sheely Drive
;   Fort Collins, CO 80526 USA
;   Phone: 970-221-0438
;   E-mail: davidf@dfanning.com
;   Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; MODIFICATION HISTORY:
;
;        Written by: David Fanning, 15 February 2000.
;        Modified the original rubberband box to be an "arrow box". 1 April 2000. DWF.
;-
;; =============================================================================
;
;###############################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Fanning Software Consulting
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###############################################################################



;-------------------------------------------------------------------------------
;
; PURPOSE: This event handler ONLY responds to button down events from the
;     draw widget. If it gets a DOWN event, it does three things: (1) sets
;     the static and dynamic corners of the arrow box, (2) changes the
;     event handler for the draw widget to ZOOM_PLOT_DRAWBOX and turns on MOTION
;     events, and (3) update the user's color table vectors.
;
PRO ZOOM_PLOT_EVENTS, event
   
   possibleEventTypes = [ 'DOWN', 'UP', 'MOTION', 'SCROLL' ]
   thisEvent = possibleEventTypes(event.type)
   
   parent = widget_info(event.handler,/parent)
   
   IF thisEvent NE 'DOWN' THEN RETURN

   ;; Must be DOWN event to get here, so get info structure.
   ;;
   Widget_Control, parent, Get_UValue=info, /No_Copy
   
   possibleButtonTypes = [ 'EMPTY', 'LEFT', 'MIDDLE', 'EMPTY', 'RIGHT']
   thisButton = possibleButtonTypes(event.press)
   info.mouseButton = thisButton
   
   ;; Set the static corners of the arrow box to current
   ;; cursor location.
   ;;
   info.xs = event.x
   info.ys = event.y
   
   ;; Change the event handler for either
   ;; the x-draw or the y-draw widget and turn MOTION events ON.
   ;;
   Widget_Control, event.id, Event_Pro='ZOOM_PLOT_DRAWBOX', $
     Draw_Motion_Events=1
 
   ;; Put the info structure back into its storage location.
   ;;
   Widget_Control, parent, Set_UValue=info, /No_Copy

END 
;; of ZOOM_PLOT_EVENTS ---------------------------------------------------------

;
;-------------------------------------------------------------------------------




