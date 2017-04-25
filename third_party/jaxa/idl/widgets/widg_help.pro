;+
; Project     : SOHO - CDS
;
; Name        : WIDG_HELP
;
; Purpose     : Widget to select help topics.
;
; Explanation : Create a widget that lists and displays the help topic from
;               which the user may select.
;
;               This program searches for a file with this name first in the
;               current directory, and then in !PATH, and searches for the
;               name by itself, and with '.hlp' appended after it.
;
;               The file consists of a series of topic headers followed by a
;               text message about that topic.  The topic headers are
;               differentiated by starting with the "!" character in the first
;               column, e.g.
;               
;                    !Overview
;                    This is the overview for the
;                    topic at hand.
;               
;                    !Button1
;                    This is the help explanation
;                    for button 1
;               
;                    etc.
;               
;               The program assumes that the first line in the file contains
;               the first topic.  Also, there must be at least one line
;               between any two *different* topics.  Thus,
;               
;                    !Button2
;                    !Button3
;                    This is the help text for buttons 2 and 3
;               
;               means that the topics "Button2" and "Button3" are really the
;               same, and both correspond to the text following !Button3. It's
;               possible to have any number of topics in a row that leads to
;               the same help text. On the other hand:
;               
;                    !Button2
;                    
;                    !Button3
;               
;               means that the two topics have different help texts. The last
;               topic in the file must have at least one non-topic line after
;               it.
;
;               When the HIERARCHY keyword is set, multiple separation
;               characters (!) indicate the level of a help topic.
;               Initially, only first-level help topics are displayed in
;               the list of topics. When a topic is selected,
;               the corresponding next level topics are displayed.
;
;               The SUBTOPIC keyword can be supplied to specify what topic
;               should be looked up.
;
;               It is possible to have keywords that are only accessible
;               through the keyword SUBTOPIC, e.g.:
;
;               !!!!!!!!!!!!!!!!XYZZYZYAA ; The user wouldn't want to see this
;               !!!!!!!!!!!!!!!!XYZZYZYBB ; Nor would he want to see this.
;               !SPECIAL TOPICS           ; But this is OK.
;
;               Specifying subtopic='XYZZYZYAA' would drop the user off
;               looking at 'SPECIAL TOPICS'.
;
; Use         : WIDG_HELP, FILENAME
;
; Inputs      : FILENAME = The name of a file that contains the help
;                          information to display.  
;
; Opt. Inputs : None.
;
; Outputs     : None.
;
; Opt. Outputs: None.
;
; Keywords    : GROUP_LEADER = The widget ID of a calling widget. Destroying
;                              that widget will kill this widget.
;
;               TITLE        = The text to be displayed on the widget title
;                              bar.  If not passed, then "Widget Help" is used.
;               FONT         = Font name for the help text widget. If
;                              not passed, the text font is determined
;                              by GET_DFONT
;               TFONT        = Font name for the topic list widget. If
;                              not passed, the topic list font is determined
;                              by GET_DFONT
;               SEP_CHAR     = Character used to differentiate topic
;                              headers. The default SEP_CHAR is '!'
;               MODAL        = Block event processing in calling widget.
;               NO_BLOCK     = Allow control back to the command line.
;               SUBTOPIC     = The initial topic selection to be displayed
;                              as the widget pops up.
;               XTEXTSIZE    = Size of the text widget.  Default is 60.
;               XTOPICSIZE   = X size of the topic list.
;               HIERARCHY    = If set, then multiple SEP_CHARs indicate the
;                              level of the section.  The levels are indented
;                              uniformly and only the sublevels within the
;                              current top-level topic are displayed in the 
;                              list.
;
; Calls       : FIND_WITH_DEF, DATATYPE, GET_DFONT, RD_ASCII, UNIQ, REVERSE
;
; Common      : WIDG_HELP_COMMON. Used to enable picking new subtopics
;                                 or killing the previous copy of widg_help.
;
; Restrictions: None.
;
; Side effects: None.
;
; Category    : Utilities, Widget
;
; Prev. Hist. : Based on PLANHELP by Elaine Einfalt, GSFC (HSTX), April 1994
;
; Written     : William Thompson, GSFC, 2 September 1994
;
; Modified    : Version 1, William Thompson, GSFC, 2 September 1994
;                          P. Brekke, GSFC, 21 September 1994
;                                     Text widget width = 60  (was 50)
;               Version 2, Liyun Wang, GSFC/ARC, April 3, 1995
;                          Added keywords FONT and SEP_CHAR
;                          Allowed commentary lines (starting with a ';'
;                             in the first column) in help text file
;               Version 3, Liyun Wang, GSFC/ARC, May 17, 1995
;                          Added keyword MODAL
;               Version 4, S.V.H. Haugan, 18-May-1995
;                          Added keyword SUBTOPIC (second time around)
;               Version 5, Liyun Wang, GSFC/ARC, June 22, 1995
;                          Added TFONT keyword
;               Version 6, Richard Schwartz, GSFC/SDAC, Aug. 28, 1995
;                          added, XTEXTSIZE, HIERARCHY, using RD_ASCII to
;                          read the help file.  Also, the SUBTOPIC
;                          is matched by finding the first matching string
;                          amongst the topics instead of requiring an exact
;                          match, where leading and trailing blanks have
;                          been discarded, and the search is case insensitive.
;                          Additionally, the selected topic remains highlighted
;                          while the text is displayed.
;               Version 7, Stein Vidar H. Haugan, UiO, 28 February 1996
;                          Two or more topic lines with no text lines inbetween
;                          causes both topics to have a common help text,
;                          i.e., the text following the last of the series
;                          of topics.
;                          If a copy of widg_help is running then it's either
;                          killed and a new one is started, or a new subtopic
;                          is displayed if we're looking at the same file.
;               Version 8, SVHH, UiO, 1 March 1996
;                          Only topics at one level below the current topic
;                          are displayed when using HIERARCHY. Moved the
;                          file format description to sect. "Explanation".
;                          Added XTOPICSIZE.
;               Version 9, SVHH, UiO, 4 March 1996
;                          Fixed problem with unrecognized subtopic causing
;                          crash.
;               Version 10, Zarro (EIT/GSFC), 22 August 2000
;                          Added check for undefined !debug
;               Version 11, William Thompson, GSFC, 14-Jan-2016
;                          Added NO_BLOCK keyword
;
;-
;


;==============================================================================
;			  The event handler routine.
;==============================================================================

	PRO WIDG_HELP_EVENT, EVENT
;
        ON_ERROR, 2
;
;  Get the event ID and the text window widget ID.
;
	WIDGET_CONTROL, EVENT.ID, GET_UVALUE=INPUT
	WIDGET_CONTROL, EVENT.TOP, GET_UVALUE=HELP
;
;  Process the widget event.  If the "Quit button was called, then exit this
;  procedure.
;

        IF !debug GT 0 THEN ON_ERROR,0
        
	CASE INPUT OF
		'CANCEL':  WIDGET_CONTROL, EVENT.TOP, /DESTROY
;
;  If one of the list items, then display the help information for the selected
;  topic.
;
                'LIST':  BEGIN
                   shown = WHERE(help.mask)
                   subtopic = STRTRIM((help.text(help.wtopic(shown)) $
                                      )(event.index),2)
                   widg_help_select,subtopic
                END
		ELSE : PRINT,'WIDG_HELP - Programmer error ' + INPUT
	ENDCASE
;
	RETURN
	END
        
        
;==============================================================================
;			The widget definition routine.
;==============================================================================
        
PRO widg_help_select,subtopic
  COMMON WIDG_HELP_COMMON,common_filename,BASE
  
  WIDGET_CONTROL,base,get_uvalue=help
  LEVEL = HELP.LEVEL
  MASK  = HELP.MASK
  WTOPIC = HELP.WTOPIC
  RANGE = INDGEN(N_ELEMENTS(MASK))
  
  TOPIC = help.text(WTOPIC)
  IX = WHERE(STRPOS(STRUPCASE(TOPIC), $
                    STRUPCASE(STRTRIM(SUBTOPIC(0),2))) NE -1,COUNT)
  
  IF count EQ 0 THEN i = 0 ELSE i = ix(0)

  WHILE help.startline(i) GT help.stopline(i) DO BEGIN
     i = i+1
     IF i EQ N_ELEMENTS(help.startline) THEN RETURN
  END
  
  WIDGET_CONTROL, HELP.TEXT_WIDG, SET_VALUE=	$
     HELP.TEXT(HELP.STARTLINE(I):HELP.STOPLINE(I))
  
  show = [-1]
  ON_ERROR,0
  
  leveli = level(i)
  FOR lev = 0,leveli+1 DO BEGIN
     lev_start = (reverse(WHERE(range LE i AND level lE lev)))(0)
     lev_end =   (WHERE(range GT i AND level lE lev))(0)
     ix = WHERE(level EQ lev)
     IF ix(0) NE -1 THEN show = [show,range(ix)]
     IF lev_end EQ -1 THEN lev_end = N_ELEMENTS(range)-1
     IF lev LE leveli THEN BEGIN
        range = range(lev_start:lev_end)
        level = level(lev_start:lev_end)
     END
  END
  
  topics_show = show((uniq(show,SORT(show)))(1:*)) ;; Take away -1
  
  WIDGET_CONTROL, HELP.LIST_WIDG, $
     SET_VALUE= HELP.TEXT(WTOPIC(TOPICS_SHOW))
  HELP.MASK = HELP.MASK * 0
  HELP.MASK(TOPICS_SHOW) = 1
  WIDGET_CONTROL, base, SET_UVALUE=HELP
  INEW = WHERE( WTOPIC(I) EQ WTOPIC(TOPICS_SHOW))
  WIDGET_CONTROL, HELP.LIST_WIDG, SET_LIST_SELECT=INEW(0)
END


PRO WIDG_HELP, FILENAME, GROUP_LEADER=GROUP, TITLE=TITLE, FONT=FONT,$
               SEP_CHAR=SEP_CHAR, MODAL=MODAL, SUBTOPIC=SUBTOPIC, $
               TFONT=TFONT, XTEXTSIZE=XTEXTSIZE, HIERARCHY=HIERARCHY,$
               XTOPICSIZE=XTOPICSIZE, NO_BLOCK=NO_BLOCK
        COMMON WIDG_HELP_COMMON,common_filename,base
;
;  Define the error status.
;
	ON_ERROR, 2

        defsysv,'!debug',exists=defined
        if not defined then defsysv,'!debug',0
;
;  If already running return immediately.
;  Or maybe not. Instead we'll either kill the existing one and start over,
;  or select a new subtopic if we're looking at the same file.
;
        IF XREGISTERED('widg_help') THEN BEGIN
           IF datatype(filename) NE 'STR' THEN return
           IF filename EQ common_filename THEN BEGIN
              IF KEYWORD_SET(subtopic) THEN widg_help_select,subtopic
              return
           END ELSE begin
              WIDGET_CONTROL,base,/destroy
           END
        END
        
;
;  Check the number of arguments.
;
	IF N_PARAMS() NE 1 THEN MESSAGE, 'Syntax:  WIDG_HELP, FILENAME'
;
;  Set font for text and topic list widgets
;
        IF datatype(font) NE 'STR' THEN font = (get_dfont(wfont))(0)
        IF datatype(tfont) NE 'STR' THEN tfont = (get_dfont(wfont))(0)
;
;  See if SEP_CHAR is passed
;
        IF datatype(sep_char) NE 'STR' THEN sep_char = '!'
        comment = ';'
;
;  See if XTEXTSIZE is passed
;
        IF datatype(xtextsize) EQ 'UND' THEN xtextsize = 60
        comment = ';'
;
;  Open the help file.
;
	FILE = FIND_WITH_DEF(FILENAME,!PATH,'.hlp')
	IF FILE EQ '' THEN MESSAGE, 'Unable to open file '+FILENAME
;
;  Read in the file
;
        text = rd_ascii( file(0) )
        common_filename = filename
	wtopic = where( strmid( text, 0, 1) eq sep_char, ntopics)
	if ntopics lt 1 then message,'No topic characters, '+sep_char+' ,found!'
	topic  = strmid( text(wtopic), 1, max(strlen(text(wtopic))) )
	startline = wtopic + 1
	stopline  = [wtopic(1:*)-1, n_elements(text)-1]
;
;  If the HIERARCHY keyword is set look for more SEP_CHAR at the start
;  of each topic line.  The hierarchical level is determined by their number.
;
	test = '                                                                     '
	if keyword_set( hierarchy ) then begin
	   level = intarr(ntopics)
	   for i=0,ntopics-1 do begin
		level(i) = (where( byte(topic(i)) ne (byte(sep_char))(0)))(0)
		topic(i) = strmid( test, 0, level(i)) + $ 
			strmid( topic(i), level(i), strlen(topic(i)))
	   endfor
	endif else level= intarr(ntopics)
        text(wtopic) = topic
        
        IF N_ELEMENTS(XTOPICSIZE) EQ 0 THEN  $
           XTOPICSIZE = MAX(STRLEN(topic))
        
        IF N_ELEMENTS(XTOPICSIZE) EQ 1 THEN $
           topic(0) = (topic(0) + $
                       STRMID(test,0,(FIX(XTOPICSIZE)-STRLEN(TOPIC(0))) > 0))
;
;  MASK keeps track of which TOPICs are displayed in the list
;
  	mask = intarr(ntopics)
;
;  Create the base widget.
;
	IF N_ELEMENTS(TITLE) EQ 1 THEN WIDGET_TITLE = TITLE ELSE	$
		WIDGET_TITLE = 'Widget Help'
	BASE = WIDGET_BASE(TITLE=WIDGET_TITLE, /ROW, SPACE=20)
;
;  Create the quit button and the list of help topics.
;
	LEFT = WIDGET_BASE(BASE, /COLUMN, SPACE=15)
	QUITIT = WIDGET_BUTTON(LEFT, VALUE='Quit', UVALUE='CANCEL')
        
        LIST = WIDGET_LIST(LEFT, YSIZE=25, VALUE=TOPIC,  UVALUE='LIST',$
                           font=tfont)
        
        
;
;  Create the topic output window.
;
        TEXT_WIDG = WIDGET_TEXT(BASE, /SCROLL, /FRAME, XSIZE=XTEXTSIZE, YSIZE=30, $
                                font=font)
;
;  Realize the widget, and pass it a structure containing all the relevant
;  information.
;
        ON_ERROR,0
	HELPPASS = {			$
		LIST_WIDG: LIST,	$
		TEXT_WIDG: TEXT_WIDG,	$
		WTOPIC: WTOPIC,		$
		MASK: MASK,		$
		LEVEL: LEVEL,		$
		TEXT: TEXT,		$
		STARTLINE: STARTLINE,	$
		STOPLINE: STOPLINE}
	WIDGET_CONTROL, BASE, /REALIZE
	WIDGET_CONTROL, BASE, SET_UVALUE=HELPPASS

;
;  If any subtopic is chosen, we select it and display it.
;

        IF N_ELEMENTS(SUBTOPIC) EQ 0 THEN SUBTOPIC=STRTRIM(topic(0),2)
	IF N_ELEMENTS(SUBTOPIC) GT 1 THEN SUBTOPIC=SUBTOPIC(0)
        IF DATATYPE(SUBTOPIC) NE 'STR' THEN SUBTOPIC=STRTRIM(topic(0),2)
        
	widg_help_select,subtopic

;
;  Start the widget.
;
        XMANAGER, 'widg_help', BASE, GROUP_LEADER=GROUP, $
           MODAL=KEYWORD_SET(MODAL), NO_BLOCK=NO_BLOCK
;
	RETURN
	END
