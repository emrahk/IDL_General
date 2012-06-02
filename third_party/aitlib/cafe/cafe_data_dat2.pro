PRO cafe_data_dat2, env, filename, group, subgroup, $
                     param,                          $
                     help=help, shorthelp=shorthelp
;+
; NAME:
;           data_dat2
;
; PURPOSE:
;           Read in 2-d data set from ascii file.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           data
;
; DATA FORMAT:
;           Read the file as an ascii file containing the
;               data in columns (error column need not be given):
;               x1 | x2 | y | error. Number separators are non-number
;               characters, recommended are spaces or tabs. 
;               Comment lines which start with "#" will be skipped.
;
;
; PARAMETER:
;           (optional) parameters are ordered as follows:
;               - The column number for the X1 axis.
;                 Default is column 0. 
;               - The column number for the X2 axis.
;                 Default is column 1. 
;               - The column number for the Y axis.
;                 Default is column 2. 
;               - The column number for the ERROR axis.
;                 Default is column 3. If no error column is given the
;                 error values will be omitted. 
;               - The number of header lines to skip. Default is 0. 
;               - The comment character. Default is "#".
;                 
;               All parameters are separated with ";". If one
;               parameter is not defined (empty string) the default
;               value is used. 
;               
; SIDE EFFECTS:
;           Loads file data to group defined and free subgroup
;
; EXAMPLE:
;
;               > data, test.dat:5,dat2 
;               -> loads in data from ascii file test.dat (marked via
;               extension dat) to first free subgroup in group 5,
;               using 2-d reading function
;
; HISTORY:
;           $Id: cafe_data_dat2.pro,v 1.2 2003/03/03 11:18:22 goehler Exp $
;             
;-
;
; $Log: cafe_data_dat2.pro,v $
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
    name="data_dat2"

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
        print, "dat2     - 2-d ascii data type"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------


    ;; read in chunks to increase speed.
    CHUNKSIZE=1000

    x1   = dblarr(CHUNKSIZE)                  ; start arrays of columns to read
    x2   = dblarr(CHUNKSIZE)                  
    y   = dblarr(CHUNKSIZE)
    err = dblarr(CHUNKSIZE)

    ;; number of datapoints
    pointno=0l
    
    ;; temporary read variables
    x1_tmp=0.D0                     
    x2_tmp=0.D0
    y_tmp=0.D0
    err_tmp=0.D0

    haserror=1                  ; flag to show whether error column given
    
    line=""                     ; line to read

    lineno=0l                   ; line number 


    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER:
    ;; ------------------------------------------------------------
    
    ;; split items:
    paramitems=stregex(param,$
                       "([0-9]*),([0-9]*),([0-9]*)"+$       ; x1, x2, y
                       "(,([0-9]+))?(,([0-9]+))?(,(.*))?", $; error, header, comment
                       /extract,/subexpr)

    ;; define columns to read 
    x1col       = paramitems[1]
    x2col       = paramitems[2]
    ycol        = paramitems[3]
    errcol      = paramitems[5]
    headskip    = paramitems[7]
    commentchar = paramitems[9]


    ;; set default for undefined; convert columns to numbers:
    IF x1col  EQ "" THEN   x1col = 0     ELSE  x1col = fix(x1col)
    IF x2col  EQ "" THEN   x2col = 1     ELSE  x2col = fix(x2col)
    IF ycol  EQ "" THEN     ycol = 2     ELSE   ycol = fix(ycol)
    IF errcol  EQ "" THEN errcol = 3     ELSE errcol = fix(errcol)
    IF headskip EQ "" THEN headskip = 0 ELSE headskip = fix(headskip)
    IF commentchar EQ "" THEN commentchar = "#"


    ;; ------------------------------------------------------------
    ;; READ DATA
    ;; ------------------------------------------------------------
    
    
    ;; open file
    get_lun, readlun
    openr, readlun, filename


    ;; skip header lines
    FOR i=1, headskip  DO   readf,readlun, line

    ;; we count lines:
    lineno=headskip
    
    ;; read till end of file:
    WHILE NOT eof(readlun) DO  BEGIN 

        ;; increase line counter:
        lineno=lineno+1

        ;; read line
        readf,readlun, line
        
        ;; skip lines starting with a comment ("#")
        IF  stregex(line,"^ *"+commentchar,/boolean) THEN CONTINUE 
        
        ;; regular expression of valid number (neat to avoid any errors!)
        numexpr = "(^(\+|-)?[0-9]+(\.[0-9]*)?((e|E)(\+|-)?[0-9]+)?)$"
        
        ;; regular expression which contains any separators which
        ;; can't be numbers
        sepexpr = "[^0-9eE.+-]+"

        ;; split line into tokens of non-number parts"
        datapoint=strsplit(line, sepexpr, /extract,/regex)

        ;; check number of columns:
        colnum = n_elements(datapoint) 
        IF   (x1col GE colnum)                $
          OR (x2col GE colnum)                $
          OR (ycol GE colnum)  THEN BEGIN
            cafereport,env,"ERROR: requested column does not exist. Skipped line "$
                      + strtrim(string(lineno),2)
            CONTINUE
        ENDIF 
         

        x1_tmp = datapoint[x1col]
        x2_tmp = datapoint[x2col]
        y_tmp = datapoint[ycol]

        ;; set error if existing:x
        IF errcol LT colnum THEN  $
          err_tmp = datapoint[errcol]$
        ELSE                      $
          err_tmp = ""

        ;; check: valid number?
        IF   (NOT stregex(x1_tmp,numexpr,/boolean)) $
          OR (NOT stregex(x2_tmp,numexpr,/boolean)) $
          OR (NOT stregex(y_tmp,numexpr,/boolean)) THEN BEGIN 
            cafereport,env,"Warning: invalid number found and skipped line: "$
                      + strtrim(string(lineno),2)
            CONTINUE
        ENDIF 



        ;; append new values: 
        x1[pointno]  =double(x1_tmp)
        x2[pointno]  =double(x2_tmp)
        y[pointno]  =double(y_tmp)
        err[pointno]=double(err_tmp)

        ;; set error column existing flag
        haserror = stregex(err_tmp,numexpr,/boolean) AND haserror

        ;; next data point
        pointno=pointno+1

        ;; we reached the array size -> add new chunk:
        IF pointno GE n_elements(x1) THEN BEGIN
            x1 =  [x1,dblarr(CHUNKSIZE)]
            x2 =  [x2,dblarr(CHUNKSIZE)]
            y =   [y,dblarr(CHUNKSIZE)]
            err = [err,dblarr(CHUNKSIZE)]
        ENDIF 

    ENDWHILE

    ;; reading finished
    close, readlun 
    free_lun, readlun
    
    ;; remove not used elements:
    x1 = x1[0:pointno-1]
    x2 = x2[0:pointno-1]
    y = y[0:pointno-1]
    err = err[0:pointno-1]          
      
    ;; allocate data points:
    (*env).groups[group].data[subgroup].x = PTR_NEW([[x1],[x2]]) 
    (*env).groups[group].data[subgroup].y = PTR_NEW(y) 

    ;; allocate errors if given
    IF haserror THEN (*env).groups[group].data[subgroup].err = PTR_NEW(err) 


    ;; allocate defined measure point array (default all defined):
    (*env).groups[group].data[subgroup].def = PTR_NEW(bytarr(n_elements(y),/nozero)) 
    (*(*env).groups[group].data[subgroup].def)[*]=1

    ;; allocate selected point array (none selected):
    (*env).groups[group].data[subgroup].selected = PTR_NEW(bytarr(n_elements(y),/nozero)) 
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
