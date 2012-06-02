PRO cafe_data_fits, env, filename, group, subgroup, $
                     param,                          $
                     help=help, shorthelp=shorthelp
;+
; NAME:
;           data_fits
;
; PURPOSE:
;           Read in data set from fits file (binary/ascii table)
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           data
;
; DATA FORMAT:
;           Read the file as an fits file containing the
;               data in tables. Images are still not supported.
;
;
; PARAMETER:
;           (optional) parameters are ordered as follows:
;               - The column for the X axis data. This may be either the
;                 column name or its number. Default is column 1.
;               - The column for the Y axis data. This may be either the
;                 column name or its number. Default is column 2.
;               - (Optional)The column for the ERROR axis data. This may be either the
;                 column name or its number. Default is column 3.
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
;               > data, rate.fits[time;]:3, 
;               -> loads in data from ascii file test.dat (marked via
;               extension dat) to first free subgroup in group 5.
;
; HISTORY:
;           $Id: cafe_data_fits.pro,v 1.9 2003/04/08 07:29:49 goehler Exp $
;             
;-
;
; $Log: cafe_data_fits.pro,v $
; Revision 1.9  2003/04/08 07:29:49  goehler
; fix: allow y column names containing more than one char (missing *)
;
; Revision 1.8  2003/03/13 08:49:52  goehler
; fix: separate parameters properly with ","
;
; Revision 1.7  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.6  2002/09/10 13:24:31  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.5  2002/09/09 17:36:02  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="data_fits"

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
        print, "fits     - fits data type"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER:
    ;; ------------------------------------------------------------
    
    ;; split items:
    paramitems=stregex(param,"([^,]*),([^,]*)(,([^,]*))?(,([0-9]+))?",/extract,/subexpr)

    ;; define x column to read (number or string)
    IF stregex(paramitems[1],"[0-9]+",/boolean) THEN BEGIN 
        xcol = fix(paramitems[1])                     
    ENDIF ELSE  BEGIN 
        ;; copy string:
        xcol = paramitems[1]                 
          
        ;; undefined x column -> default is 1
        IF xcol EQ "" THEN xcol = 1
    ENDELSE 


    ;; define y column to read (number or string)
    IF stregex(paramitems[2],"[0-9]+",/boolean) THEN BEGIN 
        ycol = fix(paramitems[2])                     
    ENDIF ELSE  BEGIN 
        ;; copy string:
        ycol = paramitems[2]                 
          
        ;; undefined x column -> default is 1
        IF ycol EQ "" THEN ycol = 2
    ENDELSE 

    ;; define error column to read (number or string)
    IF stregex(paramitems[4],"[0-9]+",/boolean) THEN BEGIN 
        errcol = fix(paramitems[4])                     
    ENDIF ELSE  BEGIN 
        ;; copy string:
        errcol = paramitems[4]                           
    ENDELSE 


    ;; define extension to use if given
    IF paramitems[6] NE "" THEN    $
      extension=fix(paramitems[6]) $
    ELSE                           $
      extension=1

    ;; ------------------------------------------------------------
    ;; READ DATA
    ;; ------------------------------------------------------------

    ;; read x:
    ftab_ext,filename,xcol,x,exten_no=extension

    ;; read y:
    ftab_ext,filename,ycol,y,exten_no=extension

    ;; read error if given:
    IF paramitems[3] NE "" THEN BEGIN 
        ftab_ext,filename,errcol,err,exten_no=extension
        (*env).groups[group].data[subgroup].err = PTR_NEW(err) 
    ENDIF 
        
      
    (*env).groups[group].data[subgroup].x = PTR_NEW(x) 
    (*env).groups[group].data[subgroup].y = PTR_NEW(y) 

    
    ;; allocate defined measure point array (default all defined):
    (*env).groups[group].data[subgroup].def = PTR_NEW(bytarr(n_elements(x),/nozero)) 
    (*(*env).groups[group].data[subgroup].def)[*]=1

    ;; allocate selected point array (none selected):
    (*env).groups[group].data[subgroup].selected = $
      PTR_NEW(bytarr(n_elements(x),/nozero)) 
    (*(*env).groups[group].data[subgroup].selected)[*]=0
    
    (*env).groups[group].data[subgroup].file = filename


    ;; ------------------------------------------------------------
    ;; STATUS REPORT
    ;; ------------------------------------------------------------
        
    cafereport,env,"  File:     "+filename 
    cafereport,env,"  Group:    "+strtrim(string(group),2) 
    cafereport,env,"  Subgroup: "+strtrim(string(subgroup),2) 
    cafereport,env,"  Datapoints: " +strtrim(string(n_elements(x)),2)
    
    
  RETURN  
END
