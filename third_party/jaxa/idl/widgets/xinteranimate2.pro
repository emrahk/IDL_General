; $Id: xinteranimate2.pro,v 1.29 2004/06/07 20:07:26 scottm Exp $
;
; Copyright (c) 1992-2004, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.

;+
; NAME:
;		XINTERANIMATE2
;
; PURPOSE:
;	Display an animated sequence of images using X-windows Pixmaps.
;	The speed and direction of the display can be adjusted using
;	the widget interface.
;
; CATEGORY:
;	Image display, widgets.
;
; CALLING SEQUENCE:
;	To initialize:
;		XINTERANIMATE2, SET = [Sizex, Sizey, Nframes]
;
;	To load a single image:
;		XINTERANIMATE2, IMAGE = Image, FRAME = Frame_Index
;
;	To load a single image that is already displayed in an existing window:
;		XINTERANIMATE2, FRAME = Frame_index, $
;			WINDOW = [Window_Number [, X0, Y0, Sx, Sy]]
;	(This technique is much faster than reading back from the window.)
;
;	To display the animation after all the images have been loaded:
;		XINTERANIMATE2 [, Rate]
;
;	To close and deallocate the pixmap/buffer (which also takes place
;	automatically when the user presses the "Done With Animation"
;	button or closes the window with the window manager):
;		XINTERANIMATE2, /CLOSE
;
; OPTIONAL INPUTS:
;	Rate:	A value between 0 and 100 that represents the speed of the
;		animation as a percentage of the maximum display rate.
;		The fastest animation is with a value of 100 and the slowest
;		is with a value of 0.  The default animation rate is 100.
;		The animation must be initialized using the SET
;		keyword before calling XINTERANIMATE2 with a rate value.
;
; KEYWORD PARAMETERS:
;	CLOSE:	Set this keyword to delete the offscreen pixwins and Widget,
;		freeing storage.
;
;	CYCLE: If set, cycle.  Normally, frames are displayed going either
;		forward or backwards.  If CYCLE is set, reverse direction
;		after the last frame in either direction is displayed.
;		Provide this keyword with the SET keyword.
;
;	FRAME:	The frame number when loading frames.  This keyword only has
;		an effect when used in conjunction with the SET keyword.
;		FRAME must be set to a number in the range 0 to Nframes-1.
;
;	GROUP:	The widget ID of the widget that calls XINTERANIMATE2.  When
;		this ID is specified, the death of the caller results in the
;		death of XINTERANIMATE2.
;
;	IMAGE:	A single image to be loaded at the animation position given
;		by FRAME.  The keyword parameter FRAME must also be specified.
;
;	KEEP_PIXMAPS: If TRUE, XINTERANIMATE2 doesn't destroy the animation
;		pixmaps when it is killed. Calling it again without
;		going through the SET and LOAD steps will cause the same
;		animation to play without the overhead of creating
;		the pixmaps.
;	BLOCK:  Set this keyword to have XMANAGER block when this
;		application is registered.  By default the Xmanager
;               keyword NO_BLOCK is set to 1 to provide access to the
;               command line if active command 	line processing is available.
;               Note that setting BLOCK for this application will cause
;		all widget applications to block, not only this
;		application.  For more information see the NO_BLOCK keyword
;		to XMANAGER.
;	ORDER:	Set this keyword to display images from the top down instead
;		of the default bottom up.  This keyword is only used when
;		loading images.
;       MODAL:  If set, then XINTERANIMATE2 runs in "modal" mode, meaning that
;               all other widgets are blocked until the user quits
;               XINTERANIMATE2.
;       MPEG_OPEN: Set this keyword to open an MPEG file.
;       MPEG_FILENAME: Set this keyword equal to a string for the desired
;               MPEG filename.  If not set, idl.mpg is used.
;       MPEG_QUALITY : Set this keyword to a value between 0 (low quality)
;               and 100 (high quality) to control the quality of the movie file.
;       MPEG_BITRATE, MPEG_IFRAME_GAP, MPEG_MOTION_VEC_LENGTH : See the
;               documentation for the IDLgrMPEG object for information on
;               using these keywords for finer control of the MPEG quality.
;               In most situations, the MPEG_QUALITY keyword should be
;               sufficient.
;       MPEG_CLOSE: Set this keyword to write the MPEG file.
;     SHOWLOAD:	Set this keyword (in conjunction with the SET keyword) to
;		display each frame and update the frame slider as frames are
;		loaded.
;
;	SET:	This keyword initializes XINTERANIMATE2.  SET should be equated
;		to a 3-element integer vector containing the following
;		parameters:
;		  Sizex, Sizey:	The width and height of the images to be
;				displayed, in pixels.
;
;		  Nframes:	The number of frames in the animated sequence
;				(since XINTERANIMATE2 is an animation routine,
;				Nframes must be at least 2 frames).
;
;	TITLE:	A string to be used as the title of the widget.  If this
;		keyword is not specified, the title is set to "XInterAnimate2"
;		This keyword has an effect only when used in conjunction with
;		the SET keyword).
;
;	TRACK: If set, the frame slider tracks the current frame.  Default
;		is not to track.  Provide this keyword with the SET keyword.
;
;	WINDOW:	When this keyword is specified, an image is copied from an
;		existing window to the animation pixmap.  When using X
;		windows, this technique is much faster than reading
;		from the display and then calling XINTERANIMATE2 with a 2D
;		array.
;
;		The value of this parameter is either an IDL window
;		number (in which case the entire window is copied),
;		or a vector containing the window index and the rectangular
;		bounds of the area to be copied, for example:
;		WINDOW = [Window_Number, X0, Y0, Sx, Sy]
;
;      XOFFSET:	The horizontal offset, in pixels from the left of the frame,
;		of the image in the destination window.
;
;      YOFFSET:	The vertical offset, in pixels from the bottom of the frame,
;		of the image in the destination window.
;
; OUTPUTS:
;	No explicit outputs.
;
; COMMON BLOCKS:
;	XINTERANIMATE2_COM: a private common block.
;
; SIDE EFFECTS:
;	A pixmap and widget are created.
;
; RESTRICTIONS:
;	Only a single copy of XINTERANIMATE2 can run at a time.
;
; PROCEDURE:
;	When initialized, this procedure creates an approximately square
;	pixmap or memory buffer, large enough to contain Nframes of
;	the requested size.  Once the images are loaded, using the
;	IMAGE and FRAME keywords, they are displayed by copying the images
;	from the pixmap or buffer to the visible draw widget.
;
; EXAMPLE:
;	Enter the following commands to open the file ABNORM.DAT (a series
;	of images of a human heart) and animate the images it contains using
;	XINTERANIMATE2.  For a more detailed example of using XINTERANIMATE2,
;	see the example in the "Using IDL Widgets" chapter of "IDL Basics".
;	Read the images into the variable H by entering:
;
;		OPENR, 1, FILEPATH('abnorm.dat', SUBDIR = 'examples/data')
;		H = BYTARR(64, 64, 16)
;		READU, 1, H
;		CLOSE, 1
;		H = REBIN(H, 128, 128, 16)
;
;	Initialize XINTERANIMATE2 with the command:
;
;		XINTERANIMATE2, SET=[128, 128, 16], /SHOWLOAD
;
;	Load the images into XINTERANIMATE2 and play the animation by entering:
;
;		FOR I=0,15 DO XINTERANIMATE2, FRAME = I, IMAGE = H[*,*,I]
;		XINTERANIMATE2
;
; MODIFICATION HISTORY:
;	DMS, April, 1990.
;	SMR, December, 1990.  	Modified the XANIMATE code to work
;				interactively with widgets.
;
;	DMS, March, 1991.	Modified the routine to use individual pixmaps
;				for each frame of the animation.  Also added
;				the ability to read in from current IDL
;				windows directly into offscreen bitmap.
;
;	SMR, March, 1991.	Modified to use new XMANAGER keyword CLEANUP
;				to clean up the offscreen pixmaps when dying.
;
;	SMR, Jan, 1992.		Modified the /CLOSE portion to check for a
;				valid widget before using WIDGET_CONTROL
;				and /DESTROY.
;
;	AB, June 1992		Rewrite using the new CW_ANIMATE compound
;				widget. Added the KEEP_PIXMAPS keyword.
;
;	DJE, April, 1996	Replaced XANNOUNCE with DIALOG_MESSAGE
;
;       SJL, December, 1997     Added MPEG capability.
;
;LP, 6/16/98             Added MODAL keyword.
;  Kim Tolbert, 4-Feb-2005.  Replaced xinteranimate2 with the newer version of xinteranimate
;    (main diff is addition of mpeg stuff), but kept the change to xkill.  This version
;    calls cw_animate2 instead of cw_animate.  cw_animate2 has a catch in it, so that
;    when the it crashes (usually by running out of memory for pixmaps) it cleans up
;    after itself before returning, instead of leaving a gazillion pixmaps.
;  Kim Tolbert, 16-Nov-2005.  Call xintanim_kill_pix from the catch block.
;-

PRO xintanim_kill_pix
; If there are pixmaps currently open, free them.

  COMPILE_OPT hidden
  COMMON XInterAnimate2_com, topbase, animatebase, pwin, mpegID

  i = size(pwin)
  if (i[0] ne 0) then begin		; Not scalar, so contains valid IDs
    i = i[i[0] + 2]			; # of elements in pwin
    FOR j=0, i-1 DO IF pwin[j] GE 0 THEN WDELETE, pwin[j] ;Delete the windows
  pwin = -1		;Show nothing there by setting to scalar value
  endif

end








PRO xintanim_event, ev
; The only event that can be seen by this application is the "DONE"
; event from the CW_ANIMATION cluster.

  COMPILE_OPT hidden

  xkill,ev.top
END







PRO XInterAnimate2, RATE, SET = SET, IMAGE = IMAGE, FRAME = FRAME, $
	ORDER = ORDER, CLOSE = CLOSE, TITLE = TITLE, $
	SHOWLOAD = SHOWLOAD, GROUP = GROUP, WINDOW = WINDOW, $
	XOFFSET = XOFFSET, YOFFSET = YOFFSET, KEEP_PIXMAPS=KEEP_PIXMAPS, $
	CYCLE = cycle, TRACK = track, MPEG_OPEN = mpegOpen, $
	MPEG_CLOSE = mpegClose, MPEG_FILENAME = mpegFilename, $
	MPEG_QUALITY = mpegQuality, MPEG_BITRATE = mpegBitrate, $
	MPEG_IFRAME_GAP = mpegIFrameGap, $
	MPEG_MOTION_VEC_LENGTH = mpegMotionVecLength, $
	BLOCK=block, MODAL = modal, ABORT=abort

COMMON XInterAnimate2_com, topbase, animatebase, pwin, mpegID

;ON_ERROR, 2

abort = 0

catch,err
if err ne 0 then begin
	catch,/cancel
	message,/cont,!error_state.msg
	message,/cont,'Aborting.'
	if (OBJ_VALID(mpegID)) then MPEG_CLOSE, mpegID
	xkill, topbase
	xintanim_kill_pix
	abort = 1
	return
endif

IF N_ELEMENTS(block) EQ 0 THEN block=0

;--------------------- MPEG Write Portion of Xinteranimate2 --------------------

    if (KEYWORD_SET(mpegClose)) then begin
        ; let user know about demo mode limitation.
        ; mpeg object is disabled in demo mode
        if (LMGR(/DEMO)) then begin
            MESSAGE, 'MPEG_CLOSE: Feature disabled for demo mode.'
            return
        endif

        if (OBJ_VALID(mpegID)) then $
          MPEG_SAVE, mpegID
    endif

    if (KEYWORD_SET(mpegOpen)) then begin
        ; let user know about demo mode limitation.
        ; mpeg object is disabled in demo mode
        if (LMGR(/DEMO)) then begin
            MESSAGE, 'MPEG_OPEN: Feature disabled for demo mode.'
            return
        endif

        ;; the object will default these kw parms if passed as undefined
        mpegID = OBJ_NEW('IDLgrMPEG', FILENAME = mpegFilename, $
        	QUALITY = mpegQuality, BITRATE = mpegBitrate, $
			IFRAME_GAP = mpegIFrameGap, $
			MOTION_VEC_LENGTH = mpegMotionVecLength)
    endif

;--------------------- CLOSE Portion of Xinteranimate2 -------------------------

  IF KEYWORD_SET(CLOSE) THEN BEGIN
      ;; Get rid of the MPEG object if it exists
      if (OBJ_VALID(mpegID)) then $
        MPEG_CLOSE, mpegID
    xkill,topbase
    xintanim_kill_pix
    RETURN
  ENDIF

  ;Don't allow two copies of xinternimate to run at once
  IF xregistered("XInterAnimate2") THEN begin
    tmp = dialog_message( /error, [ 'Error in XINTERANIMATE2:', ' ', $
    			  'Only one animation at a time is allowed.' ])
    abort = 1
    return
  endif



;----------------------  SET Portion of Xinteranimate2 ------------------------

  IF KEYWORD_SET(SET) THEN BEGIN

    ;This is the first call to xinteranimate2.  Here the pixmap is
    ;	created and the widgets are initialized.

    xintanim_kill_pix				;If old pixmap exists, delete

    IF NOT(KEYWORD_SET(TITLE)) THEN TITLE = "XInterAnimate2"

    if KEYWORD_SET(MODAL) AND N_ELEMENTS(GROUP) GT 0 then begin
        topbase = WIDGET_BASE(TITLE = TITLE, $
                              GROUP_LEADER = GROUP, /MODAL)
    endif else begin
        topbase = WIDGET_BASE(TITLE = TITLE)
    endelse

    ; Setting the managed attribute indicates our intention to put this app
    ; under the control of XMANAGER, and prevents our draw widgets from
    ; becoming candidates for becoming the default window on WSET, -1. XMANAGER
    ; sets this, but doing it here prevents our own WSETs at startup from
    ; having that problem. Don't do this if SHOWLOAD is to be used because
    ; we want it to grab the window then.
    IF not KEYWORD_SET(SHOWLOAD) THEN WIDGET_CONTROL, /MANAGED, topbase

    animatebase = CW_ANIMATE2(topbase, set[0], set[1], set[2], $
		TRACK = KEYWORD_SET(track), CYCLE=KEYWORD_SET(cycle))

    ; If the SHOWLOAD keyword is set, realize things now so the load is seen
    IF KEYWORD_SET(SHOWLOAD) THEN $
      WIDGET_CONTROL, topbase, /REALIZE, /HOURGLASS

    RETURN
  ENDIF

;-----------------  IMAGE Loading Portion of Xinteranimate2 --------------------

  nwindow = N_ELEMENTS(WINDOW)
  nimage = N_ELEMENTS(image)
  if (nwindow gt 0) or (nimage gt 0) then begin
    old_window = !D.WINDOW				;Save old window

    ; Make sure a widget has been created before trying to load it.
    if (not widget_info(topbase, /valid)) then MESSAGE, 'Not initialized'

    IF (N_ELEMENTS(YOFFSET) EQ 0) THEN YOFFSET = 0
    IF (N_ELEMENTS(XOFFSET) EQ 0) THEN XOFFSET = 0

    if (N_ELEMENTS(WINDOW) gt 0) then begin
      CW_ANIMATE2_LOAD, animatebase, frame=frame, window=window, $
		XOFFSET = XOFFSET, YOFFSET = YOFFSET
      ;; Write to MPEG if needed
      if (OBJ_VALID(mpegID)) then $
        MPEG_PUT, mpegID, FRAME=frame, WINDOW=window
    endif else begin
      IF (N_ELEMENTS(ORDER) EQ 0) THEN ORDER = 0
      CW_ANIMATE2_LOAD, animatebase, frame=frame, image=image, $
		XOFFSET = XOFFSET, YOFFSET = YOFFSET, ORDER = ORDER
      ;; Write to MPEG if needed
      if (OBJ_VALID(mpegID)) then $
        MPEG_PUT, mpegID, FRAME=frame, IMAGE=image, ORDER=order
    endelse
    IF (old_window GE 0) THEN WSET, old_window
    RETURN
  ENDIF

;---------------  Register and Run Portion of Xinteranimate2 -------------------

  ; If the base is not valid, it means that we have skipped
  ; calling this routine with the SET keyword. In this case, we can restart
  ; the last animation if the KEEP_PIXMAP keyword was used to preserve them
  ; in the previous call.

  if (not widget_info(topbase, /valid)) then begin
    s = size(pwin)
    if (s[0] eq 0) then message, 'No image frames loaded'
    ; Scan the pixmaps to figure out the image size
    n = s[s[0] + 2]
    xs = 0
    for i = 0, n-1 do begin
      if pwin[i] ne -1 then begin
        old_window = !D.WINDOW
	wset, pwin[i]
        xs = !d.x_vsize
        ys = !d.y_vsize
	IF (old_window GE 0) THEN WSET, old_window
        goto, found		; Like a "break" in C
      endif
    endfor
  found:
    if (xs ne 0) then begin
      IF NOT(KEYWORD_SET(TITLE)) THEN TITLE = 'XInterAnimate2'
      topbase = WIDGET_BASE(TITLE = TITLE)
      animatebase = CW_ANIMATE2(topbase, xs, ys, n, PIXMAPS=pwin)
      ; The pixmaps are no longer our responsibility. They will get destroyed
      ; by CW_ANIMATE2 as usual unless this invocation of XINTERANIMATE2
      ; specifies the KEEP_PIXMAP keyword.
      pwin = 0			; Indicate that we aren't saving them anymore.
    endif else message, 'No image frames loaded'
  endif


  ; At this point, the application must be realized if it isn't already
  if (not widget_info(topbase, /realized)) then $
    WIDGET_CONTROL, topbase, /REALIZE

  ; Save the pixmaps for later restart
  if keyword_set(keep_pixmaps) then CW_ANIMATE2_GETP, animatebase, pwin

  if N_ELEMENTS(RATE) EQ 0 THEN RATE = 100
  cw_animate2_run, animatebase, rate

  Xmanager, "XInterAnimate2", topbase, EVENT_HANDLER = "xintanim_event", $
	  GROUP_LEADER = GROUP, NO_BLOCK=(NOT(FLOAT(block)))
END
