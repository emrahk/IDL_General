; Project     : VSO
;
; Name        : VSO_INFO()
;
; Purpose     : Request info from VSO about available datasets
;
; Explanation : Prints a list of known values for a given VSO parameter
;
; Category    : Utility, Class2, VSO
;
; Syntax      : IDL> vso_info,/instrument
;
; Examples    : IDL> vso_info,/instrument,out=out
;               IDL> print_struct, out
;
;
; History     : Ver 0.1, 26-Sep-2006, J A Hourcle.  wrote the original (bad) version
;		Ver 1,   01-Apr-2009, J A Hourcle.  revisiting after a question from Dominic
;               Ver 2,   27-Aug-2010, J A Hourcle.  rewrite so it's both relatively intuitive & still useful
;                        the older (more complex) version might get revived under a different name
;                        23-Nov-2011, J A Hourcle.  actually doing the rewrite, not just document the plan
;
; Contact     : oneiros@grace.nascom.nasa.gov
;               http://virtualsolar.org/
;
; Input Keywords (flags):
;   SOURCE     : boolean : list the valid source names (synonym: SPACECRAFT, OBSERVATORY)
;   INSTRUMENT : boolean : list the valid instrument names (synonym: TELESCOPE)
;   DETECTOR   : boolean : list the valid detector names
;   PROVIDER   : boolean : list the valid data providers
;   PHYSOB     : boolean : list the valid physical observables (synonym: OBSERVABLE)
;   LAYOUT     : boolean : list the valid data layouts keywords (synonym: DATATYPE)
;   EXTENT     : boolean : list the valid extent keywords   
; Other Keywords (flags) :
;   QUIET      : boolean : Don't print output to screen (only useful with OUTPUT)
;   DEBUG      : boolean : Print XML SOAP messages
; Output Keywords :
;   OUTPUT     : struct[n] : an array of structures

function vso::GetInfoTagNames, $
	source=source, spacecraft=spacecraft, observatory=observatory, $
	instrument=instrument, telescope=telescope, detector=detector, $
	provider=provider, physobs=physobs, observable=observable, $
	layout=layout, datatype=datatype, extent=extent
        
       ; synonym processing ... yes, I could do this in the if() block, but this
       ; is better for when I do the other planned changes

	if ( keyword_set(layout)      ) then datatype=layout
	if ( keyword_set(telescope)   ) then instrument=telescope
        if ( keyword_set(observatory) ) then source=observatory
	if ( keyword_set(spacecraft)  ) then source=spacecraft
	if ( keyword_set(observable)  ) then physobs=observable
	
        names = obj_new( 'stack' )
        
       ; if ( keyword_set(available) ) then names->push, 'available'
       ; if ( keyword_set(contact)   ) then names->push, 'contact'
       ; if ( keyword_set(level)     ) then names->push, 'level'
       ; if ( keyword_set(time)      ) then names->push, 'time'
       ; if ( keyword_set(wave)      ) then names->push, 'wave'
 
        if ( keyword_set(datatype)   ) then names->push, '+datatype'
        if ( keyword_set(detector)   ) then names->push, '+detector'
        if ( keyword_set(instrument) ) then names->push, '+instrument'
        if ( keyword_set(physobs)    ) then names->push, '+physobs'
        if ( keyword_set(provider)   ) then names->push, '+provider'
        if ( keyword_set(source)     ) then names->push, '+source'
        if ( keyword_set(datatype)   ) then names->push, '+datatype'
        if ( keyword_set(extent)     ) then names->push, '+extent'


      ;  ; assume a useful default
      ;  if ( names->n_elements() eq 0 ) then begin
      ;          obj_destroy, names
      ;          return, [ '+source', '+instruments' ]
      ;  endif
	if ( names->n_elements() eq 0 ) then return, ''
        
        fields = names->contents()
        obj_destroy, names


        ; if ( keyword_set(xxx) ) then begin
        ;         ; now it's time to do bad things -- we're going to undefine all of the values passed
        ;         ; in that are also valid in vso->buildQuery()
                
        ;         if ( 0 ne is_string( filter     ) ) then a = temporary( filter     )
        ;         if ( 0 ne is_string( level      ) ) then a = temporary( level      )
        ;         if ( 0 ne is_string( time       ) ) then a = temporary( time       )
        ;         if ( 0 ne is_string( wave       ) ) then a = temporary( wave       )
        ;         if ( 0 ne is_string( datatype   ) ) then a = temporary( datatype   )
        ;         if ( 0 ne is_string( detector   ) ) then a = temporary( detector   )
        ;         if ( 0 ne is_string( instrument ) ) then a = temporary( instrument )
        ;         if ( 0 ne is_string( physobs    ) ) then a = temporary( physobs    )
        ;         if ( 0 ne is_string( provider   ) ) then a = temporary( provider   )
        ;         if ( 0 ne is_string( source     ) ) then a = temporary( source     )
        ; endif

        return, fields

end

function vso::GetInfo, query, fields, quiet=quiet, _extra=extra
;       dom = self->send('GetInfo', { GetInfoRequest, item: [ ptr_new(query), ptr_new(fields) ] }, /all, _extra=extra )
;        dom = self->send('GetInfo', [ ptr_new(query), ptr_new(fields) ], /all, _extra=extra)
;        parser=self->parser()
;        message, 'stopping in GetInfo'
;        return, ''

	path = strjoin( fields, '/', /single )
	url = 'http://sdac.virtualsolar.org/cgi-bin/registry_tab/' + path

	sock_list, url, result
	tab = string(9b)
	headers = strsplit( result[0], tab, /extract)
	

	create_struct, responsestruct, '', headers, strjoin(replicate('A',n_elements(headers)), ',')
	response = replicate( responsestruct, n_elements(result) - 1)
	; response = replicate( responsestruct, n_elements(result))

	; content = strsplit( result[1:*], tab, /extract)
	num_headers = n_elements(headers)-1;
	
	; yes, for loops are bad ... tell me some other way to do this, as strsplit won't work on arrays
	for i = 0, n_elements(response)-1 do begin
		content = strsplit(result[i+1], tab, /extract, /preserve)
		for j = 0, num_headers do begin
			response[i].(j) = content[j]
		endfor
	endfor

	; Dominic told me the better way, but the regex needs work.
	; parse=stregex(strcompress(result),'([^ ]+) (.+)',/extract,/sub)
	; for j = 0, num_headers do $
	; 	response[*].(j) = rotate( parse[j,1:*], 3)
	

	return, response
end

; I know, someone's going to yell at me for passing all of the terms in as _extra=_extra
; there's a good reason for it, though.  I actually have to pass the same parameters
; into two different routines, and this keeps me from having to change everything
; in three places, should the parameter list change.

; function vso_info, tstart, tend, _extra=extra
;         vso = obj_new('vso')
;         fields = vso->GetInfoTagNames( _extra=extra )
; 		
;         ; query  = vso->buildQuery( tstart, tend, _extra=extra, /GETINFO )
;         ; query  = vso->buildQuery( tstart, tend, _extra=extra )
; 	query = vso->buildQuery( '1900-01-01', '3000-01-01' );
;         temp = vso->GetInfo( query, fields, _extra=extra )
; 	obj_destroy, vso
; 	return, temp
; end

; convenience procedure to dump the contents.
pro vso_info, tstart, tend, output=output, quiet=quiet, help=help, _extra=extra
	if ( keyword_set(help) ) then begin
		vso_help, /info
		return
	endif

        vso = obj_new('vso')
	fields = vso->GetInfoTagNames( _extra=extra )
	if ( fields[0] eq '' ) then begin
		vso_info, /help
		obj_destroy, vso
		return
	endif
		
        ; query  = vso->buildQuery( tstart, tend, _extra=extra, /GETINFO )
        ; query  = vso->buildQuery( tstart, tend, _extra=extra )
	query = vso->buildQuery( '1900-01-01', '3000-01-01' );
        output = vso->GetInfo( query, fields, _extra=extra )
	obj_destroy, vso
        
        if ( keyword_set(quiet) ) then begin
        	; do nothing
        endif else if ( ~ n_elements(output) ) then begin
                print, 'No matching records returned'
        	endif else $
                	print_struct, output ;, /left
return & end
