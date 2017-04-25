;+
; Project     : VSO
;
; Name        : get_keyword_settings
;
; Purpose     : Retrieve keyword values from an enviromental variable
;
; Category    : Utility
;
; Explanation : Checks environment for a variable and processes the
;               value into a struct that can be joined with 'extra'
;               to override values or set defaults.  The string is
;               parsed using the following rules:
;               * spaces separate keyword=value pairs
;               * barewords are considered as a flag keyword (set to 1)
;               * arrays of values are comma separated
;
; Syntax      : IDL> settings = get_keyword_settings( name )
;
; Inputs      : NAME  = STRING : name of environmental variable to read
;
; Output      : an anonymous structure
;
; Examples    : IDL> set_logenv, 'vso_defaults', 'key1 key2=value key3=val1,val2'
;               IDL> defaults_struct = get_keyword_settings( 'vso_defaults' )
;
;               pro procedure_name, _extra=extra
;                  defaults_struct = get_keyword_defaults( 'vso_defaults' )
;                  override_struct = get_keyword_defaults( 'vso_override' )
;                  extra = join_struct( extra, defaults_struct )
;                  extra = join_struct( override_struct, extra )
;                  call_procedure, _extra=extra
;               return & end
;
; History     : Written, 19-Jul-2010, J.A.Hourcle
;               v1.0.1,  20-Jul-2010, Hourcle -- now memoizing the structure
;
; Contact     : oneiros@grace.nascom.nasa.gov
;
; Limitations : All values are returned as a string.
;               This may change in the future
;-

function get_keyword_settings, name
	string = get_logenv( name )
	if ( is_blank(string) ) then $
		return, create_struct( '_blank', 1 )

	; memoizing : basically, we stash the created structure
	; and the string in a common block -- if the string
	; hasn't changed, there's no reason to re-parse it.

	mem_name = '_memoize_'+name;
	common mem_name, cached_string, cached_struct
	if ~ is_blank(cached_string) then $
		if cached_string eq string then $
			return, cached_struct

	pairs  = strsplit( string, ' ', /extract )

	num_pairs = size(pairs,/n_elements);
	if ( ~ num_pairs ) then $
		return, create_struct( '_blank', 1 )

	for i = 0, num_pairs-1 do begin
		key   = pairs[i]
		value = 1
		if stregex( pairs[i], '([^=]+)=(.*)', /boolean ) then begin
			match = stregex( pairs[i], '([^=]+)=(.*)', /extract, /subexpr )
			key   = match[1]
			value = match[2]
		endif
		if stregex( value, ',', /boolean ) then $
			value = strsplit ( value, ',', /extract )
		if stregex( key, '^/', /boolean ) then $
			key = strmid( key, 1 )

		return_struct = join_struct( return_struct, create_struct( key, value ) )
	endfor

	cached_struct = return_struct
	cached_string = string

	return, return_struct
end

