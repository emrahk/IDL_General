PRO cafe_export_dat, env, filename, group,           $
                     param,                          $
                     help=help, shorthelp=shorthelp
;+
; NAME:
;           export_dat
;
; PURPOSE:
;           Write out data to ascii file.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           data
;
; DATA FORMAT:
;           Write data into ascii file, column separated:
;           - The column 0 for the X axis.
;           - The column 1 for the Y axis.
;           - The column 2 for the ERROR axis if error is defined. 
;
; PARAMETER:
;           (optional) Parameter text will be preprended, marked with
;           "#". 
;               
; SIDE EFFECTS:
;           Writes all subgroup data to ascii file.
;
; EXAMPLE:
;
;               > export, test.dat:5, 
;               -> writes all data (all subgroups) of group 5 into
;               ascii file test.dat 
;
; HISTORY:
;           $Id: cafe_export_dat.pro,v 1.1 2003/04/15 09:27:10 goehler Exp $
;             
;-
;
; $Log: cafe_export_dat.pro,v $
; Revision 1.1  2003/04/15 09:27:10  goehler
; new facility to write data to file
;
;
;
;

    ;; command name of this source (needed for automatic help)
    name="export_dat"

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
        print, "export   - ascii export type"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    ;; ------------------------------------------------------------
    ;; WRITE DATA
    ;; ------------------------------------------------------------
    
    
    ;; open file
    get_lun, writelun
    openw, writelun, filename

    ;; write header:
    IF param NE "" THEN BEGIN 
        printf, writelun, "# "+param
    ENDIF 
    


    ;; all subgroups
    FOR i = 0, n_elements((*env).groups[group].data[*])-1 DO BEGIN 


        ;; skip empty subgroups:
        IF NOT PTR_VALID((*env).groups[group].data[i].y)  THEN CONTINUE 
      

        ;; write default header info:
        IF param EQ "" THEN BEGIN 
            printf, writelun, "#","Group: ",group, $
              format="(A,A11, I3)"
            printf, writelun, "#", "Subgroup: ",i, $
              format="(A, A11, I3)"
        ENDIF 

        ;; number of dimensions in x:
        dimnum = n_elements((*(*env).groups[group].data[i].x)[0,*])
      

        ;; create x-string if number not zero:
        IF dimnum GT 1 THEN BEGIN
            xtitlestr = ""
            xtitleformatstr= ""
            xformatstr= ""
            FOR j = 1,dimnum DO BEGIN 
                xtitlestr = [xtitlestr, "X"+strtrim(string(j),2)]
                xtitleformatstr=xtitleformatstr+"A15,"
                xformatstr = xformatstr + (*env).format.xformat +","
            ENDFOR 
            xtitlestr = xtitlestr[1:dimnum]
        ENDIF ELSE BEGIN 
            xtitlestr = "X"
            xtitleformatstr= "A14,"
            xformatstr = (*env).format.xformat + ","
        ENDELSE


        ;; error exists -> write error column:
        IF ptr_valid((*env).groups[group].data[i].err) THEN BEGIN 

            ;; write default header:
            IF param EQ "" THEN BEGIN 
                printf, writelun, "#",xtitlestr,"Y","ERROR",$
                  format="(A,"+xtitleformatstr+"A15,A15)"
            ENDIF 
            
            ;; define format to use:
            format = "("+xformatstr         $
              +    (*env).format.yformat $
              + ","+(*env).format.errformat + ")"
            
            ;; actually write data:
            printf, writelun,                        $   
              transpose([                            $
              [(*(*env).groups[group].data[i].x)],     $
              [(*(*env).groups[group].data[i].y)],     $ 
              [(*(*env).groups[group].data[i].err)]]), $
              format=format
            
        ENDIF ELSE BEGIN ;; no error column:
            ;; define format to use:
            format = "("+xformatstr         $
              +    (*env).format.yformat + ")"
            
            ;; write default header:
            IF param EQ "" THEN BEGIN 
                printf, writelun, "#", xtitlestr,"Y",       $
                  format="(A,"+xtitleformatstr+"A15)"
            ENDIF 

            ;; actually write data:
            printf, writelun,                         $
              transpose([                             $
              [(*(*env).groups[group].data[i].x)],    $
              [(*(*env).groups[group].data[i].y)]]),  $ 
              format=format
        ENDELSE 
    ENDFOR 


    ;; reading finished
    close, writelun 
    free_lun, writelun
    
    
    
  RETURN  
END
