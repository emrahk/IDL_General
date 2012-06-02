FUNCTION  cafeiplotinbutton, x,y, number
                      
;+
; NAME:
;           cafeiplotinbutton
;
; PURPOSE:
;           returns whether button hit
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           iplotinbutton
;
; SYNTAX:
;           flag=cafeiplotinbutton(x,y, number)
;
; INPUT:
;           x,y    - (normal) coordinates to test. 
;           number - button number
;           
;
; DESCRIPTION:
;
;           If (x,y) lays in the button with given button number 1 is
;           returned, otherwise 0. 
;           x,y must be normal coordinates (ranging from 0..1).
;           
; SIDE EFFECTS:
;           none. 
;
;
; HISTORY:
;           $Id: cafeiplotinbutton.pro,v 1.5 2002/09/10 13:24:36 goehler Exp $
;
;
; $Log: cafeiplotinbutton.pro,v $
; Revision 1.5  2002/09/10 13:24:36  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.4  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.3  2002/09/09 17:36:20  goehler
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
    ;; COMPUTE IN-RELATION
    ;; ------------------------------------------------------------

    return,  ((x GE  position[0]) AND $
              (x LE position[2])  AND $ 
              (y GE position[1])  AND $
              (y LE position[3]))
    

END 
