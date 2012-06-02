PRO  cafe_fiterror, env, $
                  quiet=quiet, selected=selected, $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           fiterror
;
; PURPOSE:
;           reconstruct error column by fitting model
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           fiterror [,subgroup][,group][,/selected][,/quiet]
;
; INPUTS:
;
; OPTIONS:
;           quiet      - Do not show fit processing.
;           selected   - Apply fit to selected data points only.
;
;
; DESCRIPTION:
;
;          If the data set does not contain a error column the fit
;          process assumes an error of 1 which leads to improper fit
;          statistics. With this command it is possible to reconstruct
;          an error using following assumptions:
;          1.) The error is basically the same for all data points.
;          2.) The model to fit is a good fit so the resulting reduced
;              Chi^2 is 1.
;          Of course these assumptions are not always justified, so
;          this command should be used with care. This also means that
;          for following fits the resulting reduced Chi^2 value is 1
;          and could not be used to establish a goodness of the fit.
;          But the command may help for deriving a formal error by
;          first selecting ranges of data points with well-known model
;          features, reconstructing the error column and then apply
;          this full data set to other regions where a closer model
;          must be applied.
;
;          If more than one data set is given all data sets which are
;          involved in the fitting process are taken into
;          account. Excluded are:
;          - Groups without a defined model
;          - Groups with a model but no valid data points. If a group
;            contains defined but not selected data points and the
;            option /selected was chosen this group is also ignored.
;          Subgroups with unselected data points when the group is
;          valid and the select option is used are noticed. 
;
; REMARK:
;          Use with care! Former error columns are modifierd; and the
;          new error column of data may contain misleading values.  
;
;
; SIDE EFFECTS:
;           Adds error column to data set.
;           Changes parameter values/errors in environment
;           according fit result.
;               
;
; EXAMPLE:  
;           > model, lin      ; apply simple model for first part
;           > ignore, 100-*   ; of data, which is flat
;           > fiterror        ; create error column
;           > notice, *       ; for all data:
;           > model, lin+gauss; apply complex model
;           > fit             ;   for a fit. 
;                     -> fit exhibits a goodness of fit for the
;                        complex model
;
; HISTORY:
;           $Id: cafe_fiterror.pro,v 1.8 2003/04/30 13:59:37 goehler Exp $
;-
;
; $Log: cafe_fiterror.pro,v $
; Revision 1.8  2003/04/30 13:59:37  goehler
; change: compute error for *all* valid groups/subgroups.
;
; Revision 1.7  2003/03/17 14:11:28  goehler
; review/documentation updated.
;
; Revision 1.6  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.5  2002/09/09 17:36:03  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="fiterror"

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
        cafereport,env, "fiterror - reconstruct data error column"
        return
    ENDIF

    
    ;; ------------------------------------------------------------
    ;; PERFORM FIT TO GET BEST FIT VALUE
    ;; ------------------------------------------------------------
    
    cafe_fit,env,quiet=quiet, selected=selected


    ;; ------------------------------------------------------------
    ;; CHECK WHICH GROUP IS VALID
    ;; ------------------------------------------------------------

    ;; list of valid groups
    grouplist = 0

    FOR grp=0, n_elements((*env).groups)-1 DO BEGIN 

        ;; skip groups without model:
        IF (*env).groups[grp].model EQ "" THEN  CONTINUE 


        ;; point number in current group:
        group_point_num = 0l
   
        ;; check all subgroups, build y/error array
        FOR subgroup = 0, n_elements((*env).groups[grp].data)-1 DO BEGIN 

            ;; skip not defined data sets (subgroups)
            IF NOT PTR_VALID((*env).groups[grp].data[subgroup].y)  THEN CONTINUE

            ;; index for defined values:
            IF keyword_set(selected) THEN BEGIN 
                def_index = where(*(*env).groups[grp].data[subgroup].def AND $
                                  *(*env).groups[grp].data[subgroup].selected)
            ENDIF ELSE BEGIN 
                def_index = where(*(*env).groups[grp].data[subgroup].def)
            ENDELSE 


            ;; no index found -> next data set
            IF def_index[0] EQ -1 THEN CONTINUE 

            ;; summ up defined data points in current group
            group_point_num=group_point_num+n_elements(def_index)           
        ENDFOR

        ;; if no data points in current group ->
        ;; disable all parameters in current group
        IF group_point_num NE 0 THEN BEGIN 
            grouplist = [grouplist,grp]
        ENDIF 
    ENDFOR


    ;; check singularity case:
    IF n_elements(grouplist) LT 2 THEN BEGIN 
        cafereport,env, "Error: no valid group"
        return 
    ENDIF 

    ;; remove dummy element:
    grouplist = grouplist[1:*]


    ;; ------------------------------------------------------------
    ;; COMPUTE NEW ERROR COLUMN FOR ALL VALID GROUPS/SUBGROUPS:
    ;; ------------------------------------------------------------

    ;; reconstruct common error:
    common_error = sqrt(cafegetchisq(env,selected=selected)$
                        / cafegetdof(env,selected=selected))

    FOR i=0,n_elements(grouplist)-1 DO BEGIN 

        group = grouplist[i]

        ;; for each subgroup:
        FOR sg=0, n_elements((*env).groups[group].data)-1 DO BEGIN 

            ;; check data set existence:
            IF PTR_VALID((*env).groups[group].data[sg].def) EQ 0  THEN CONTINUE


            ;; error exists -> quest
            IF ptr_valid((*env).groups[group].data[sg].err) THEN BEGIN 

                                ;-)
                cafereport,env, "Warning: for subgroup"+strtrim(string(sg),2)$
                  +" the error already exists. Change its values?"
                
                ;; ask
                input=""
                caferead,env,  input, prompt="[y/n]"
                IF input NE "y" THEN CONTINUE 
                
                ;; copy existing error column
                error = *(*env).groups[group].data[sg].err

            ENDIF  ELSE BEGIN 
                
                ;; create error column if not existing:
                error = dblarr(n_elements(*(*env).groups[group].data[sg].def))
                
                ;; set at unity:
                error[*] = 1.D0
            ENDELSE                         
            
            ;; error_new = error_old * chi^2/dof
            error = temporary(error) * common_error


            ;; delete former error
            IF ptr_valid((*env).groups[group].data[sg].err) THEN $
              ptr_free, (*env).groups[group].data[sg].err
            
            
            ;; set new error
            (*env).groups[group].data[sg].err = ptr_new(error)

        ENDFOR  ; subgroup
    ENDFOR ; group


    ;; ------------------------------------------------------------
    ;; REPORT COMMON ERROR
    ;; ------------------------------------------------------------

    cafereport,env, "Common error for all datapoints is: "+strtrim(string(common_error),2)

END 
