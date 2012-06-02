PRO  cafeiplotbutton, number, text
                      
;+
; NAME:
;           cafeiplotbutton
;
; PURPOSE:
;           plots button on graphic window
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           iplot
;
; SYNTAX:
;           cafeiplotbutton, number, text
;
; INPUT:
;           number - button number
;           text   - text of button
;
; DESCRIPTION:
;
;           In iplot some buttons should be displayed. These are
;           numbered, to allow easy handling, and equipped with text.
;           Events are afterwards handled with the function
;           cafeiplotinbutton. 
;
; SIDE EFFECTS:
;           none. 
;
;
; HISTORY:
;           $Id: cafeiplotbutton.pro,v 1.4 2002/09/10 13:24:36 goehler Exp $
;
;
; $Log: cafeiplotbutton.pro,v $
; Revision 1.4  2002/09/10 13:24:36  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.3  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.2  2002/09/09 17:36:20  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

      
    ;; ------------------------------------------------------------
    ;; CONFIGURATION
    ;; ------------------------------------------------------------

    ;; width of button in normal coordinates:
    width = 0.15

    ;; height of button in normal coordinates:
    height = width * 0.2 ; golden section ;-)

    ;; space between buttons
    margin = 0.01

    ;; set color:
    color = 200 

    ;; size of char (1.0 is normal)
    charsize = 2.0
      


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    ;; position of button:
    position = [margin+number*(width+margin), $
                margin,                       $
                (number+1)*(width+margin),    $
                margin+height                 $
               ]

    ;; ------------------------------------------------------------
    ;; SHOW BUTTON
    ;; ------------------------------------------------------------


    ;; button is text:
    plot,[0],[0],/normal,/nodata,/noerase,$
      position=position,                  $
      color=color,                        $
      xticklen=0.00001, yticklen=0.00001, $ ; clumsy: don't know how to disable ticks. 
      xtickformat="nolabel", ytickformat="nolabel"

    xyouts, margin+number*(width+margin)+0.5*width, $ ; x position
      margin+0.3*height,                     $ ; y position
      text,charsize=charsize,                $
      color=color,alignment=0.5,/normal
    

END 
