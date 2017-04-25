;+
; Project     : RHESSI
;
; Name        : PLOT_MAP_STRUCT
;
; Purpose     : Create structure used by MAP object to store plot properties
;
; Category    : structures
;
; Inputs      : None
;
; Outputs     : STRUCT = structure with appropriate plot property fields
;
; Keywords    : None
;
; History     : 27-Oct-2009, Zarro (ADNET) - written
;               30-Oct-2012, Zarro (ADNET) - added GSTYLE
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro plot_map_struct,struct
                   
red=bytarr(!d.table_size)                                                      
green=red                                                                      
blue=red                                                                       
struct={log_scale:0b,grid_spacing:0.,gstyle:1,limb_plot:0b,$
        red:red,green:green,blue:blue,has_colors:0b}
   
return & end                  
