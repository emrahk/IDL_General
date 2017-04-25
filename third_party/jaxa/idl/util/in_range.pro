;+
; Project     : RHESSI
;
; Name        : IN_RANGE
;
; Purpose     : check if all input data values are with a selected data range
;				Original version is still valid. Returns a 1 if all INPUT are within limits of ARRAY
;				Using the WHERE_FLAG returns the indices or the values of INPUT with the limits of ARRAY.
;
; Category    : utility
;
; Syntax      : IDL> out=in_range(input,array)
;
; Inputs      : INPUT = array of values to check
;               ARRAY = target array of values
;
; Keywords    : WHERE_FLAG - if set, check each element of Input using Where
;				VALUES - if set, return where selected values from input, iff WHERE_FLAG
;				COMPLEMENT - where complement, doesn't change if VALUES selected
;				COUNT - Count argument from Where function. Number of valid elements in INPUT
;				INCLUSIVE - default is set so input equal minmax of array are included
; Outputs     : 1 - if at all input points inside array ranges
;               0 - if at least one point is outside
;				If WHERE_FLAG is set
;				Returns indices of INPUT within or equal to limits of ARRAY
;				Returns INPUT values if WHERE_FLAG and VALUES are set
;
; History     : 8-Oct-02, Zarro (LAC/GSFC) - written
;				7-Jul-2014, richard.schwartz@nasa.gov
;				Added WHERE_FLAG, VALUES, COMPLEMENT, COUNT, INCLUSIVE
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function in_range, input, array, $

	values = values,  $
	where_flag = where_flag, $
	complement = complement,  $
	count = count, $
	inclusive = inclusive

if (~exist(input)) or ( ~exist(array)) then return,0b
default, inclusive, 1

if ~keyword_set( where_flag ) then begin
	np=n_elements(input)
	amax=max(array,min=amin)
	imax=max(input,min=imin)

	out= inclusive ? (imin lt amin) or (imax gt amax) : (imin le amin) or (imax ge amax)

	out = 1b-out
	endif else begin
	zrange = minmax( array )
	test = inclusive ? ( input ge zrange[0] ) and ( input le zrange[1] ) : $
		( input gt zrange[0] ) and ( input lt zrange[1] )
	select = where( test, count, complement = complement)
	out = keyword_set( values ) && ( count < 1 ) ? input[ select ] : select

	endelse
return, out

end
