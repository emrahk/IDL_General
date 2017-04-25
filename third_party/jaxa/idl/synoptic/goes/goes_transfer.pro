;+                                                                                                           
; PROJECT: SDAC
;
; NAME:    GOES_TRANSFER
;                                                                                                            
; PURPOSE:                                                                                                   
; This procedure computes the transfer functions for the                                                     
; GOES XRS soft-xray spectrometers.                                                                          
;                                                                                                            
; CATEGORY:                                                                                                  
;  GOES, SPECTRAL ANALYSIS                                                                                   
;                                                                                                            
; CALLING SEQUENCE:                                                                                          
;  GOES_TRNFR, gshort_trnfr=gshort_trnfr, gshort_lambda=gshort_lambda, $                                     
;         glong_trnfr=glong_trnfr, glong_lambda=glong_lambda, $                                              
;         bar_gshort=bar_gshort, bar_glong=bar_glong                                                         
;                                                                                                            
; INPUTS:                                                                                                    
; None.                                                                                                      
;                                                                                                            
; KEYWORD PARAMETERS:                                                                                        
; GSHORT_TRNFR-   Transfer function for short wavelengths.                                                   
; GSHORT_LAMBDA-  Wavelengths for which the transfer fnc is defined.                                         
; GLONG_TRNFR-    Transfer function for long wavelengths.                                                    
; GLONG_LAMBDA-   Wavelengths for which the transfer fnc is defined.                                         
; BAR_GSHORT-     Wavelength averaged transfer function for short wavelength.                                
; BAR_GLONG-      Wavelength averaged transfer function for long wavelength.                                 
; GOES6-          If set, use GOES6 response.                                                                
; GOES7-          If set, use GOES7 response.                                                                
; GOES8-          If set, use GOES8 response.                                                                
; GOES9-          If set, use GOES9 response.                                                                
; GBAR_TABLE-     A structure which gives the Wavelength averaged transfer function for
;                 each GOES included for both channels
; DATE-           Time in ANYTIM format, used for GOES6 which changes the value
;                 of gbar.short on 28 June 1993
; OUTPUTS:                                                                                                   
; In keyword format, so you don't have to remember the output order.                                         
;                                                                                                            
; PROCEDURE:                                                                                                 
; The GOES-1 transfer functions defined on the wavelengths in                                                
; Donnelly et al 1977.                                                                                       
; Transfer functions are given in units of amp /watt meter^2                                                 
;                                                                                                            
; Transfer functions allow you to integrate over a solar spectrum to                                         
; get the response of the GOES detectors.  Units of GOES detectors already                                   
; has had its current in AMP converted to Watts/meter^2 using the                                            
; wavelength averaged transfer functions, here called BAR_GSHORT and                                         
; BAR_GLONG for the 0.5-4.0 and 1.0-8.0 Angstroms channels, respectively.                                    
; 
; COMMON BLOCKS:
;	GBAR_TABLE                                                            
;
; MODIFICATION HISTORY:                                                                                      
; VERSION 2, RAS SDAC/GSFC/HSTX 25-JULY-1996                                                                 
;       Mod. 08/12/96 by RCJ. Cleaned up documentation.                                                      
; Version 4, RAS, 20-nov-1996, goes6 & goes7                                                                 
; Version 5, richard.schwartz@gsfc.nasa.gov, 22-jul-1997, change in
;	transfer function on 28 June 1993 is for GOES 6 only!
;	Previously, it had changed all of the long wavelength transfer functions.
;	The date is not used in make_goes_resp so the interpolation tables were
;	not affected and GOES_TEM should still produce a correct result.
;	The change in transfer function value on this date is explicitly coded
;	into GOES_TEM.     
; Version 6, richard.schwartz@gsfc.nasa.gov, 3-aug-1998, added goes10                             
;-                                                                                                           
pro goes_transfer, gshort_trnfr=gshort_trnfr, $                                                              
gshort_lambda=gshort_lambda, $                                                                               
glong_trnfr=glong_trnfr, glong_lambda=glong_lambda, $                                                        
bar_gshort=bar_gshort, bar_glong=bar_glong, goes8=goes8, goes9=goes9,$                                       
goes6=goes6, goes7=goes7, goes10=goes10, gbar_table=gbar_table, date=date
                                                                                                             

gbar_table = replicate( {gbar, sat:0L, long:0.0, short:0.0}, 10)

gbar_table.sat  = indgen(10)+1
gbar_table.short=1e-5*[1.27,1.25,1.25,1.73,1.74,1.74,1.68,1.58,1.607, 1.631] ; A m^2 / Watt 
gbar_table.long =1e-6*[4.09,3.98,3.98,4.56,4.84,5.32,4.48,4.165,3.99, 3.824] ; A m^2 / Watt

if anytim( fcheck(date, 4.5722880e+08),/sec) lt 4.5722880e+08 then $
	gbar_table(5).long=4.43e-6

;Which version of GOES?                                                                                      
igoes = [keyword_set(goes6),keyword_set(goes7),keyword_set(goes8),keyword_set(goes9),keyword_set(goes10)]                        
igoes = (where(igoes))(0)+6                                                                                  
bar_gshort = gbar_table(where(gbar_table.sat eq igoes)).short 
bar_glong =  gbar_table(where(gbar_table.sat eq igoes)).long  
                                                                                                             
case igoes of                                                                                                
    5: begin                                                                                                 
        ;SHORT WAVELENGTH TRANSFER AND WAVELENGTH VECTORS 0.5-4 ANGSTROMS                                    
                                                                                                             
        ;Transfer function for short wavelength GOES ion chamber                                             
                                                                                                             
        ;Defined on these wavelengths                                                                        
        gshort_lambda=[0.1+0.1*findgen(35), 3.6+0.2*findgen(8), 5.5,6.0,7.0,8.0, $                           
        0.35839, .35841, 2.5869, 2.5871]                                                                     
                                                                                                             
        ;Transfer function for GOES-1                                                                        
        ;Units are amp watt-1 m2                                                                             
                                                                                                             
        gshort_trnfr= 1.e-6*[ .162, .621, 1.38, 1.01, 1.8, 2.87, 2.03, 5.61, 7.73, $                         
        9.24,  11.0, 12.9, 14.7, 16.3, 17.1, 18.0, 18.6, 18.9, 19.0, $                                       
        18.8, 18.5, 18.0, 17.1, 16.4,  15.1, 11.3, 11.2, 11.0, 10.7, 10.4, $                                 
        9.89, 9.36, 8.77, 8.14, 7.5, 6.68, 5.54, 4.38, 3.25, 2.39,1.70, 1.17, $                              
        .781, .233, .0539, .00131, .00001, 1.79, .789, 14.5, 11.3]                                           
                                                                                                             
                                                                                                             
        ;LONG WAVELENGTH TRANSFER AND WAVELENGTH VECTORS 1-8 ANGSTROMS                                       
                                                                                                             
        glong_lambda = [0.2+0.2*findgen(32), 6.8+0.4*findgen(14), 13.,14.,15.,16., $                         
        3.869, 3.871]                                                                                        
                                                                                                             
        glong_trnfr = 1.e-6*[.021, .140, .418, .887, 1.54, 2.34, 3.24, 4.11, $                               
        4.87, 5.49, 5.92, 6.18, 6.29, 6.31, 6.25, 6.14, 6.01, 5.85, 5.68, $                                  
        4.02, 4.12, 4.20, 4.24, 4.24, 4.19, 4.09, 3.96, 3.81, 3.62, 3.42, $                                  
        3.21, 2.99, 2.54, 2.07, 1.66, 1.31, .992, .732, .527, .368, .249, $                                  
        .163, .102, .0624, .0369, .0210, .00416, .00068, .00009, .00001, $                                   
        5.63, 3.92]                                                                                          
        bar_gshort = gbar_table(0).short 
        bar_glong =  gbar_table(0).long  
                                                                                                             
        end                                                                                                  
    8:begin                                                                                                  
        ;These are the transfer functions for GOES8!!                                                        
        gshort_lambda = [findgen(36)*.1+.1,3.8+findgen(14)*.2]                                               
        glong_lambda = [.2+findgen(32)*.2,6.8+.4*findgen(14), 13+findgen(4)]                                 
                                                                                                             
        gshort_trnfr =[1.19E-7, 5.90E-7,  $                                                                  
        1.27E-6, 9.47E-7, 1.71E-6, 2.74E-6, 4.04E-6, 5.54E-6, 7.19E-6, 8.94E-6,  $                           
        1.07E-5, 1.24E-5, 1.39E-5, 1.52E-5, 1.60E-5, 1.68E-5, 1.74E-5, 1.76E-5,  $                           
        1.76E-5, 1.74E-5, 1.70E-5, 1.66E-5, 1.57E-5, 1.51E-5, 1.38E-5, 1.03E-5,  $                           
        1.02E-5, 9.84E-6, 9.58E-6, 9.22E-6, 8.78E-6, 8.25E-6, 7.72E-6, 7.13E-6,  $                           
        6.57E-6, 5.92E-6, 4.76E-6, 3.69E-6, 2.76E-6, 2.00E-6, 1.38E-6, 9.28E-7,  $                           
        5.97E-7, 3.58E-7, 2.17E-7, 1.23E-7, 6.62E-8, 3.55E-8, 1.62E-8, 7.39E-9]                              
                                                                                                             
                                                                                                             
        glong_trnfr =[ 1.82E-8, 1.31E-7,  $                                                                  
        3.92E-7, 8.46E-7, 1.44E-6, 2.18E-6, 3.00E-6, 3.81E-6, 4.55E-6, 5.13E-6,  $                           
        5.55E-6, 5.80E-6, 5.92E-6, 5.94E-6, 5.89E-6, 5.80E-6, 5.69E-6, 5.55E-6,  $                           
        5.40E-6, 3.79E-6, 3.92E-6, 4.01E-6, 4.06E-6, 4.06E-6, 4.02E-6, 3.94E-6,  $                           
        3.84E-6, 3.70E-6, 3.54E-6, 3.36E-6, 3.16E-6, 2.97E-6, 2.56E-6, 2.15E-6,  $                           
        1.74E-6, 1.39E-6, 1.07E-6, 8.06E-7, 5.90E-7, 4.24E-7, 2.95E-7, 1.97E-7,  $                           
        1.29E-7, 8.16E-8, 4.99E-8, 2.96E-8, 6.55E-9, 1.19E-9, 1.8E-10, 1.9E-11]                              
        end                                                                                                  
                                                                                                             
    9:begin                                                                                                  
        ;These are the transfer functions for GOES9!!                                                        
        gshort_lambda = [findgen(36)*.1+.1,3.8+findgen(14)*.2]                                               
        glong_lambda = [.2+findgen(32)*.2,6.8+.4*findgen(14), 13+findgen(4)]                                 
                                                                                                             
        gshort_trnfr =[1.19E-7, 5.89E-7,   $                                                                 
        1.26E-6, 9.45E-7, 1.70E-6, 2.74E-6, 4.03E-6, 5.53E-6, 7.18E-6, 8.93E-6,   $                          
        1.07E-5, 1.24E-5, 1.39E-5, 1.52E-5, 1.60E-5, 1.68E-5, 1.74E-5, 1.76E-5,   $                          
        1.76E-5, 1.75E-5, 1.71E-5, 1.67E-5, 1.58E-5, 1.52E-5, 1.40E-5, 1.04E-5,   $                          
        1.03E-5, 9.98E-6, 9.73E-6, 9.38E-6, 8.95E-6, 8.43E-6, 7.91E-6, 7.32E-6,   $                          
        6.77E-6, 6.11E-6, 4.95E-6, 3.86E-6, 2.91E-6, 2.12E-6, 1.48E-6, 1.01E-6,   $                          
        6.55E-7, 3.98E-7, 2.44E-7, 1.41E-7, 7.67E-8, 4.18E-8, 1.95E-8, 9.06E-9]                              
                                                                                                             
                                                                                                             
        glong_trnfr =[1.74E-8, 1.24E-7,   $                                                                  
        3.73E-7, 8.05E-7, 1.37E-6, 2.07E-6, 2.85E-6, 3.63E-6, 4.33E-6, 4.89E-6,   $                          
        5.29E-6, 5.53E-6, 5.64E-6, 5.66E-6, 5.62E-6, 5.53E-6, 5.42E-6, 5.29E-6,   $                          
        5.15E-6, 3.62E-6, 3.74E-6, 3.83E-6, 3.88E-6, 3.88E-6, 3.85E-6, 3.78E-6,   $                          
        3.68E-6, 3.55E-6, 3.40E-6, 3.23E-6, 3.04E-6, 2.86E-6, 2.47E-6, 2.08E-6,   $                          
        1.69E-6, 1.35E-6, 1.04E-6, 7.91E-7, 5.82E-7, 4.20E-7, 2.94E-7, 1.98E-7,   $                          
        1.30E-7, 8.27E-8, 5.09E-8, 3.04E-8, 6.89E-9, 1.28E-9, 1.9E-10, 2.2E-11 ]                             
        end                                                                                                  
    10:begin                                                                                                  
        ;These are the transfer functions for GOES10!!                                                        
        gshort_lambda =[0.1+0.1*findgen(35),3.6+0.2*findgen(8),5.5,6.,7.,8., 0.35798,0.35801,2.5889,2.5901] 
        glong_lambda = [0.2+0.2*findgen(32),6.8+0.4*findgen(14),findgen(4)+13.,3.869,3.8701]                                    
                             
                                                                                                             
        gshort_trnfr =[ $            
	1.21e-7, 6.01e-7, 1.29e-6, 9.63e-7, 1.73e-6, 2.79e-6, 4.10e-6, 5.64e-6,	  $
	7.32e-6, 9.10e-6, 1.09e-5, 1.26e-5, 1.42e-5, 1.55e-5, 1.62e-5, 1.71e-5,   $
	1.77e-5, 1.79e-5, 1.79e-5, 1.70e-5, 1.73e-5, 1.70e-5, 1.60e-5, 1.55e-5,   $
	1.42e-5, 1.06e-5, 1.04e-5, 1.01e-5, 9.83e-6, 9.47e-6, 9.02e-6,   $
	8.49e-6, 7.96e-6, 7.36e-6, 6.79e-6, 6.12e-6, 4.94e-6, 3.85e-6, 2.85e-6,   $
	2.10e-6, 1.46e-6, 9.84e-7, 6.37e-7, 1.81e-7, 3.92e-8, 0.17e-10, 4.24e-12,  $
	1.62e-6, 7.30e-7, 1.37e-5, 1.06e-5]	
                                                     
                                                                                
                                                                                                             
        glong_trnfr =[1.76e-8, 1.26e-7, $
	3.77e-7, 8.14e-7, 1.38e-6, 2.09e-6, 2.88e-6, 3.67e-6, 4.37e-6, 4.93e-6,   $
	5.33e-6, 5.56e-6, 5.67e-6, 5.68e-6, 5.63e-6, 5.53e-6, 5.41e-6, 5.26e-6,   $
	5.11e-6, 3.58e-6, 3.68e-6, 3.76e-6, 3.78e-6, 3.77e-6, 3.71e-6, 3.62e-6,   $
	3.51e-6, 3.36e-6, 3.19e-6, 3.01e-6, 2.81e-6, 2.62e-6, 2.21e-6, 1.82e-6,   $
	1.45e-6, 1.12e-6, 8.38e-7, 6.13e-7, 4.34e-7, 3.00e-7, 2.01e-7, 1.38e-7,   $
	8.04e-8, 4.81e-8, 2.79e-8, 1.56e-8, 2.92e-9, 4.38e-10, 5.25e-11, 4.51e-12,$
	5.05e-6, 3.48e-6 ]
	                        
        end                                                                                                  
    6:begin                                                                                                  
        gshort_lambda = [0.1+0.1*findgen(35),3.6+0.2*findgen(15),0.35839,0.35841,2.5869,2.5871]              
        glong_lambda = [0.2+0.2*findgen(32),6.8+0.4*findgen(14),findgen(4)+13.,3.869,3.871]                  
                                                                                                             
        ;c  GOES6 G-bar long (gl6) was changed from 4.43e-6 to 5.316e-6 on 28 june 1983                      
        ;      data gl6,gs6,gl7,gs7/                                                                         
        ;     gbars= [5.316e-6,1.74e-5,4.48e-6,1.68e-5]                                                      
                                                                                                             
        gshort_trnfr = [1.25e-7,6.20e-7,$                                                                    
        1.33e-6,9.94e-7,1.79e-6,2.88e-6,4.24e-6,5.82e-6,7.56e-6,9.40e-6,$                                    
        1.13e-5,1.30e-5,1.46e-5,1.60e-5,1.68e-5,1.77e-5,1.83e-5,1.85e-5,$                                    
        1.86e-5,1.84e-5,1.80e-5,1.76e-5,1.67e-5,1.61e-5,1.47e-5,1.10e-5,$                                    
        1.09e-5,1.06e-5,1.03e-5,9.92e-6,9.47e-6,8.93e-6,8.39e-6,7.77e-6,$                                    
        7.18e-6,6.49e-6,5.27e-6,4.12e-6,3.11e-6,2.27e-6,1.59e-6,1.08e-6,$                                    
        7.07e-7,5.06e-7,3.06e-7,1.74e-7,1.10e-7,4.60e-8,3.70e-8,2.80e-8,$                                    
        0.97e-6*[1.79,.789,14.5,11.3]]                                                                       
                                                                                                             
        glong_trnfr =[ 1.99e-8,1.42e-7, $                                                                    
        4.27e-7,9.21e-7,1.57e-6,2.37e-6,3.26e-6,4.15e-6,4.95e-6,5.58e-6,$                                    
        6.04e-6,6.31e-6,6.43e-6,6.45e-6,6.40e-6,6.29e-6,6.16e-6,6.00e-6,$                                    
        5.83e-6,4.09e-6,4.22e-6,4.31e-6,4.35e-6,4.35e-6,4.30e-6,4.20e-6,$                                    
        4.08e-6,3.92e-6,3.74e-6,3.54e-6,3.32e-6,3.11e-6,2.65e-6,2.20e-6,$                                    
        1.77e-6,1.39e-6,1.06e-6,7.86e-7,5.67e-7,4.00e-7,2.74e-7,1.79e-7,$                                    
        1.15e-7,7.07e-8,4.22e-8,2.43e-8,4.99e-9,8.3e-10,1.1e-10,1.1e-11,$                                    
        5.63e-6, 3.92e-6]                                                                                    
                                                                                                             
                                                                                                             
        end                                                                                                  
    7:begin                                                                                                  
        gshort_lambda = [0.1+0.1*findgen(35),3.6+0.2*findgen(15),0.35839,0.35841,2.5869,2.5871]              
        glong_lambda = [0.2+0.2*findgen(32),6.8+0.4*findgen(14),findgen(4)+13.,3.869,3.871]                  
                                                                                                             
                                                                                                             
        gshort_trnfr= [1.23e-7,6.12e-7,$                                                                     
        1.31e-6,9.80e-7,1.77e-6,2.84e-6,4.18e-6,5.74e-6,7.46e-6,9.27e-6,$                                    
        1.11e-5,1.29e-5,1.45e-5,1.58e-5,1.66e-5,1.75e-5,1.81e-5,1.83e-5,$                                    
        1.83e-5,1.82e-5,1.78e-5,1.74e-5,1.64e-5,1.59e-5,1.46e-5,1.09e-5,$                                    
        1.08e-5,1.04e-5,1.02e-5,9.81e-6,9.37e-6,8.83e-6,8.30e-6,7.68e-6,$                                    
        7.11e-6,6.43e-6,5.22e-6,4.08e-6,3.09e-6,2.26e-6,1.58e-6,1.08e-6,$                                    
        7.04e-7,5.04e-7,3.06e-7,1.74e-7,1.10e-7,4.61e-8,3.70e-8,2.80e-8,$                                    
        0.95e-6*[1.79,.789,14.5,11.3]]                                                                       
                                                                                                             
        glong_trnfr= [2.09e-8,1.50e-7,$                                                                      
        4.48e-7,9.67e-7,1.64e-6,2.49e-6,3.42e-6,4.35e-6,5.19e-6,5.85e-6,$                                    
        6.32e-6,6.60e-6,6.72e-6,6.73e-6,6.67e-6,6.54e-6,6.39e-6,6.22e-6,$                                    
        6.03e-6,4.22e-6,4.34e-6,4.42e-6,4.45e-6,4.43e-6,4.35e-6,4.24e-6,$                                    
        4.10e-6,3.92e-6,3.72e-6,3.49e-6,3.25e-6,3.03e-6,2.54e-6,2.08e-6,$                                    
        1.64e-6,1.26e-6,9.33e-7,6.67e-7,4.73e-7,3.24e-7,2.14e-7,1.34e-7,$                                    
        8.32e-8,4.90e-8,2.79e-8,1.53e-8,2.72e-9,3.8e-10,4.3e-11,3.4e-11,$                                    
        [5.63e-6, 3.92e-6]*1.05]                                                                             
                                                                                                             
        end                                                                                                  
    endcase                                                                                                  
                                                                                                             
                                                                                                             
ord = sort(gshort_lambda)                                                                                    
gshort_lambda = gshort_lambda(ord)                                                                           
gshort_trnfr = gshort_trnfr(ord)                                                                             
                                                                                                             
                                                                                                             
ord = sort(glong_lambda)                                                                                     
glong_lambda = glong_lambda(ord)                                                                             
glong_trnfr = glong_trnfr(ord)                                                                               
                                                                                                             
                                                                                                             
                                                                                                             
end                                                                                                          
