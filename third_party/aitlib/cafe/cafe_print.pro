PRO cafe_print, env, range, subgroup, group, $
                  help=help, shorthelp=shorthelp
;+
; NAME:
;           print
;
; PURPOSE:
;           prints out data list of single group
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           print [,range][,subgroup][,group]
;
; INPUTS:
;           range    - (optional) Define the range to print. This can
;                      be either:
;                       - Data point range, denoted by the data point
;                         number:  <n1>[-<n2>], while <n1>, <n2> are
;                         positive numbers. Data point numbers start
;                         from zero. 
;                       - X value range, denoted by float point numbers:
;                         <val1>-<val2>, while <val1>, <val2>
;                         represents X values defining the interval to
;                         ignore. Open intervals can be represented
;                         with a * instead of the value. 
;                       - The "selected" identifier: This will take all
;                         data points which are marked as selected (with
;                         wplot/select command).
;                       - Boolean expressions with X/Y values. All
;                         values for which this expression is true are
;                         printed.
;                      Default is the entire range (="*").
;                      
;           subgroup - (optional) The dataset to print. This can be
;                      either the dataset name or its subgroup
;                      number. Subgroup numbers can be given as an
;                      array of numbers ([]) separated with ",";
;                      wildcards ("*")in names are possible. 
;
;           group    - (optional) Define the data group to show.
;                      Default is the current group set with
;                      "chgrp". Must be in range [0..29]. 
;
; SIDE EFFECTS:
;           None. 
;
; EXAMPLE:
;
;               > data, "test.dat:2"
;               > print, *,*,2
;                 -> X   Y   ERROR
;                    3   5   0.2
;                    4   7   0.15
;                    6   9   0.3
;                    ... all data of all subgroups in group 2.
;
; HISTORY:
;           $Id: cafe_print.pro,v 1.10 2003/03/17 14:11:34 goehler Exp $
;-
;
; $Log: cafe_print.pro,v $
; Revision 1.10  2003/03/17 14:11:34  goehler
; review/documentation updated.
;
; Revision 1.9  2003/03/03 11:18:24  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.8  2003/02/18 16:45:30  goehler
; removed debugging statement
;
; Revision 1.7  2003/02/11 07:32:37  goehler
; added multi-dimension print facility
;
; Revision 1.6  2002/09/09 17:36:09  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="print"

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
    print, "print    - prints out data of single group"
    return
  ENDIF



    ;; ------------------------------------------------------------
    ;; SET GROUP/SUBGROUP 
    ;; ------------------------------------------------------------


    ;; define default group
    IF n_elements(group) EQ 0 THEN group = (*env).def_grp

    ;; check boundary:
    IF (group GE n_elements((*env).groups)) OR (group LT 0)  THEN BEGIN 
        cafereport,env, "Error: invalid group number"
        return
    ENDIF


    ;; define default subgroup -> first valid subgroup
    IF n_elements(subgroup) EQ 0 THEN BEGIN 
        subgroup = where((*env).groups[group].data[*].file NE "")
        subgroup = subgroup[0]
    ENDIF 


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

    ;; ------------------------------------------------------------
    ;; RANGE SETUP
    ;; ------------------------------------------------------------

    IF n_elements(range) EQ 0 THEN range = "*"

    range=strtrim(string(range),2)



  ;; ------------------------------------------------------------
  ;; SHOW DATA
  ;; ------------------------------------------------------------

  ;; list all subgroups:
  FOR i = 0, n_elements(subgroup)-1 DO BEGIN 
      
      ;; select subgroup:
      sg = subgroup[i]
      
      IF NOT PTR_VALID((*env).groups[group].data[sg].y)  THEN CONTINUE 
      
      ; number of dimensions in x:
      dimnum = n_elements((*(*env).groups[group].data[sg].x)[0,*])
      

      ;; create x-string if number not zero:
      IF dimnum GT 1 THEN begin
          xtitlestr = ""
          xtitleformatstr= ""
          xformatstr= ""
          FOR j = 1,dimnum DO BEGIN 
              xtitlestr = [xtitlestr, "X"+strtrim(string(j),2)]
              xtitleformatstr=xtitleformatstr+",A15"
              xformatstr = xformatstr + (*env).format.xformat +","
          ENDFOR 
          xtitlestr = xtitlestr[1:dimnum]
      ENDIF ELSE BEGIN 
          xtitlestr = "X"
          xtitleformatstr= ",A15"
          xformatstr = (*env).format.xformat + ","
      ENDELSE


      cafereport,env, string("File: ",(*env).groups[group].data[sg].file,format="(A11,A10)")
      cafereport,env, string("Group:", group, " Subgroup:", sg,format="(A10,I2,A10,I2)")
      cafereport,env, string("Num", xtitlestr,"Y","ERROR","DEFINED",$
                             format="(A5"+xtitleformatstr+",A15,A15, A10)")

      ;; define format to use:
      format = "("+xformatstr         $
              +    (*env).format.yformat $
              +","+(*env).format.errformat + ")"

      ;; index of selected range
      index = caferange(env,range,group,sg)

      IF index[0] EQ  -1 THEN CONTINUE 


      FOR j = 0, n_elements(index)-1 DO BEGIN 

          ;; number selected:
          datnum = index[j]

          IF ptr_valid((*env).groups[group].data[sg].err) THEN $
            err = (*(*env).groups[group].data[sg].err)[datnum] ELSE $
            err = 0.D0
          
          cafereport,env, string(datnum,                                     $
                                   (*(*env).groups[group].data[sg].x)[datnum,*],  $
                                   (*(*env).groups[group].data[sg].y)[datnum],  $ 
                                   err,                                      $
                                   (*(*env).groups[group].data[sg].def)[datnum],$
                                   format="(I5,"+format+",I5)")
      ENDFOR 
  ENDFOR

  RETURN  
END

