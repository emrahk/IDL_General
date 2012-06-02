FUNCTION  cafeconvertparamtoabs, env, index
;+
; NAME:
;           cafeconvertparamtoabs
;
; PURPOSE:
;           convert parameter index of parameter to absolute index of parameter
;
; CATEGORY:
;           cafe
;
;
; SYNTAX:
;           index=cafeconvertparamtoabs( env, index)
;
; INPUTS:
;           index   - Integer number referring to a parameter in the
;                     3-dim parameter space of all parameters
;                     (paramnum/modelnum/group).
;
; OUTPUT:
;           Returns integer number. This is the index of the parameter
;           in a 1-dim list of all parameters which are well defined
;           (i.e. have proper parameter names).
;           The conversion is necessary to get the parameter index of
;           the list of a parameter whose index in the entire
;           parameter space is known only.
;           Returns -1 if no parameter defined.
;           
; SIDE EFFECTS:
;           none. 
;
;
; HISTORY:
;           $Id: cafeconvertparamtoabs.pro,v 1.6 2003/04/29 07:58:19 goehler Exp $
;
;
; $Log: cafeconvertparamtoabs.pro,v $
; Revision 1.6  2003/04/29 07:58:19  goehler
; change/fix: ignore groups with undefined data points or non-existing models
;             The determination of valid parameters is performed in new
;             function cafegetvalidparam()
;
; Revision 1.5  2003/03/03 11:18:33  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.3  2002/09/09 17:36:18  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; ------------------------------------------------------------
    ;; CONFIG
    ;; ------------------------------------------------------------

    ;; dimensions of parameter array (needed for array copying):
    param_dim = size((*env).parameter,/dimension)

    ;; ------------------------------------------------------------
    ;; CREATE INDEX OF ALL PARAMETERS:
    ;; ------------------------------------------------------------


    ;; find absolute index of index:
    ;; -> we already have the index within all parameters of those to
    ;;    link to. But we need the index of the parameter list of all
    ;;    defined parameters (which have nonzero parameter name).
    ;;    Therefore we must convert the index to the truncated
    ;;    parameter list. 

    ;; create index list of all parameters:
    indlist = indgen(param_dim[0],param_dim[1],param_dim[2])    

    ;; set all these indices which represent non-zero parameters at
    ;; the parameter number

    def_param_ind = cafegetvalidparam(env,selected=(*env).fitresult.selected)

    ;; check existence of any parameter:
    IF def_param_ind[0] EQ -1 THEN return, -1 

    ;; set index list at successive increasing numbers of absolute
    ;; parameter list:
    indlist[def_param_ind] = indgen(n_elements(def_param_ind))

    ;; create absolute parameter index of input index:
    param_index = indlist[index]

    return, param_index

END 
