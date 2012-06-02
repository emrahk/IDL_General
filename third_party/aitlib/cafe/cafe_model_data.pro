FUNCTION  cafe_model_data, x, parameter, env=env,$
                  getparam=getparam,             $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           model_data
;
; PURPOSE:
;           Use separate data in distinct group as fit model. 
;
; CATEGORY:
;           CAFE
; 
; SUBCATEGORY:
;           fitmodel
;  
; INPUTS:
;           x         - Input x value array. Should be double precision.
;           parameter - Parameter to compute model. Must contain 1
;                       value.  
; 
; PARAMETERS:
;           data:grp - group using to get data. !! THIS
;                      PARAMETER MUST BE FIXED AND INTEGER !!!
;                      (Otherwise the fit algorithm tries to
;                      vary the group - would be quite interesting...)
;                      It is prudent not to define a model for
;                      the group which contains these data.
;
; OUTPUT:
;           y = data[x].
;           To allow arbitrary x-values interpolation will be
;           used. For x values out of the data range the closest data
;           x value will be used.  
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_data.pro,v 1.6 2003/03/17 14:11:30 goehler Exp $
;-
;
; $Log: cafe_model_data.pro,v $
; Revision 1.6  2003/03/17 14:11:30  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/10 13:24:31  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.3  2002/09/09 17:36:05  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;



    name="model_data"

    ;; ------------------------------------------------------------
    ;; HELP
    ;; ------------------------------------------------------------
    ;; if help given -> print the specification above (from this file)
    IF keyword_set(help) THEN BEGIN
        cafe_help,env, name,/model
        return,0
    ENDIF 


  ;; ------------------------------------------------------------
  ;; short HELP
  ;; ------------------------------------------------------------
  IF KEYWORD_SET(SHORTHELP) THEN BEGIN  
      PRINT, "data - use separate data as fit model"
      RETURN, 0
  ENDIF




  ;; ------------------------------------------------------------
  ;; PARAMETER SETTING
  ;; ------------------------------------------------------------

  IF keyword_set(getparam)  THEN BEGIN 
      param={cafeparam}
      param.parname = "data:grp"
      param.fixed   = 1
      param.value   = 1 ;; default group: 1
      return, param
  ENDIF

  ;; ------------------------------------------------------------
  ;; SETUP
  ;; ------------------------------------------------------------

  ;; set group according parameter:
  group = fix(parameter[0])



  ;; ------------------------------------------------------------
  ;; COMPUTE Y/ERROR VALUE FOR  EACH SUBGROUP:
  ;; ------------------------------------------------------------


    ;; dummy startup values:
    x_data=0.D0
    y_data=0.D0

    
    ;; check all subgroups, build x/y data array
    FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

        ;; skip not defined data sets (subgroups)
        IF NOT PTR_VALID((*env).groups[group].data[subgroup].y)  THEN CONTINUE

        ;; index for defined values:
        IF (*env).fitresult.selected THEN BEGIN 
            def_index = where(*(*env).groups[group].data[subgroup].def AND $
                              *(*env).groups[group].data[subgroup].selected)
        ENDIF ELSE BEGIN 
            def_index = where(*(*env).groups[group].data[subgroup].def)
        ENDELSE 

        ;; no index found -> next data set
        IF def_index[0] EQ -1 THEN CONTINUE 
            
        x_data = [x_data,(*(*env).groups[group].data[subgroup].x)[def_index]]
        y_data = [y_data,(*(*env).groups[group].data[subgroup].y)[def_index]]
            


    ENDFOR 


    ;; check for datapoints, remove first dummy one:
    IF n_elements(y_data) GT 1 THEN BEGIN 
        x_data =x_data[1:*]
        y_data =y_data[1:*]        

    ENDIF ELSE BEGIN
        ;; no datapoint found -> return 0.
        return, 0.D0
    ENDELSE


  ;; ------------------------------------------------------------
  ;; COMPUTE VALUE BY INTERPOLATION:
  ;; ------------------------------------------------------------

  ;; actual computation:
  return,  interpol(y_data,x_data,x)

END  


