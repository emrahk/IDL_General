;+                                                                   
; Project     : SOLAR-B/EIS                                          
;                                                                    
; Name        : WIDGET_CONTROL2                                      
;                                                                    
; Purpose     : wrapper around WIDGET_CONTROL that check for valid ID
;                                                                    
; Category    : utility widgets                                      
;                                                                    
; Syntax      : IDL> widget_control2,id                              
;                                                                    
; Inputs      : ID = widget id                                       
;                                                                    
; Outputs     : None                                                 
;                                                                    
; Keywords    : all those of WIDGET_CONTROL                          
;                                                                    
; History     : 12-Jan-2006, Zarro (L-3Com/GSFC) - written           
;                                                                    
; Contact     : DZARRO@SOLAR.STANFORD.EDU                            
;-                                                                   
                                                                     
pro widget_control2,id,_ref_extra=extra                              
                                                                     
if (1-widget_valid(id)) then return                                  
                                                                     
error=0                                                              
catch,error                                                          
if error ne 0 then begin                                             
 catch,/cancel                                                       
 return                                                              
endif                                                                
                                                                     
widget_control,id,_extra=extra                                       
                                                                     
return & end                                                         
