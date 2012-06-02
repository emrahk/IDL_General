function cafeenv__define
;+
; NAME:
;           cafeenv__define
;
; 
; PURPOSE:
;       Environment structure definition of the CAFE
;       program. This procedure allows automatic structure
;       definition after IDL version 5.0
;
;
; CATEGORY:
;       CAFE
;
;
;
; CALLING SEQUENCE:
;       This function returns a initial environment structure
;       and acts as an "constructor" for the cafeenv structure. 
;
;
;
; SIDE EFFECTS:
;       Running this procedure defines the structure CAFEENV.
;
;
;
; RESTRICTIONS:
;
;
;
;
; PROCEDURE:
;
;
;
;
; MAINTENANCE:
;       If a command of the CAFE program needs some
;       environment parameter (either to keep them between
;       several calls of the command or to transfer data
;       between different commands), it must add this
;       parameter with a unique name.
;       If this structure allocates some resources, these must
;       be cleaned up in procedure cafeenv_cleanup.pro
;
;
; EXAMPLE:
;
;
;
;
; MODIFICATION HISTORY:
;
;
;-
;
; $Log: cafeenv__define.pro,v $
; Revision 1.34  2003/05/06 13:17:39  goehler
; - added result group which can be set with chres
; - added global setup information which can be used by certain
;   data processing commands.
;
; Revision 1.33  2003/05/05 09:26:07  goehler
; first working version of legend. Allocation a bit hand-made.
;
; Revision 1.32  2003/05/02 07:23:52  goehler
; changed default prompt from cafe> to cafe:0> (including group info)
;
; Revision 1.31  2003/04/28 14:38:09  goehler
; added storage for wplot slider display
;
; Revision 1.30  2003/04/24 09:49:49  goehler
; added command file lun to be stored for batch/interactive processing.
; Needed for proper log report
;
; Revision 1.29  2003/03/11 14:35:38  goehler
; updated plotout for multiple plots. tested.
;
; Revision 1.28  2003/03/10 16:43:17  goehler
; change of plotout: use own version of open_print.
; future change: multiple prints into single file. Still not working.
;
; Revision 1.27  2003/03/03 11:18:33  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.26  2003/02/26 16:10:14  goehler
; allow 30 groups
;
; Revision 1.25  2003/02/18 08:02:32  goehler
; change of steppar/contour:
; use free group 9 to put contour plot at
;
; Revision 1.24  2003/02/14 18:31:01  goehler
; fix of t3d-wplot bug. must use device coordinates, not normal one...
;
; Revision 1.23  2003/02/13 14:44:48  goehler
; added slider for wplot (may be added as buttons)
;
; Revision 1.22  2003/02/12 12:57:45  goehler
; set default rotation axis at 30 deg
;
; Revision 1.21  2003/02/12 12:40:15  goehler
; added rotation information
;
; Revision 1.20  2002/09/10 13:24:34  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.19  2002/09/09 17:36:19  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;



  ;; ------------------------------------------------------------
  ;; SIZE CONSTANTS
  ;; ------------------------------------------------------------

    MAX_GROUP_NUM = 30     ; maximal number of available groups (independent data sets)

    MAX_SUBGROUP_NUM = 10  ; maximal number of available subgroups (dependent data sets)

    MAX_MODELCOMP_NUM = 10 ; maximal number of model components in one group 

    MAX_PARAMETER_NUM = 10     ; maximal number of parameter per model

    MAX_PANEL_NUM = 10     ; maximal number of plot panels



  ;; ------------------------------------------------------------
  ;; DATA SET STRUCTURE
  ;; ------------------------------------------------------------
    
    dataset = {cafedata,        $
               file : "",         $  ; file name of data set
               x  : ptr_new(),    $  ; its x values
               y  : ptr_new(),    $  ; its y values
               err: ptr_new(),    $  ; its error values
               def: ptr_new(),    $  ; array indicating wether value is defined (1)
               selected: ptr_new()$  ; array indicating wether point is selected (1)
              }

  ;; ------------------------------------------------------------
  ;; FIT PARAMETER STRUCTURE
  ;; ------------------------------------------------------------

    fitparam = {cafeparam,      $
                parname : "",     $ ; parameter name
                value   : 0.D0,   $ ; value to fit
                error   : 0.D0,   $ ; resulting fit error
                fixed   : 0,      $ ; fit parameter free (0) or fixed (1)
                limits : [0.D0,0.D0],  $ ; limits of fit
                limited: [0,0],        $ ; which limits to apply
                tied    : "",          $ ; parameter is tied to another
                tie_info: "",          $ ; tie parameter information
                errmin  : 0.D0,        $ ; error minimum value
                errmax  : 0.D0,        $ ; error maximum value
                errmininfo: 0.D0,      $ ; error minimum determination info
                errmaxinfo: 0.D0,      $ ; error maximum determination info
                step      : 0.D0,      $ ; step for computing derivatives. 0 means none.
                mpside    : 0   ,      $ ; sidenes of function. 0 means all
                mpminstep : 0.D0,      $ ; minimum step for each iteration. 0 means none
                mpmaxstep : 0.D0       $ ; maximum step numbers to perform. 0 means none
               }
    


    
  ;; ------------------------------------------------------------
  ;; FIT GROUP STRUCTURE
  ;; ------------------------------------------------------------

        fitgroup = {cafegroup,                         $
                model     : "",                        $
                data      : REPLICATE(dataset,         $ ; data sets in subgroups
                                     MAX_SUBGROUP_NUM) $
               }


  ;; ------------------------------------------------------------
  ;; FIT RESULT STRUCTURE
  ;; ------------------------------------------------------------

        fitresult = {caferesult,                       $
                     selected  :  0                    $ ; flag which is set when last fit 
                                                         ; was obtained with selected data
                                                         ; points 
               }


  ;; ------------------------------------------------------------
  ;; PLOT STRUCTURE
  ;; ------------------------------------------------------------

        plotenv = {cafeplotenv,                  $
                panels : strarr(MAX_PANEL_NUM),  $ ; plot type of all panels ("" if not used)
                plotparams: strarr(MAX_PANEL_NUM),$ ; plot parameter for all panels
                range     : dblarr(6),            $ ; range of all dimensions
                xwidth    : 0.D0,                $  ; width of range     (w/iplot)
                xpos      : 0.D0,                $  ; position of center (w/iplot)
                ywidth    : 0.D0,                $  ; width of range     (w/iplot)
                ypos      : 0.D0,                $  ; position of center (w/iplot)
                zwidth    : 0.D0,                $  ; width of range     (w/iplot)
                zpos      : 0.D0,                $  ; position of center (w/iplot)
                ax        : 30.D0,               $  ; Rotation around X-Axis for 3D view
                az        : 30.D0,               $  ; Rotation around Z-Axis for 3D view
                t3d       : !P.T,                $  ; 3D conversion matrix 
                plotoutfile: "",                 $  ; file which was opened for plotout
                plotouttype: "",                 $  ; file type which was used for plotout last time
                legend: ""                       $  ; legend info to draw
               }

  ;; ------------------------------------------------------------
  ;; PRINT FORMAT STRUCTURE
  ;; ------------------------------------------------------------

        formatenv = {cafeformatenv,                  $
                xformat   : "F15.5",      $ ;  format of x axis print
                yformat   : "F15.5",      $ ;  format of y axis print
                errformat : "F15.7",      $ ;  format of err axis print
                paramvalformat   : "F15.5",  $ ;  format of parameter values
                paramerrformat   : "F15.7"   $ ;  format of parameter errors
               }


  ;; ------------------------------------------------------------
  ;; SHOW STRUCTURE
  ;; ------------------------------------------------------------

        showenv = {cafeshowenv,                  $
                topic   : "result"      $ ; topic to show
               }


  ;; ------------------------------------------------------------
  ;; STEPPAR STRUCTURE
  ;; ------------------------------------------------------------

        stepparenv = {cafestepparenv,     $
                      param1 : fitparam,  $ ; parameter 1 values
                      param2 : fitparam   $ ; parameter 2 values
                     }


  ;; ------------------------------------------------------------
  ;; WIDGET STRUCTURE
  ;; ------------------------------------------------------------

        widgetenv = {cafewidgetenv,       $ ; WIDGET INFO FOR WPLOT
                     defaultID: 0,        $ ; the default window ID when closing
                     baseID : 0,          $ ; the ID of the wplot widget
                     drawID : 0,          $ ; the ID of the draw widget used for plotting
                     pixID  : 0,          $ ; ID of pixmap to retain plot
                     xlabelID: 0,         $ ; ID of label for x position
                     ylabelID: 0,         $ ; ID of label for y position
                     in_area : 0,         $ ; flag: when mouse pressed =1
                     xsize   : 0,         $
                     ysize   : 0,         $
                     xstart  : 0.D0,        $
                     ystart  : 0.D0,        $
                     addon_buttons : "",  $ ; buttons used as add-on 
                     addon_sliders : "",  $ ; sliders used as add-on 
                     savefile : ""        $ ; file name to save fit parameter into
                     }

  ;; ------------------------------------------------------------
  ;; CAFE ENVIRONMENT STRUCTURE
  ;; ------------------------------------------------------------
  
  env =  ptr_new({cafeenv,                 $ ; structure contains environment 
          name        : "cafe",    $ ; name of this environment
          praefix     : "cafe_",   $ ; praefix for all files of this environment
          prompt      : "cafe:%g> ", $ ; command line prompt 
          logfile_lun : 0,           $ ; log file handle (0 if no logfile)
          cmdfile_lun : 0,           $ ; command file handle (0 if no command file)
          def_grp     : 0,           $ ; default group (could be changed)
          res_grp     : -1,          $ ; default result group for transformation results
          groups      : REPLICATE(fitgroup,          $ ; available groups
                                  MAX_GROUP_NUM),    $          
          parameter   : REPLICATE(fitparam,          $ ; list of parameter to fit 
                                  MAX_PARAMETER_NUM, $ ; for each model
                                  MAX_MODELCOMP_NUM, $ ; and group
                                  MAX_GROUP_NUM),    $ 
          plot        : plotenv,                     $ ; plotting properties
          format      : formatenv,                   $ ; print properties
          show        : showenv,                     $ ; show properties
          steppar     : stepparenv,                  $ ; steppar properties
          fitresult   : fitresult,                   $ ; common results of last fit
          widgets     : widgetenv,                   $ ; common results of last fit
          setup       : ""                           $ ; common settings
        })

  ;; ------------------------------------------------------------
  ;; INITIAL SETUP
  ;; ------------------------------------------------------------
  
  ;; first panel: data
  (*env).plot.panels[0] = "data"
  
  RETURN, env
END











