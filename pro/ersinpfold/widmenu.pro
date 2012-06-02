; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;+
; NAME:
;	WIDMENU
;
; PURPOSE:
;	Widget version of WMENU, plus optional SCROLL bar
;
; CATEGORY:
;	WIDGETS
;
; CALLING SEQUENCE:
;	RESULT = WIDMENU(SELECTIONS [, keywords])
;
; INPUTS:
;       SELECTIONS: STRARR of the menu selections
;
; KEYWORD PARAMETERS:
;       TITLE         : The title
;       INITIAL       : The inital cursor selection
;       SCROLL        : Adds a scroll bar
;       WIDTH         : Width of the widget in pixels (height is set 
;                       automatically based on the number of buttons)
;       UL            : Place the menu in the upper left corner
;       LL            : Place the menu in the lower left corner
;       UR            : Place the menu in the upper right corner
;       LR            : Place the menu in the lower right corner
;       X_SCROLL_SIZE : Size of x scroll region (pixels), if /SCROLL is set
;       Y_SCROLL_SIZE : Size of y scroll region (pixels), if /SCROLL is set
;
; OUTPUTS:
;       RESULT = index of the menu item (including TITLE, if supplied)
;
; COMMON BLOCKS:
;	NONE
;
; SIDE EFFECTS:
;       Creates a widget on the current device
;
; RESTRICTIONS:
;	TITLE can only be a single line on the widget
;
; DEPENDENCIES:
;       NONE
;
; PROCEDURE:
;       Function call; mimics WMENU 
;
; EXAMPLES:
;       Error notification message:
;       INDEX = WIDMENU(['ERROR Opening File to Read', 'OK'], $
;                         title = 0, initial = 1)
;
;       QUIT confirmation:
;       INDEX = WIDMENU(['Do you really want to QUIT?', 'Yes', 'No'], $
;                         title = 0, initial = 1)
;
; MODIFICATION HISTORY:
;	Written, <mallozzi@gibson.msfc.nasa.gov>, Dec 1994.
;       RSM, July 1995, placed menu in center of screen (thanks M. Bell)
;       RSM, July 1995, added check to see if IDL widgets are supported; if
;            not, WMENU is used 
;       RSM, Nov 1995, fixed initial cursor placement
;       RSM, Mar 1996, added UL, LL, UR, LR keywords
;       RSM, Aug 1996, added X_SCROLL_SIZE, Y_SCROLL_SIZE keywords
;-
FUNCTION WIDMENU, SELECTIONS, TITLE = TITLE, SCROLL = SCROLL, $
                  INITIAL = INITIAL, WIDTH = WIDTH, $
                  UL = UL, LL = LL, UR = UR, LR = LR, POSITION = POSITION, $
                  X_SCROLL_SIZE = X_SCROLL_SIZE, $
                  Y_SCROLL_SIZE = Y_SCROLL_SIZE


NUM_BUTTONS  = N_ELEMENTS(SELECTIONS)

HAVE_TITLE         = N_ELEMENTS(TITLE) NE 0
HAVE_INITIAL       = N_ELEMENTS(INITIAL) NE 0
HAVE_WIDTH         = N_ELEMENTS(WIDTH) NE 0
HAVE_SCROLL        = N_ELEMENTS(SCROLL) NE 0
HAVE_X_SCROLL_SIZE = N_ELEMENTS(X_SCROLL_SIZE) NE 0
HAVE_Y_SCROLL_SIZE = N_ELEMENTS(Y_SCROLL_SIZE) NE 0


IF (HAVE_TITLE) THEN BEGIN
   IF (TITLE GT NUM_BUTTONS - 1) THEN TITLE = NUM_BUTTONS - 1
   THE_TITLE = SELECTIONS(TITLE)
   LOCAL_SELECTIONS = SELECTIONS(WHERE(INDGEN(NUM_BUTTONS) NE TITLE))
ENDIF ELSE BEGIN
   THE_TITLE = ''
   LOCAL_SELECTIONS = SELECTIONS
ENDELSE

; Widgets available?
IF ((!D.FLAGS AND 65536) NE 0) THEN HAVE_WIDGETS = 1 ELSE HAVE_WIDGETS = 0

IF (HAVE_WIDGETS) THEN BEGIN

   ; Parent
   IF (HAVE_WIDTH) THEN BEGIN
      MENU_BASE = WIDGET_BASE(TITLE = ' ', /COLUMN, XSIZE = WIDTH, MAP = 0)
   ENDIF ELSE BEGIN
      MENU_BASE = WIDGET_BASE(TITLE = ' ', /COLUMN, MAP = 0)
   ENDELSE

   ; Add the title, if it's supplied
   IF (HAVE_TITLE) THEN BEGIN
      T_BASE = WIDGET_LABEL(MENU_BASE, VALUE = THE_TITLE)
   ENDIF

   ; Selection buttons
   IF (HAVE_SCROLL) THEN BEGIN
      IF (HAVE_X_SCROLL_SIZE) AND (HAVE_Y_SCROLL_SIZE) THEN BEGIN
         B_BASE = WIDGET_BASE(MENU_BASE, /COLUMN, /FRAME, /SCROLL, $
                  X_SCROLL_SIZE = X_SCROLL_SIZE, $
                  Y_SCROLL_SIZE = Y_SCROLL_SIZE)
      ENDIF
      IF (NOT HAVE_X_SCROLL_SIZE) AND (HAVE_Y_SCROLL_SIZE) THEN BEGIN
         B_BASE = WIDGET_BASE(MENU_BASE, /COLUMN, /FRAME, /SCROLL, $
                  Y_SCROLL_SIZE = Y_SCROLL_SIZE)
      ENDIF
      IF (HAVE_X_SCROLL_SIZE) AND (NOT HAVE_Y_SCROLL_SIZE) THEN BEGIN
         B_BASE = WIDGET_BASE(MENU_BASE, /COLUMN, /FRAME, /SCROLL, $
                  X_SCROLL_SIZE = X_SCROLL_SIZE)
      ENDIF
      IF (NOT HAVE_X_SCROLL_SIZE) AND (NOT HAVE_Y_SCROLL_SIZE) THEN BEGIN
         B_BASE = WIDGET_BASE(MENU_BASE, /COLUMN, /FRAME, /SCROLL)
      ENDIF
   ENDIF ELSE BEGIN
      B_BASE = WIDGET_BASE(MENU_BASE, /COLUMN, /FRAME)
   ENDELSE

   M_BUT = LONARR(NUM_BUTTONS)
   FOR I=0, N_ELEMENTS(LOCAL_SELECTIONS)-1 DO BEGIN
       M_BUT(I) = WIDGET_BUTTON(B_BASE, VALUE = LOCAL_SELECTIONS(I), UVALUE = I)
   ENDFOR

   ; Make it so
   WIDGET_CONTROL, MENU_BASE, /REALIZE 


   ; Place the menu
   DEVICE, GET_SCREEN_SIZE = CURRENT_SCREEN
   WIDGET_CONTROL, MENU_BASE, TLB_GET_SIZE = MENU_SIZE

   IF (N_ELEMENTS(POSITION) NE 0) THEN BEGIN
      MENU_PT = position * current_screen 
   ENDIF ELSE $
   IF (N_ELEMENTS(UL) NE 0) THEN BEGIN
      MENU_PT = [0, 0] 
   ENDIF ELSE $
   IF (N_ELEMENTS(LL) NE 0) THEN BEGIN
      MENU_PT = [0, CURRENT_SCREEN(1) - MENU_SIZE(1)] 
   ENDIF ELSE $
   IF (N_ELEMENTS(UR) NE 0) THEN BEGIN
      MENU_PT = [CURRENT_SCREEN(0) - MENU_SIZE(0), 0] 
   ENDIF ELSE $
   IF (N_ELEMENTS(LR) NE 0) THEN BEGIN
      MENU_PT = [CURRENT_SCREEN(0) - MENU_SIZE(0), $ 
                 CURRENT_SCREEN(1) - MENU_SIZE(1)] 
   ENDIF ELSE BEGIN
      MENU_PT = [(CURRENT_SCREEN(0) / 2.0) - (MENU_SIZE(0) / 2.0), $ 
                 (CURRENT_SCREEN(1) / 2.0) - (MENU_SIZE(1) / 2.0)] 
   ENDELSE

   WIDGET_CONTROL, MENU_BASE, $
                   TLB_SET_XOFFSET = MENU_PT(0), $
                   TLB_SET_YOFFSET = MENU_PT(1)
   WIDGET_CONTROL, MENU_BASE, MAP = 1
 
   ; Place the cursor (4 cases)
   CASE 1 OF
        HAVE_TITLE AND HAVE_INITIAL: BEGIN
             ; Is INITIAL valid?
             INDEX = WHERE(INDGEN(NUM_BUTTONS) NE TITLE)
             BUTTON_INDEX = WHERE(INDEX EQ INITIAL, INITIAL_VALID)
             IF (INITIAL_VALID) THEN BEGIN
                IF (TITLE LT INITIAL) THEN BEGIN
                   CURSOR_POSITION = INITIAL - 1
                ENDIF ELSE BEGIN
                   CURSOR_POSITION = INITIAL
                ENDELSE
             ENDIF ELSE BEGIN
                ; INITIAL not valid, just use the first available button
                CURSOR_POSITION = 0
             ENDELSE
             END

        NOT(HAVE_TITLE) AND HAVE_INITIAL: BEGIN
             ; Is INITIAL valid?
             INDEX = INDGEN(NUM_BUTTONS)
             BUTTON_INDEX = WHERE(INDEX EQ INITIAL, INITIAL_VALID)
             IF (INITIAL_VALID) THEN BEGIN
                CURSOR_POSITION = INITIAL
             ENDIF ELSE BEGIN
                ; INITIAL not valid, just use the first available button
                CURSOR_POSITION = 0
             ENDELSE
             END

        HAVE_TITLE AND NOT(HAVE_INITIAL): BEGIN
             ; Just use the first available button
             CURSOR_POSITION = 0
             END

        ELSE: BEGIN
             ; Just use the first available button
             CURSOR_POSITION = 0
             END
   ENDCASE

   WIDGET_CONTROL, M_BUT(CURSOR_POSITION), /INPUT_FOCUS

   ; Get the event, without using XMANAGER
   EVENT = WIDGET_EVENT(MENU_BASE)

   ; Process the event
   TYPE = TAG_NAMES(EVENT, /STRUCTURE)
   CASE TYPE OF

    ; The button widget events
    'WIDGET_BUTTON': BEGIN
            WIDGET_CONTROL, EVENT.ID, GET_VALUE = VALUE, $
                            GET_UVALUE = UVALUE
                   
            FOR I=0, N_ELEMENTS(LOCAL_SELECTIONS)-1 DO BEGIN
                IF (UVALUE EQ I) THEN BEGIN
                   WIDGET_CONTROL, EVENT.TOP, /DESTROY
                   IF (HAVE_TITLE) THEN BEGIN
                      IF (I GE TITLE) THEN BEGIN
                         ADD_I = HAVE_TITLE 
                      ENDIF ELSE ADD_I = 0
                   ENDIF ELSE ADD_I = 0

                   RETURN, I + ADD_I
                ENDIF
            ENDFOR
            END ; WIDGET_BUTTON events

   ENDCASE ; for TYPE

ENDIF ELSE BEGIN ; HAVE_WIDGETS = 0

   ; Place the cursor (4 cases)
   CASE 1 OF
        HAVE_TITLE AND HAVE_INITIAL: BEGIN
             ; Is INITIAL valid?
             INDEX = WHERE(INDGEN(NUM_BUTTONS) NE TITLE)
             BUTTON_INDEX = WHERE(INDEX EQ INITIAL, INITIAL_VALID)
             IF (INITIAL_VALID) THEN BEGIN
                   CURSOR_POSITION = INITIAL
             ENDIF ELSE BEGIN
                ; INITIAL not valid, just use the first available button
                CURSOR_POSITION = 0
             ENDELSE
             END

        NOT(HAVE_TITLE) AND HAVE_INITIAL: BEGIN
             ; Is INITIAL valid?
             INDEX = WHERE(INDGEN(NUM_BUTTONS) NE TITLE)
             BUTTON_INDEX = WHERE(INDEX EQ INITIAL, INITIAL_VALID)
             IF (INITIAL_VALID) THEN BEGIN
                IF (TITLE LT INITIAL) THEN BEGIN
                   CURSOR_POSITION = INITIAL - 1
                ENDIF ELSE BEGIN
                   CURSOR_POSITION = INITIAL
                ENDELSE
             ENDIF ELSE BEGIN
                ; INITIAL not valid, just use the first available button
                CURSOR_POSITION = 0
             ENDELSE
             END

        HAVE_TITLE AND NOT(HAVE_INITIAL): BEGIN
             ; Just use the first available button
             CURSOR_POSITION = 0
             END

        ELSE: BEGIN
             ; Just use the first available button
             CURSOR_POSITION = 0
             END
   ENDCASE

   IF (HAVE_TITLE) THEN BEGIN
      I = WMENU(SELECTIONS, TITLE = TITLE, INITIAL = CURSOR_POSITION)
   ENDIF ELSE BEGIN
      I = WMENU(SELECTIONS, INITIAL = CURSOR_POSITION)
   ENDELSE

   RETURN, I

ENDELSE ; HAVE_WIDGETS



END 
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
