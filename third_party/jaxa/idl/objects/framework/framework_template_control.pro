;---------------------------------------------------------------------------
; Document name: framework_template_control.pro
; Created by:  Andre Csillaghy, February 10, 2001
;
; Last Modified: Sat Feb 10 07:03:55 2001 (Administrator@TOURNESOL)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       FRAMEWORK_TEMPLATE_CONTROL
;
; PURPOSE: 
;       (*
;       THIS IS NOT RUNNING CODE!
;       This template is designed to help define the initialization
;       function that assign default values to control parameters.  
;       as used by frameworks. You can modify this template
;       as you wish and remove all comments that are between (* *). Replace
;       framework_template_control with the name of your
;       structure, which is usually the name of the object class
;       followed by "_control"
;       *)
;
; CATEGORY:
;       (* put here the category of the object class *)
; 
; CALLING SEQUENCE:
;       (* replace by the name of your class *)
;       var = Framework_Template_Control() 
;
; SEE ALSO:
;       (* 
;       Put here further references. For explanantions on how to
;       use framework templates, please check:
;       http://hessi.ssl.berkeley.edu/software/hessi_oo_concept.html
;       *)
;
; HISTORY:
;       Version 1, February 10, 2001, 
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;-
;


PRO Framework_Template_Control

;(*
; For each tag defined in the structure, you may (or may not) assign a
; default value
; *)

var = {framework_template_control}

var.tag1 =  ...
var.tag2 =  ...
...

RETURN, var

END


;---------------------------------------------------------------------------
; End of 'framework_template_control.pro'.
;---------------------------------------------------------------------------
