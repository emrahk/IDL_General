PRO cafe_rebin, env,  param, subgroup, group,     $ 
                gaps=gaps, devn=devn, quiet=quiet,$
                nogaps=nogaps,                    $
                help=help, shorthelp=shorthelp
;+
; NAME:
;           rebin
;
; PURPOSE:
;           Rebins data set in group/subgroup
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           rebin, key=param[,subgroup][, group][,/gaps][,/devn][,/quiet]
;
; INPUTS:
;           subgroup - Defines the subgroup to rebin. This can be
;                      either the subgroup number, a list of subgroups
;                      within brackets ([]) or the file name of
;                      the subgroup. Wildcards ("*") for file names are
;                      allowed to rebin more than one subgroup.
;
;           group    - (optional) Define the data group to remove the
;                      data from. Default is the primary group 0. Must
;                      be in range [0..29].
;
;           key      - How to bin. This may be either:
;                        - DT : binning should be evenly with this
;                               delta x.
;                        - COMB: combine this number of datapoints
;                                assuming evenly spaced input (first two
;                                data points are taken as original delta x)
;                        - MIN: each bin should at least contain this
;                               number. !Still not working!
;           param    - Defines the value according key given.
;           
; OPTIONS:
;           gaps     - Skip bins without data (gaps) 
;           devn     - Estimate error by standard deviation instead of
;                      error propagation while binning.
;           quiet    - Do not report problems. 
;
;           nogaps   - Skip data gaps when no data defined in
;                      time interval. It is assumed that
;                      the periodicity is defined by x[1] - x[0].                      
;                      
;
; SIDE EFFECTS:
;           Changes data representation irrevocably.
;
; DESCRIPTION:
;           X/Y table entries are combined to be
;           - evenly distributed
;             or
;           - contain at least minimum of data.
;
; EXAMPLE:
;
;               > rebin, test.dat, MIN=25
;               -> sets data at binning while each data point reaches
;                  at least Y >= 25.
;
; HISTORY:
;           $Id: cafe_rebin.pro,v 1.3 2003/04/16 17:11:18 goehler Exp $
;             
;-
;
; $Log: cafe_rebin.pro,v $
; Revision 1.3  2003/04/16 17:11:18  goehler
; added nobin option to deal with datasets containing lot of empty space
;
; Revision 1.2  2003/04/16 15:47:17  goehler
; added COMB keyword/fix of defined array
;
; Revision 1.1  2003/04/16 15:01:32  goehler
; rebin package calling rebinlc for timing. alpha state
;
;
;


    ;; command name of this source (needed for automatic help)
    name="rebin"

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
      cafereport,env, "rebin   - evenly distribute data sets."
      return
  ENDIF



  ;; ------------------------------------------------------------
  ;; SETUP
  ;; ------------------------------------------------------------

  ;; define default group
  IF n_elements(group) EQ 0 THEN group = (*env).def_grp

  ;; check boundary:
  IF (group GT n_elements((*env).groups[*])-1) OR (group LT 0)  THEN BEGIN 
      cafereport,env, "Error: invalid group number"
      return
  ENDIF


  ;; define default subgroup(s) -> all subgroups
  IF n_elements(subgroup) EQ 0 THEN $
    subgroup = indgen(n_elements((*env).groups[group].data))


  ;; subgroup given as string -> look for matching file:
  IF ((SIZE(subgroup))[0] EQ 0 ) AND ((SIZE(subgroup))[1] EQ 7) THEN BEGIN  
      
      ;; look for subgroups containing this string:
      subgroup = where(strmatch((*env).groups[group].data[*].file,subgroup))

      IF subgroup[0] EQ  -1 THEN BEGIN 
          cafereport,env, "Error: Subgroup file not found"
          return
      ENDIF
        
  ENDIF         
    
  ;; check boundary:
  IF (where(subgroup GE n_elements((*env).groups[group].data) $
            OR (subgroup LT 0)))[0] NE -1  THEN BEGIN 
      cafereport,env, "Error: invalid subgroup(s)"
      return
  ENDIF


  ;; gap tolerance:
  IF n_elements(gaptol) EQ 0 THEN BEGIN ; how much the gap binning may vary
      gaptol = 0.1              ; default: 10%       
  ENDIF 
  gaptol = gaptol+1.            ; add 100% for binning

  ;; ------------------------------------------------------------
  ;; SETUP BINNING PARAMETER:
  ;; ------------------------------------------------------------

  paramitems=strsplit(param,"=",/extract)

  IF n_elements(paramitems) LT 2 THEN BEGIN 
      cafereport,env, "Error: invalid binning parameter"
      return
  ENDIF

  IF strupcase(paramitems[0]) EQ "DT" THEN BEGIN 
      dt = double(paramitems[1])
  ENDIF 


  IF strupcase(paramitems[0]) EQ "MIN" THEN BEGIN 
      cafereport,env,"Error: still not supported!"
      return
;      minnum = double(paramitems[1])
  ENDIF 

  ;; ------------------------------------------------------------
  ;; PERFORM BINNING:
  ;; ------------------------------------------------------------


  ;; put this array in heap:
  FOR i = 0, n_elements(subgroup)-1 DO BEGIN

      ;; select subgroup:
      sg = subgroup[i]

      ;; check data set existence:
      IF NOT PTR_VALID((*env).groups[group].data[sg].def)  THEN CONTINUE      

      ;; extract data sets:
      x = (*(*env).groups[group].data[i].x)
      y = (*(*env).groups[group].data[i].y)
      err = (*(*env).groups[group].data[i].err)

      ;; default: no gaps -> start from index 0
      ;; gap_index stores the indices where a gap starts(!)
      ;; for convenience a gap start is added immediate after the last data
      ;; point 


      gap_index=[0]

      ;; check gaps -> compute difference, take binning into account
      IF KEYWORD_SET(nogaps ) THEN BEGIN   
          binning   = (x[1]-x[0]) ; x binning 

          ;; define x gaps:
          ;; -> where x is not sequence of binning of time distance:
          gap_index   = where((x-[-!values.d_infinity,x]) GE binning*gaptol)      
      ENDIF 

      ;; combine data points -> use first delta:
      IF strupcase(paramitems[0]) EQ "COMB" THEN BEGIN 
          dt = double(paramitems[1])*(x[1]-x[0])
      ENDIF 

      ;; add gap at last element (plus 1)
      gap_index=[gap_index,n_elements(x)]

      ;; dummy first variables:
      xtotal=0.D0
      ytotal=0.D0
      errtotal=0.D0

      ;; actually perform binning:
      FOR g=0, n_elements(gap_index)-2 DO BEGIN 

          ;; bin it:
          rebinlc, x[gap_index[g]:gap_index[g+1]-1],$
                   y[gap_index[g]:gap_index[g+1]-1],$
                   xout,yout,                       $ 
               dt=dt, minnum=minnum,                $
               raterr=y[gap_index[g]:gap_index[g+1]-1], $
               devn=devn, ern=errout

          ;; combine:
          xtotal=[xtotal,xout]
          ytotal=[ytotal,yout]
          errtotal=[errtotal,errout]
      ENDFOR 

      ;; remove first dummy element:
      xtotal=xtotal[1:*]
      ytotal=ytotal[1:*]
      errtotal=errtotal[1:*]


      ;; free former data:
      PTR_FREE, (*env).groups[group].data[sg].x
      PTR_FREE, (*env).groups[group].data[sg].y 
      PTR_FREE, (*env).groups[group].data[sg].err 
      PTR_FREE, (*env).groups[group].data[sg].def        

      ;; realloc new data:
      (*env).groups[group].data[sg].x = PTR_NEW(xtotal)
      (*env).groups[group].data[sg].y = PTR_NEW(ytotal)
      (*env).groups[group].data[sg].err = PTR_NEW(errtotal)
      (*env).groups[group].data[sg].def = $
        PTR_NEW(make_array(n_elements(ytotal),value=1,/byte))
  ENDFOR 


  RETURN  
END

