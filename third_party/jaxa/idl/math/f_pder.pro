
;+
; PROJECT:
;       SDAC
; 	
; NAME: f_pder
;	
; PURPOSE:
;	This function returns the partial derivative of a function. 
;	
; CALLING SEQUENCE:  result = f_pder( funct=function_name, param=a, data=x, npar=n )
;	
; EXAMPLES:
;	pder(*,i)=f_pder(funct=function_name, par=a(0:*), data=x, n=i)
;	pder(*,i)= f_pder(funct=f_model, par=a, data=x, n=free(i))
;	pder(*,1) = f_pder( funct='f_gauss_intg',param=a,data=xin,npar=1)
;
; KEYWORD INPUTS:
;	funct - function name, string
;	parameters - A vector of parameter values required by the function.
;	data_points - input to the function, defined on points (M values)
;		or edges (2xM values low and high)
;	npar - differentiate with respect to  PARAMETERS(NPAR)
; OPTIONAL INPUTS:
;	
; OUTPUTS:
;	function returns the computed partial derivative at each data point
; OPTIONAL OUTPUTS:
;
; PROCEDURE:
;	uses call_function to generate functional values + and - .1% of parameter
;	then calculates this partial derivative arithmetically
; CALLS:
;	F_DIV
; COMMON BLOCKS:
;
; RESTRICTIONS:
;
; MODIFICATION HISTORY:
;	ras, 23-mar-95, added documentation	
; CONTACT:
;	richard.schwartz@gsfc.nasa.gov
;-
;
function f_pder, funct=function_name, parameters=a, data_points=x, npar=n
;calculate the partial derivative of FUNCTION wrt parameter A(NPAR) at every
;data_point in X

da1 = a
da2 = a
da1(n) = a(n)*(1.0+1.D-3) ;differentiate wrt parameter n
df1 = call_function( function_name, x, da1) 
da2(n) = a(n)*(1.0-1.D-3) ;differentiate wrt parameter n
df2 = call_function( function_name, x, da2) 


result = f_div( df1-df2, (da1(n)-da2(n))+ df1*0.0 )

return, result
end
