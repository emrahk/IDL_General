PRO cafe_data_dat, env, filename, group, subgroup, $
                     param,                          $
                     help=help, shorthelp=shorthelp
;+
; NAME:
;           data_dat
;
; PURPOSE:
;           Read in data set from ascii file.
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
;               x | y | error. Number separators are non-number
;               characters, recommended are spaces or tabs. 
;               Comment lines which start with "#" will be skipped.
;
;
; PARAMETER:
;           (optional) parameters are ordered as follows:
;               - The column number for the X axis.
;                 Default is column 0. 
;               - The column number for the Y axis.
;                 Default is column 1. 
;               - The column number for the ERROR axis.
;                 Default is column 2. If no error column is given the
;                 error values will be omitted. 
;               - The number of header lines to skip. Default is 0. 
;               - The comment character. Default is "#".
;                 
;               All parameters are separated with ",". If one
;               parameter is not defined (empty string) the default
;               value is used. 
;               
; SIDE EFFECTS:
;           Loads ascii file data to group defined and free subgroup.
;
; EXAMPLE:
;
;               > data, test.dat:5, 
;               -> loads in data from ascii file test.dat (marked via
;               extension dat) to first free subgroup in group 5.
;
; HISTORY:
;           $Id: cafe_data_dat.pro,v 1.14 2003/03/17 14:11:27 goehler Exp $
;             
;-
;
; $Log: cafe_data_dat.pro,v $
; Revision 1.14  2003/03/17 14:11:27  goehler
; review/documentation updated.
;
; Revision 1.13  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.12  2002/09/20 09:52:46  goehler
; - data now handles more than one file
; - file type dat now faster
; - added 2-d data input types
;
; Revision 1.11  2002/09/10 13:24:31  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.10  2002/09/09 17:36:02  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="data_dat"

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
        print, "dat      - ascii data type"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------


    ;; read in chunks to increase speed.
    CHUNKSIZE=1000

    x   = dblarr(CHUNKSIZE)                  ; start arrays of columns to read
    y   = dblarr(CHUNKSIZE)
    err = dblarr(CHUNKSIZE)

    ;; number of datapoints
    pointno=0l
    
    x1=0.D0                     ; temporary read variables
    y1=0.D0
    err1=0.D0

    haserror=1                  ; flag to show whether error column given
    
    line=""                     ; line to read

    lineno=0l                   ; line number 


    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER:
    ;; ------------------------------------------------------------
    
    ;; split items:
    paramitems=stregex(param,"([0-9]*),([0-9]*)(,([0-9]+))?(,([0-9]+))?(,(.*))?", $
                       /extract,/subexpr)

    ;; define columns to read 
    xcol        = paramitems[1]
    ycol        = paramitems[2]
    errcol      = paramitems[4]
    headskip    = paramitems[6]
    commentchar = paramitems[8]


    ;; set default for undefined; convert columns to numbers:
    IF xcol  EQ "" THEN xcol = 0     ELSE xcol = fix(xcol)
    IF ycol  EQ "" THEN ycol = 1     ELSE ycol = fix(ycol)
    IF errcol  EQ "" THEN errcol = 2 ELSE errcol = fix(errcol)
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
        IF (xcol GE colnum)                $
          OR (ycol GE colnum)  THEN BEGIN
            cafereport,env,"ERROR: requested column does not exist. Skipped line "$
                      + strtrim(string(lineno),2)
            CONTINUE
        ENDIF 
         

        x1 = datapoint[xcol]
        y1 = datapoint[ycol]

        ;; set error if existing:x
        IF errcol LT colnum THEN  $
          err1 = datapoint[errcol]$
        ELSE                      $
          err1 = ""

        ;; check: valid number?
        IF (NOT stregex(x1,numexpr,/boolean)) $
           OR (NOT stregex(y1,numexpr,/boolean)) THEN BEGIN 
            cafereport,env,"Warning: invalid number found and skipped line: "$
                      + strtrim(string(lineno),2)
            CONTINUE
        ENDIF 

        ;; convert to double value:
        x1 = double(x1)
        y1 = double(y1)

        ;; append new values: 
        x[pointno]  =x1
        y[pointno]  =y1
        err[pointno]=double(err1)

        ;; set error existing flag
        haserror = stregex(err1,numexpr,/boolean) AND haserror


        ;; next data point
        pointno=pointno+1

        ;; we reached the array size -> add new chunk:
        IF pointno GE n_elements(x) THEN BEGIN
            x = [x,dblarr(CHUNKSIZE)]
            y = [y,dblarr(CHUNKSIZE)]
            err = [err,dblarr(CHUNKSIZE)]
        ENDIF 

    ENDWHILE

    ;; reading finished
    close, readlun 
    free_lun, readlun
    
    ;; remove not used elements:
    x = x[0:pointno-1]
    y = y[0:pointno-1]
    err = err[0:pointno-1]          
      
    ;; allocate data points:
    (*env).groups[group].data[subgroup].x = PTR_NEW(x) 
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
    cafereport,env,"  Datapoints: " +strtrim(string(n_elements(x)),2)
    
    
  RETURN  
END
