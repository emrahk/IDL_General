;+
; Name:
;
;      XYCURSOR
;
; Purpose:
;
;      Full-sized cross-hair cursor in a plot window
;
; Category:
;
;      Plot
;
; Calling sequence:
;
;      XYCURSOR, X, Y [ , BUTTON=button , ALT_CURSOR=alt_cursor , 
;                       /DATA , /NORMAL , /DEVICE , /PRINT , /NO_LF , 
;                       ... other PLOTS keywords ... ]
;
; Input:
;
;      None
;
; Keyword parameters:
;
;      BUTTON: 1=left button; 2=middle button; 4=right button
;      DATA:    (0/1=def) set this keyword to get data coordinates (default)
;      NORMAL:  (0=def/1) set this keyword to get normalized coordinates 
;      DEVICE:  (0=def/1) set this keyword to get device coordinates 
;      ALT_CURSOR: controls appearance of cursor
;      PRINT:   (0=def/1) print current coordinates?
;      NO_LF:   (0=def/1) Line feed before returning? (Only if kwd PRINT is set)
;      In addition: 
;        all keyword accepted by PLOTS
;
; Output:
;
;      X : cursor's latest abscissa
;      Y : cursor's latest ordinate
;
; Common blocks:
;
;      None
;
; Calls:
;
;      TVCRS,CURSOR,PLOTS,CONVERT_COORD
;
; Description:
;
;      - Plots a cross-hair cursor spanning the entire X- and Y-range of an 
;      existing plot (with /NOCLIP: cross-hair spans the full screen). 
;      Initial position is at center of plot window.
;      - If requested, prints the current cursor coordinates. 
;      - Exits when any mouse button is pressed; returns to caller as soon 
;      as the button is released. 
;      - Returns the coordinates of the cursor at the time the button was 
;      pressed (not at the time it was released), as well as an integer 
;      specifying which button was pressed (keyword BUTTON, taken directly 
;      from !MOUSE.BUTTON). Coordinates can be data (the default), device 
;      or normalized. 
;      - By default (X Windows only), current cursor shape is masked out. 
;      Setting keyword ALT_CURSOR explicitly to 0 can prevent that; non-zero 
;      values specify other cursor shapes (device dependent).
;      - All keywords valid for PLOTS are also accepted. 
;
; Side effects:
;
;      This routine temporarily changes some device settings using the 
;      following DEVICE keywords:
;
;        GET_GRAPHICS_FUNCTION
;        SET_GRAPHICS_FUNCTION
;        CURSOR_IMAGE (X-windows only and if ALT_CURSOR is undefined)
;        CURSOR_STANDARD (if ALT_CURSOR is defined and NE 0)
;        CURSOR_CROSSHAIR (unless ALT_CURSOR is defined and EQ 0)
;
;      Before exiting, this routine resets the device to its initial graphic 
;      function and (unless ALT_CURSOR EQ 0) to the default cross-hair cursor. 
;      Should an unexpected error occur, the routine also tries to return the 
;      device to its original state. In case that too would fail, reset 
;      the device as follow:
;
;         DEVICE,SET_GRAPHICS_FUNCTION=3 ; or whatever it was before
;         DEVICE,/CURSOR_CROSSHAIR       ; usually the default for X Windows
;      or
;         DEVICE,CURSOR_STANDARD=n       ; n=predefined index of cursor image
;
;      The latter might be necessary if a non-standard cursor was defined 
;      before calling XYCURSOR. 
;      See also IDL documentation on 'Keywords for DEVICE Procedure'.
;
; Restrictions and notes:
;
;      - Do not use within draw widgets (see documentation of routine CURSOR).
;      - Uses current coordinate system, which might not be the right one  
;      for the current window (e.g., after a call to WSET).
;      - Tested on X windows only. However, if ALT_CURSOR is not set  
;      (either 0 or undefined), it will probably work with most graphical 
;      interfaces. 
;
; Modification history:
;
; v1:  V. Andretta, 23/Feb/1998 - Created
;      V. Andretta, 25/Feb/1998 - Modified: returns the button index
; v2:  V. Andretta, 12/Mar/1998 - Largely rewritten (taking also a few tips 
;        from similar routine CURFULL of IDL Astronomy User's Library): 
;        - improved error handling (trying to restore the state of the device);
;        - changed cycle to make redrawing of lines as close as possible in 
;          time and reducing the number of calls to DEVICE (now safer because 
;          of the better error handling);
;        - made PLOTS inherit _EXTRA keywords (NOCLIP, LINESTYLE and such);
;        - changed printout format: added specification of coordinate type;
;        - added ALT_CURSOR keyword.
;
; Contact:
;
;      andretta@gsfc.nasa.gov
;
;-
;===============================================================================
;
  pro XYCURSOR,Xc,Yc,BUTTON=button $
              ,DATA=k_data,NORMAL=k_normal,DEVICE=k_device $
              ,ALT_CURSOR=alt_cursor $
              ,PRINT=k_print,NO_LF=no_lf $
              ,_EXTRA=extra_plot


;*> on error, return to caller

  on_error,2


;*> check if current device supports windows before continuing

  if (!D.flags and 256) ne 256 then $
    message,'Current graphics device ('+!D.name+') does not support windows'


;*> some definitions and defaults

  print=keyword_set(k_print)

  NoCurImg=!D.name eq 'X' and n_elements(alt_cursor) eq 0

  CR=string("15B)
  format='"X = ",A," ; Y = ",A,A,$'

;type of coordinates; 
;in case of conflict, priority goes to: 1) DATA, 2) DEVICE, 3) NORMAL
  case 1 of
    keyword_set(k_data)  : begin
                             device=0 & normal=0 & data=1
                             format='("DATA:   ",'+format+')'
                           end
    keyword_set(k_device): begin
                             device=1 & normal=0 & data=0
                             format='("DEVICE: ",'+format+')'
                           end
    keyword_set(k_normal): begin
                             device=0 & normal=1 & data=0
                             format='("NORMAL: ",'+format+')'
                           end
    else:                  begin
                             device=0 & normal=0 & data=1
                             format='("DATA:   ",'+format+')'
                           end
  endcase


;*> save current graphic function (normally: 3 = GXcopy)

  device,GET_GRAPHICS=orig_mode


;*> initialize coordinates and cursor position

;if no coordinate system is currently defined, create one:
  if max(abs(!X.crange)) eq 0 then $
    plot,[0,1],[0,1],XMARGIN=[0,0],YMARGIN=[0,0],XSTYLE=5,YSTYLE=5,/NODATA

;find window size in user coordinates
  Xwindow=[0.,1.]
  Ywindow=[0.,1.]
  if not normal then begin
    coord=convert_coord(Xwindow,Ywindow,/NORMAL,TO_DATA=data,TO_DEVICE=device)
    Xwindow(*)=coord(0,0:1)
    Ywindow(*)=coord(1,0:1)
  endif

;find coordinate of the center of the plot window in user coordinates
  Xc_old=0.5*(!X.crange(0)+!X.crange(1))
  Yc_old=0.5*(!Y.crange(0)+!Y.crange(1))
  if !X.type eq 1 then Xc_old=10.^Xc_old
  if !Y.type eq 1 then Yc_old=10.^Yc_old
  if not data then begin
    coord=convert_coord(Xc_old,Yc_old,/DATA,TO_DEVICE=device,TO_NORMAL=normal)
    Xc_old=coord(0)
    Yc_old=coord(1)
  endif


;*> start-up

;put cursor at center of plot window...
  tvcrs,Xc_old,Yc_old,DATA=data,NORMAL=normal,DEVICE=device

;...and print initial position
  if print then print,string(Xc_old),string(Yc_old),CR,FORMAT=format

;redefine cursor appearance
  if keyword_set(alt_cursor) then $
    device,CURSOR_STANDARD=alt_cursor $
  else $
    if NoCurImg then device,CURSOR_IMAGE=intarr(16)

;SET_GRAPHICS_FUNCTION keyword of DEVICE set to 6: GXxor (XOR operator)
  device,SET_GRAPHICS=6


;*> from now on, when an unexpected error occurs, will try to restore 
;*> the device to its original state

  catch,error
  if error ne 0 then begin
;back to default error handling
    catch,/CANCEL
;print error message
    if print then print,form='($,/)'
    print,!msg_prefix+'XYCURSOR: Unexpected error.'
    print,!msg_prefix+!err_string
;restore device to original state (see also 'Restrictions'). If the routine has 
;gone so far, the variable ORIG_MODE should already been defined.
    device,SET_GRAPHICS=orig_mode
    if keyword_set(alt_cursor) or NoCurImg then device,/CURSOR_CROSSHAIR
;return
    return
  endif


;*> main cycle: ends when any button is pressed and then released

  repeat begin

;plot cursor at the old position
    plots,[Xc_old,Xc_old],Ywindow,DATA=data,NORMAL=normal,DEVICE=device $
         ,NOCLIP=0,_EXTRA=extra_plot
    plots,Xwindow,[Yc_old,Yc_old],DATA=data,NORMAL=normal,DEVICE=device $
         ,NOCLIP=0,_EXTRA=extra_plot

;get new cursor position (and button ID) upon change of state 
    cursor,Xc,Yc,/CHANGE,DATA=data,NORMAL=normal,DEVICE=device
    button=!mouse.button
;if a button was pressed, wait for it to be relased
    if button ne 0 then cursor,Xc_dum,Yc_dum,/UP

;delete cross-hair cursor at the old position
    plots,[Xc_old,Xc_old],Ywindow,DATA=data,NORMAL=normal,DEVICE=device $
         ,NOCLIP=0,_EXTRA=extra_plot
    plots,Xwindow,[Yc_old,Yc_old],DATA=data,NORMAL=normal,DEVICE=device $
         ,NOCLIP=0,_EXTRA=extra_plot

;convert coordinates to floating point type (device coordinates are 
;usually integers).
    Xc=float(Xc)
    Yc=float(Yc)
;get ready for the next change of state of the cursor
    Xc_old=Xc
    Yc_old=Yc

;print current position
    if print then print,string(Xc),string(Yc),CR,FORMAT=format

;end cycle

  endrep until button ne 0


;*> finish-up: 

;restore device graphic function to its original value
  device,SET_GRAPHICS=orig_mode

;restore cursor shape
  if keyword_set(alt_cursor) or NoCurImg then device,/CURSOR_CROSSHAIR

;line feed: 
  if print and not keyword_set(no_lf) then print,form='($,/)'


;*> return

  return
  end


