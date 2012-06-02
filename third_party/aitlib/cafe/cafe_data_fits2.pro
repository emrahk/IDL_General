PRO cafe_data_fits2, env, filename, group, subgroup, $
                     param,                          $
                     help=help, shorthelp=shorthelp
;+
; NAME:
;           data_fits
;
; PURPOSE:
;           Read in 2-d data set from fits file (binary/ascii table)
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           data
;
; DATA FORMAT:
;           Read the file as an fits file containing the
;           data in tables. Images are still not supported.
;
;
; PARAMETER:
;           (optional) parameters are ordered as follows:
;               - The column for the X1 axis data. This may be either the
;                 column name or its number. Default is column 1.
;               - The column for the X2 axis data. This may be either the
;                 column name or its number. Default is column 2.
;               - The column for the Y axis data. This may be either the
;                 column name or its number. Default is column 3.
;               - (Optional) The column for the ERROR axis data.
;                 This may be either the column name or its
;                 number. Default is column 4. 
;                 If not given the error is omitted. 
;               - (optional) The extension number. If not given the
;                 extension number 1 is used (first extension).
;                 
;               All parameters are separated with ";". If one
;               parameter is not defined (empty string) the default
;               column is used. 
;               
; SIDE EFFECTS:
;           Loads file data into environment.
;
; EXAMPLE:
;
;               > data, rate.fits:3,fits2[x;y;z] 
;               -> loads in data from ascii file test.dat (marked via
;               extension dat) to first free subgroup in group 5. Use
;               columns x,y for independent values and z for dependend values.
;
; HISTORY:
;           $Id: cafe_data_fits2.pro,v 1.3 2003/03/17 14:11:28 goehler Exp $
;             
;-
;
; $Log: cafe_data_fits2.pro,v $
; Revision 1.3  2003/03/17 14:11:28  goehler
; review/documentation updated.
;
; Revision 1.2  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.1  2002/09/20 09:52:46  goehler
; - data now handles more than one file
; - file type dat now faster
; - added 2-d data input types
;
;
;
;

    ;; command name of this source (needed for automatic help)
    name="data_fits2"

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
        print, "fits     - 2-d fits data type"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER:
    ;; ------------------------------------------------------------
    
    ;; split items:
    paramitems=stregex(param,"(.*),(.*),(.*)(,(.*))?(,([0-9]+))?",/extract,/subexpr)

    ;; define x1 column to read (number or string)
    IF stregex(paramitems[1],"[0-9]+",/boolean) THEN BEGIN 
        x1col = fix(paramitems[1])                     
    ENDIF ELSE  BEGIN 
        ;; copy string:
        x1col = paramitems[1]                 

        ;; undefined x column -> default is 1
        IF x1col EQ "" THEN x1col = 1
    ENDELSE 

    ;; define x2 column to read (number or string)
    IF stregex(paramitems[2],"[0-9]+",/boolean) THEN BEGIN 
        x2col = fix(paramitems[2])                     
    ENDIF ELSE  BEGIN 
        ;; copy string:
        x2col = paramitems[2]                 

        ;; undefined x column -> default is 1
        IF x2col EQ "" THEN x2col = 2
    ENDELSE 


    ;; define y column to read (number or string)
    IF stregex(paramitems[3],"[0-9]+",/boolean) THEN BEGIN 
        ycol = fix(paramitems[3])                     
    ENDIF ELSE  BEGIN 
        ;; copy string:
        ycol = paramitems[3]                 
          
        ;; undefined x column -> default is 1
        IF ycol EQ "" THEN ycol = 2
    ENDELSE 

    ;; define error column to read (number or string)
    IF stregex(paramitems[5],"[0-9]+",/boolean) THEN BEGIN 
        errcol = fix(paramitems[5])                     
    ENDIF ELSE  BEGIN 
        ;; copy string:
        errcol = paramitems[5]                           
    ENDELSE 


    ;; define extension to use if given
    IF paramitems[7] NE "" THEN    $
      extension=fix(paramitems[7]) $
    ELSE                           $
      extension=1

    ;; ------------------------------------------------------------
    ;; READ DATA
    ;; ------------------------------------------------------------

    ;; read x:
    ftab_ext,filename,x1col,x1,exten_no=extension
    ftab_ext,filename,x2col,x2,exten_no=extension

    ;; read y:
    ftab_ext,filename,ycol,y,exten_no=extension

    ;; read error if given:
    IF paramitems[5] NE "" THEN BEGIN 
        ftab_ext,filename,errcol,err,exten_no=extension
        (*env).groups[group].data[subgroup].err = PTR_NEW(err) 
    ENDIF 
        
      
    (*env).groups[group].data[subgroup].x = PTR_NEW([[x1],[x2]]) 
    (*env).groups[group].data[subgroup].y = PTR_NEW(y) 

    
    ;; allocate defined measure point array (default all defined):
    (*env).groups[group].data[subgroup].def = PTR_NEW(bytarr(n_elements(y),/nozero)) 
    (*(*env).groups[group].data[subgroup].def)[*]=1

    ;; allocate selected point array (none selected):
    (*env).groups[group].data[subgroup].selected = $
      PTR_NEW(bytarr(n_elements(y),/nozero)) 
    (*(*env).groups[group].data[subgroup].selected)[*]=0
    
    (*env).groups[group].data[subgroup].file = filename


    ;; ------------------------------------------------------------
    ;; STATUS REPORT
    ;; ------------------------------------------------------------
        
    cafereport,env,"  File:     "+filename 
    cafereport,env,"  Group:    "+strtrim(string(group),2) 
    cafereport,env,"  Subgroup: "+strtrim(string(subgroup),2) 
    cafereport,env,"  Datapoints: " +strtrim(string(n_elements(y)),2)
    
    
  RETURN  
END
