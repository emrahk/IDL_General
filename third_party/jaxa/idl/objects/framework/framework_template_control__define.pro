;---------------------------------------------------------------------------
; Document name: framework_template_control__define.pro
; Created by:  Andre Csillaghy, February 10, 2001
;
; Last Modified: Sat Feb 10 06:55:05 2001 (Administrator@TOURNESOL)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       FRAMEWORK_TEMPLATE_CONTROL__DEFINE
;
; PURPOSE: 
;       (*
;       THIS IS NOT RUNNING CODE!
;       This template is designed to help define control structures
;       that can be used by frameworks. You can modify this template
;       as you wish and remove all comments that are in (* *). Replace
;       framework_template_control with the name of your control
;       structure, which is usually the name of the object class
;       followed by "_control"
;       *)
;
; CATEGORY:
;       (* put here the category of the object class *)
; 
; CALLING SEQUENCE:
;       (* replace by the name of your class *)
;       var = {framework_template_control} 
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


PRO Framework_Template_Control__define

;(*
; In the structure definition, you should input as tags 
; all control parameters associated with the object
; *)

struct = {framework_template_control, $
          tag: ... $        
         }

END


;---------------------------------------------------------------------------
; End of 'framework_template_control__define.pro'.
;---------------------------------------------------------------------------
