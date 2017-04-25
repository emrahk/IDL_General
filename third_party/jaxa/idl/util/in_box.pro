;+
; Project     : RHESSI
;                   
; Name        : IN_BOX
;               
; Purpose     : check if x,y coordinates are inside box 
;               
; Category    : utility
;               
; Syntax      : IDL> out=in_box(input, xaxis, yaxis)
;    
; Inputs      : INPUT = array of x,y values to check  [2,n]
;               XAXIS = 1-D array of xaxis values 
;               YAXIS = 1-D array of yaxis values
;               
; Outputs     : 1 - if all input points inside box defined by xaxis,yaxis
;               0 - if at least one point is outside
;
; History     : Kim Tolbert, 6-Nov-2009
;
; Modifications : 
;-      


function in_box, input, xaxis, yaxis

if ~exist(input) or ~exist(xaxis) or ~exist(yaxis) then return, 0b
if n_elements(input) lt 2 then return, 0b

return, in_range(input[0,*],xaxis) and in_range(input[1,*],yaxis)
end 