;+
; NAME:
;           wplot_savefit
;
; PURPOSE:
;           Button to save fitted parameters into file
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +savefit[file]+
;
; SUBCATEGORY:
;           wplot add-on button
;
; BUTTON LABEL:
;           "Savefit"
;
; DESCRIPTION:
;           After a fit was performed this action will save last
;           (wplot) fit parameters into a text file with the name
;           fitparam.dat".
;           Saved will be:
;               - the fit parameter+value
;               - the fit error, if given
;               - current x range position 
;               
; PARAMETER:
;          file - The file to save the data into. If the file exists a
;                 warning will be shown but the data will be appended
;                 at given file. 
;
;                 If no file is given the filename is
;                 "fitparam.dat". 
;               
; SIDE EFFECTS:
;           Changes file content.
;
; REMARK:
;           Calls the SAVE command with the "param" file type.
;
;
; HISTORY:
;           $Id: cafe_wplot_savefit.pro,v 1.17 2003/04/28 07:45:10 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_savefit.pro,v $
; Revision 1.17  2003/04/28 07:45:10  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.16  2003/04/24 09:45:58  goehler
; moved parameter saving to new procedure cafe_save_param
; which allows interactive saving also.
;
; Revision 1.15  2003/03/17 14:11:41  goehler
; review/documentation updated.
;
; Revision 1.14  2003/03/04 16:45:00  goehler
;  bug fix: pointer to environment not dereferenced with (*env).
;
; Revision 1.13  2003/03/03 11:18:30  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.12  2003/02/26 08:34:16  goehler
; added print command
;
; Revision 1.11  2003/02/24 17:18:34  goehler
; - save title also
; - one line per parameter save only.
;
; Revision 1.10  2003/02/14 16:40:33  goehler
; documentized
;
; Revision 1.9  2002/09/10 13:24:34  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.8  2002/09/09 17:36:16  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;



;; ------------------------------------------------------------
;; CAFE_WPLOT_BUTTONEVENT --- EVENT PROCEDURE WHEN BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_savefitevent, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env
    
    ;; save the parameters:
    cafe_save,env,(*env).widgets.savefile,"param",/clobber

    ;; report command:
    cafereport,env,'save,'+(*env).widgets.savefile+',param,/clobber',/nocomment
END    


;; ------------------------------------------------------------
;; SAVEFIT - THE MAIN FUNCTION WHICH ALLOCATES A NEW BUTTON
;; ------------------------------------------------------------

PRO cafe_wplot_savefit,env,  baseID, file,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_savefit"
    
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
        print, "savefit   - saves fit parameters of last fit"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------



    ;; ------------------------------------------------------------
    ;; SET FILENAME/CHECK EXISTENCE
    ;; ------------------------------------------------------------

    IF n_elements(file) EQ 0 THEN file = "fitparam.dat"

    ;; default file:
    IF file  EQ "" THEN file = "fitparam.dat"

    (*env).widgets.savefile = file

    IF file_exist(file) THEN BEGIN 
        cafereport,env, "Warning: File "+file+" already exists."
        cafereport,env, "         New fit results will be appended."
    ENDIF 

    ;; ------------------------------------------------------------
    ;; ALLOCATE WIDGET
    ;; ------------------------------------------------------------
    buttonID= widget_button(baseID, value="Savefit", $
                            event_pro="cafe_wplot_savefitevent")

END   
