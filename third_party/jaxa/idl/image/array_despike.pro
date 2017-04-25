FUNCTION Array_Despike,array, $
	kernel=kernel, $
	sigma =sigma, $
	threshold=threshold,ITMAX=itmax,$
	scale = scale, $
	NOLOW = NOLOW, $
	verbose=verbose
;+
; NAME:
;	Array_Despike
;
; PURPOSE:
;	Remove isolated HIGH SIGNAL/NOISE elements from a 2D array, replacing
;	them with a local mean. This routine iterates until convergence or
;	a user-supplied maximum number. Only
;	points passing the S/N cut are affected.
;
; CALLING SEQUENCE:
;	Newarray = Array_Despike( array, kernel=kernel, $
;		 Sigma=Sigma, threshold=threshold, itmax=itmax, verbose=verbose

; INPUT ARGUMENT:
;	array = the array to despike. Units are counts because sqrt(mean) used
;		to determine number of standard deviations per spike
;
; OPTIONAL INPUT ARGUMENT:
;   kernel = local mean computed by convol( array, kernel, /normalize,/edge_truncate)
;		default kernel is the 8 cells surrounding a cell
;	SIGMA = the number of standard deviations by which a pixel must
;		exceed the local background for it to be replaced. DEFAULT = 5.0
;	ITMAX = the maximum number of iterations. DEFAULT = 20
;	SCALE = If any scaling is needed for cells, scale is used.
;		it should have the same size as array.  For example, if
;		array columns have different accumulation times (livetimes)
;		then this scaling can be applied here. Expectation values
;		should scale with array/scale.
;	NOLOW = If set, then negative spikes are not removed
;
;


; OUTPUT:
; 	Array_Despike returns the array, with spikes removed.
;
; REVISION HISTORY:
;	7-jul-2006, richard.schwartz@gsfc.nasa.gov
;	12-jul-2006, richard.schwartz@gsfc.nasa.gov, added scale array input
;		and fixed problem with totally isolated spikes, minimum
;		sigma is 1 to keep f_div from reporting 0 for diff/sigma
;	19-jul-2006, ras, Added removal of negative spikes and NOLOW keyword to disable this
;	new feature
;-

; Fill in default parameters:
on_error, 2
default, itmax,20
default, sigma, 8 ;

default, threshold, 6
a = array
if not same_data( size(a,/dim), size(scale,/dim)) then scale =  1.0
if not keyword_set(kernel) then $


	kernel= size(/n_dim, a) eq 2 ? [[1,1,1],[1,0,1],[1,1,1]] : [1,0,1]


iter = 0
test = 1

while test do begin

	if since_version('6.2') then $
		asm = n_elements(scale) eq 1 ? convol( a, kernel, /norm, /edge_tru) : $
		convol( f_div(a, scale), kernel, /norm, /edge_tru) * scale else $


		asm = (n_elements(scale) eq 1 ? convol( a, kernel, /edge_tru) : $
		convol( f_div(a, scale), kernel,  /edge_tru) * scale ) / total(kernel)


	diff = a - asm

	sigma_array = f_div( diff, sqrt(asm)>1.)

	repl = where( sigma_array gt sigma and a ge threshold, nreplace)
	if nreplace ge 1 then a[repl] = asm[repl]

	if keyword_set(verbose) then print, 'replace ',nreplace, ' points for iter = ', iter

	iter = iter + 1
	test = (iter gt itmax) or (nreplace eq 0) ? 0 : 1

endwhile
test = 1
iter = 0
if not keyword_set(NOLOW) THEN while test do begin

	if since_version('6.2') then $
		asm = n_elements(scale) eq 1 ? convol( a, kernel, /norm, /edge_tru) : $
		convol( f_div(a, scale), kernel, /norm, /edge_tru) * scale else $


		asm = (n_elements(scale) eq 1 ? convol( a, kernel, /edge_tru) : $
		convol( f_div(a, scale), kernel,  /edge_tru) * scale ) / total(kernel)


	diff = asm - a

	sigma_array = f_div( diff, sqrt(a)>1.)

	repl = where( sigma_array gt sigma and asm ge threshold, nreplace)

	if nreplace ge 1 then a[repl] = asm[repl]

	if keyword_set(verbose) then print, 'replace ',nreplace, ' points for iter = ', iter

	iter = iter + 1
	test = (iter gt itmax) or (nreplace eq 0) ? 0 : 1

endwhile

RETURN,A
END