;+
; NAME:
;     DIALOG_LIST
;
; PURPOSE:
;     A modal (blocking) dialog widget to display a selectable list.
;     The dialog must be dismissed by selecting a menu item before
;     execution of the calling program can continue.
;
; TYPE:
;     FUNCTION
;
; CATEGORY:
;     WIDGETS
;
; CALLING SEQUENCE:
;     result = DIALOG_LIST (list_items)
;
; INPUTS:
;     list_items: STRARR of list items
;
; KEYWORD PARAMETERS:
;
;     TITLE: The list title
;
;     MULTIPLE: Allow multiple list selections
;
;     XSIZE: Width of the widget in PIXELS 
;     YSIZE: Height of the list widget in LINES 
;
;     DIALOG_PARENT: Set this keyword to the widget ID of a widget over
;            which the message dialog should be positioned. When displayed,
;            the DIALOG_MENU dialog will be positioned over the specified
;            widget. Dialogs are often related to a non-dialog widget tree.
;            The ID of the widget in that tree to which the dialog is most
;            closely related should be specified.
;          
;            If this keyword is not specified, the default placement of the
;            menu is the center of the screen (window manager dependent).
;
;     EMBED_PARENT: Optional, if used dialog appears inside given
;     Base, or can also be set to -1 to supress this behavior.
;
;     INDEX: Optionally return the index of the selected item(s) instead of
;            the item text.  The index of the first list_item is zero.
;
;     INITIAL: Option, index of item to mark as 'default', otherwise
;              uses first item
;
;
; OUTPUTS:
;     result: STRARR of selected list items, or INTARR if INDEX keyword
;         is used, starting at index = 0.  If no selections are made, 
;         returns '' (or -1 if INDEX keyword is set)
;
; COMMON BLOCKS:
;     NONE
;
; SIDE EFFECTS:
;     Creates a modal widget
;
; RESTRICTIONS:
;     NONE
;
; DEPENDENCIES:
;     NONE
;
; EXAMPLES:
;     result = DIALOG_LIST(['Item 1', 'Item 2', 'Item 3'], $
;         TITLE = 'Select Items', /MULTIPLE)
;
; MODIFICATION HISTORY:
;     v0.13:  Sandy Antunes, Jan 2006
;             Added default choice in list
;
;     v0.12:  RSM, September 1998:
;             Allow multi-line titles.
;
;     v0.11:  RSM, August 1998: 
;             Added 'Cancel' button. 
;
;     v0.10:  Written, Robert.Mallozzi@msfc.nasa.gov, May 1998.
;
;-
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

FUNCTION DIALOG_LIST, list, $
    TITLE = title, $
    XSIZE = xsize, YSIZE = ysize, $
    DIALOG_PARENT = dialog_parent, $
    EMBED_PARENT = embed_parent, $
    MULTIPLE = multiple, INDEX = index, INITIAL = initial


    xsize = N_ELEMENTS (xsize) EQ 0 ? 0  : xsize
    ysize = N_ELEMENTS (ysize) EQ 0 ? N_ELEMENTS (list) : ysize

    have_title    = N_ELEMENTS (title) NE 0
    have_parent   = N_ELEMENTS (dialog_parent) NE 0
    have_index    = N_ELEMENTS (index) NE 0
    have_multiple = N_ELEMENTS (multiple) NE 0
    if (n_elements(initial) eq 0) then initial=0
    if (n_elements(embed_parent) eq 0) then embed_parent = -1

    ; Top level base
    ;
    IF (have_parent) THEN BEGIN

       ; Check for a valid widget id
       ;
       have_parent = WIDGET_INFO (LONG (dialog_parent), /VALID_ID)

    ENDIF   

    IF (have_parent) THEN BEGIN

       listBase = WIDGET_BASE (TITLE = ' ', /COLUMN, XSIZE = xsize, $
              /FLOATING, /MODAL, GROUP_LEADER = dialog_parent)

    END ELSE IF (embed_parent ne -1) THEN BEGIN
       listBase = WIDGET_BASE (embed_parent, TITLE = ' ', /COLUMN, $
                               XSIZE = xsize)

    END ELSE BEGIN

       listBase = WIDGET_BASE (TITLE = ' ', /COLUMN, XSIZE = xsize, MAP = 0)   

    ENDELSE

    IF (have_title) THEN BEGIN
       FOR i = 0, N_ELEMENTS (title) - 1 DO $
           w = WIDGET_LABEL (listBase, VALUE = title[i]) 
    ENDIF
    
    listID = WIDGET_LIST (listBase, VALUE = list, $
        MULTIPLE = have_multiple, YSIZE = ysize)

    w = WIDGET_BUTTON (listBase, VALUE = 'Accept')
    w = WIDGET_BUTTON (listBase, VALUE = 'Cancel')


    ; Map widget
    ;
    WIDGET_CONTROL, listBase, /REALIZE

    ; Set default item
    WIDGET_CONTROL, listID, set_list_select=initial

    ; Place the dialog: window manager dependent
    ;
    IF (NOT have_parent) THEN BEGIN

       thisScreen = GET_SCREEN_SIZE()
       WIDGET_CONTROL, listBase, TLB_GET_SIZE = dialogSize

       dialogPt = [(thisScreen[0] / 2.0) - (dialogSize[0] / 2.0), $ 
                    (thisScreen[1] / 2.0) - (dialogSize[1] / 2.0)] 

       WIDGET_CONTROL, listBase, $
                       TLB_SET_XOFFSET = dialogPt[0], $
                       TLB_SET_YOFFSET = dialogPt[1]
       WIDGET_CONTROL, listBase, MAP = 1

    ENDIF

    ; Get the event, without using XMANAGER
    ;
    REPEAT BEGIN

        event = WIDGET_EVENT (listBase)
        type = TAG_NAMES (event, /STRUCTURE)

    ENDREP UNTIL (type NE 'WIDGET_LIST') 

    WIDGET_CONTROL, event.id, GET_VALUE = value
    IF (value[0] EQ 'Cancel') THEN BEGIN
       WIDGET_CONTROL, listBase, /DESTROY
       RETURN, ''
    ENDIF
    
    ; Process the event
    ;
    listIndex = WIDGET_INFO (listID, /LIST_SELECT)
    
    WIDGET_CONTROL, listBase, /DESTROY

    IF (have_index) THEN BEGIN
       RETURN, listIndex
    ENDIF ELSE BEGIN
       IF (TOTAL (listIndex) EQ -1) THEN BEGIN
          RETURN, ''
       ENDIF ELSE BEGIN
          RETURN, list[listIndex]
       ENDELSE
    ENDELSE


END
