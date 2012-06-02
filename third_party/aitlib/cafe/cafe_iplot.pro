PRO  cafe_iplot, env,                               $
                 notransient=notransient,           $
                 help=help,shorthelp=shorthelp
;+
; NAME:
;           iplot
;
; PURPOSE:
;           interactively plots data/model of fit
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           iplot [,/notransient]
;
; OPTIONS:
;           notransient - do not restore setplot ranges. Useful when
;                         plotout is performed.
;
; DESCRIPTION:
;           iplot uses the plot command to display former defined
;           plot styles. All iplot does is to change the range(s)
;           via mouse and redisplay the range.
;
; BUTTONS:
;
;               ZOOM_IN  - narrow visible range. This will be done in
;                          steps as 10, 5, 2, 1, 0.5, 0.2, 0.1...
;               ZOOM_OUT - enlarge visible range This will be done in
;                          steps as 1, 2, 5, 10, 20, 50...
;               <<       - move left one page
;               >>       - move right one page
;               EXIT     - leave IPLOT
; 
; MOUSE:
;           Left button click will center the plot in x-range at
;               data at mouse position. 
;
; SIDE EFFECTS:
;           Changes xrange/yrange in setplot environment domain if
;           notransient option is selected.
;
; REMARK:
;           A more sophisticated but slower version is the command
;           "wplot" which allows button definitions by the user.
;           
; EXAMPLE:
;         > plot, data+model,res
;         > iplot
;                -> uses plot to interactively plot it. 
;
; HISTORY:
;           $Id: cafe_iplot.pro,v 1.7 2003/05/09 14:50:08 goehler Exp $
;-
;
; $Log: cafe_iplot.pro,v $
; Revision 1.7  2003/05/09 14:50:08  goehler
;
; updated documentation in version 4.1
;
; Revision 1.6  2003/03/17 14:11:29  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/09 17:36:04  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="iplot"

    ;; ------------------------------------------------------------
    ;; HELP
    ;; ------------------------------------------------------------
    ;; if help given -> print the specification above (from this file)
    IF keyword_set(help) THEN BEGIN
        cafe_help,env, name
        return
    ENDIF 


  ;; ------------------------------------------------------------
  ;; SHORT HELP
  ;; ------------------------------------------------------------
  IF keyword_set(shorthelp) THEN BEGIN  
    cafereport,env, "iplot    - interactive plot"
    return
  ENDIF



  ;; ------------------------------------------------------------
  ;; SETUP
  ;; ------------------------------------------------------------

  ;; width of displayed data. Use closest power to 10. For this we
  ;; exploit last plotted data units and convert 1.0 normal
  ;; coordinates to data coordinates in x-width. Isn't it nice?
  xwidth = 10^round(alog10((convert_coord(1.0,0.5,/normal,/to_data))[0]))

  
  ;; center position of displayed data. Use mid of currently displayed
  ;; data: 
  xpos   = (convert_coord(0.5,0.5,/normal,/to_data))[0]


  ;; save current plot parameters (they may change)
  plotparam_storage = (*env).plot.plotparams

  ;; ------------------------------------------------------------
  ;; MAIN INTERACTIVE LOOP
  ;; ------------------------------------------------------------

  ;; preliminaries
  cafereport,env,"IPLOT - USE MOUSE ON PLOT WINDOW TO NAVIGATE"
  cafereport,env,"  BUTTONS:"
  cafereport,env,"    ZOOM IN  - narrow visible range"
  cafereport,env,"    ZOOM OUT - enlarge visible range"
  cafereport,env,"    <<       - move left one page"
  cafereport,env,"    >>       - move right one page"
  cafereport,env,"    EXIT     - leafe IPLOT"
  cafereport,env,"  Clicking in plot window (left button) centers selected part"
  cafereport,env,"-------------------------------------------------------------"

  ;; loop till middle mouse pressed:
  REPEAT BEGIN 

      ;; --------------------------------------------------------
      ;; STORE CURRENT RANGE
      ;; --------------------------------------------------------

      ;; set current range:
      xrange=[xpos-xwidth/2.D0, xpos+xwidth/2.D0]

      cafe_setplot,env,"xrange=["+string(xrange[0])+","+ $
        string(xrange[1])+"]"

      cafereport,env,"X    : ", xpos
      cafereport,env,"RANGE: ", xwidth
      cafereport,env,"--------------------"


      ;; ------------------------------------------------------------
      ;; SHOW BUTTONS
      ;; ------------------------------------------------------------

      ;; remove plot window
      erase

      ;; display buttons with their numbers:
      cafeiplotbutton,0,"zoom in"
      cafeiplotbutton,1,"zoom out"
      cafeiplotbutton,2,"<<"
      cafeiplotbutton,3,">>"
      cafeiplotbutton,4,"exit"

      ;; --------------------------------------------------------
      ;; PLOT
      ;; --------------------------------------------------------
      
      ;; plot former definitions, do not erase or show plot information:
      cafe_plot,env, /noerase, /quiet


      ;; --------------------------------------------------------
      ;; INTERACTIVE CONTROL
      ;; --------------------------------------------------------

      ;; read cursor position
      CURSOR, x, y, /down,/normal ;


      ;; zoom in:
      if cafeiplotinbutton(x,y,0) then BEGIN 
          ;; decrease range in units of 2,5,10
          ;; the logarithmic formulae returns the range 1..10,
          ;; truncating numbers
           CASE round(10.D^(alog10(xwidth)-floor(alog10(xwidth)))) OF 
               1 : xwidth = xwidth / 2.D0
               2 : xwidth = xwidth / 2.D0
               5 : xwidth = xwidth / 5.D0 * 2.D0
               ELSE: xwidth = 10.D^floor(alog10(xwidth)) ;; for safety
           ENDCASE

          CONTINUE 
      ENDIF  


      ;; zoom out:
      if cafeiplotinbutton(x,y,1) then BEGIN 
          ;; increase range in units of 2,5,10
           CASE round(10.D^(alog10(xwidth)-floor(alog10(xwidth))))  OF 
               1 : xwidth = xwidth * 2.D0
               2 : xwidth = xwidth * 5.D0 / 2.D0
               5 : xwidth = xwidth * 2.D0
               ELSE: xwidth = 10.D^floor(alog10(xwidth)) ;; for safety
           ENDCASE

          CONTINUE 
      ENDIF  

      ;; << - move left:
      if cafeiplotinbutton(x,y,2) then BEGIN 
          xpos = xpos - 0.75*xwidth
          CONTINUE
      ENDIF 

      ;; >> - move right:
      if cafeiplotinbutton(x,y,3) then BEGIN 
          xpos = xpos + 0.75*xwidth
          CONTINUE
      ENDIF 

      ;; left -> shift x-pos
      if !mouse.button eq 1 then begin     
          ;; get new x-position in data time units:
          xpos=(convert_coord(x,0.5,/normal,/to_data))[0]
      endif    

      ;; --------------------------------------------------------
      ;; QUIT WHEN BUTTON PRESSED
      ;; --------------------------------------------------------
  ENDREP UNTIL cafeiplotinbutton(x,y,4)

  ;; --------------------------------------------------------
  ;; RESTORE PLOT PARAMETERS OVERRIDEN
  ;; --------------------------------------------------------
  IF NOT keyword_set(notransient) THEN $
    (*env).plot.plotparams = plotparam_storage


  ;; --------------------------------------------------------
  ;; RESTORE PLOT
  ;; --------------------------------------------------------
      
  ;; plot former definitions, do not erase or show plot information:
  cafe_plot,env

END 
