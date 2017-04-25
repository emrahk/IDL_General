;+                                                                                 
; Project     : VSO                                                                
;                                                                                  
; Name        : byte2str                                                           
;                                                                                  
; Purpose     : convert byte array into string array                               
;                                                                                  
; Category    : utility string                                                     
;                                                                                  
; Syntax      : IDL> output=byte2str(input,newline=newline)                        
;                                                                                  
; Inputs      : BINPUT = input bytarr                                               
;                                                                                  
; Outputs     : SOUTPUT = output strarr with each new index corresponding to newline
;                                                                                  
; Keywords    : NEWLINE = byte value at which to break new line [def=13b]]         
;               SKIP = number of characters to SKIP when breaking line [def=1]
;                                                                                  
; History     : 12-Nov-2005, Zarro (L-3Com/GSFC) - written                         
;               22-Jan-2013, Zarro (ADNET)
;               - removed trailing whitespace
;                                                                                  
; Contact     : DZARRO@SOLAR.STANFORD.EDU                                          
;-                                                                                 
                                                                                   
function byte2str,binput,newline=newline,no_copy=no_copy,skip=skip                  
                                                                                   
if size(binput,/tname) ne 'BYTE' then begin                                         
 pr_syntax,'output=byte2str(input,newline=newline)'                                
 return,''                                                                         
endif                                                                              
                                                                                   
if is_number(newline) then bspace=byte(newline) else bspace=13b                    
if is_number(skip) then bskip=skip else bskip=1                                    
chk=where(binput eq bspace,count)                                                   

if count eq 0 then return,string(binput)                                                    
                                                                                   
np=n_elements(binput)                                                               
soutput=strarr(count+1)                                                             
                                                                                   
kstart=[0,chk+bskip]                                                               
kend=[chk-1,np-1]                                                                  
                                                     
for i=0,count do begin                                                             
 ks=kstart[i] & ke=kend[i]                                                         
 if (ke ge ks) and (ks lt np) and (ke lt np) then soutput[i]=string(binput[ks:ke])                                   
endfor                                                                             

if binput[np-1-bskip+1] eq newline then soutput=soutput[0:count-1]

return,soutput                                                                      
                                                                                   
end                                                                                
