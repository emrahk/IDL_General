;+
; Project     : VSO
;
; Name        : SOAP__DEFINE
;
; Purpose     : Define a SOAP class
;
; Explanation : Defines a SOAP class to connect to web services
;
; Category    : Utility, Class4, VSO
;
; Syntax      : IDL> a=obj_new('soap')
;
; Examples    : a=obj_new('soap')                   ; create a SOAP object
;               a->open(proxy, uri)                 ; connect to a SOAP service
;               results = a->send(method, args)     ; call a remote method
;
; History     : Version 0,   06-Oct-2005, J A Hourcle.  prototype written
;               Version 0.1, 12-Oct-2005, J A Hourcle.  returns XML-DOM
;               Version 0.2, 24-Oct-2005, J A Hourcle.  hack for arrays of strings/structs
;               Version 1,   08-Nov-2005, J A Hourcle.  documentation
;               Version 1.1, 10-Nov-2005, J A Hourcle.  passing SOAPAction
;                            12-Nov-2005, Zarro (L-3Com/GSFC)
;                             -added GET method
;                             -modified handling SOAPAction header
;               Version 1.2, 18-Nov-2005, Hourcle.  Fixed memory leaks
;               Version 1.3, 08-Dec-2005, Hourcle.  added HTTP timeout, /DEBUG mod
;               Version 2,   05-Jan-2010, Hourcle.  Using XMLSchema 2001, not 1999
;               Version 2.1  07-Jan-2010, Hourcle.  null changed to nil in xsi2001
;               Version 2.2, 28-Sep-2010, Hourcle.  Turn off garbage collection if IDL 8
;               Version 2.3, 8-Oct-2010, Zarro. Moved garbage collection disable to INIT and re-enabled it in
;               CLEANUP. This keeps it local.
;               Version 2.4, 22-Mar-2010, Zarro. Passed _extra to hset
;               to allow overriding user_agent.
;               Version 2.5, 10-Feb-2012, Hourcle.  Fixed
;               serialization of named arrays of structs 
;               Version 2.6, 17-Aug-2012, Zarro. Added USER_AGENT
;               environment variable string check.
;
;
; Limitations : This implementation only understands HTTP transports, currently.
;               IDL has no concept of 'null' other than a null pointer, so if you
;                need something serialize as xsi:null, assign ptr_new() to it
;               This was written for use against SOAP::Lite, and as such, is
;                not very robust.  (ie, RPC wrapped document/literal)
;               See vso__define.pro for an example in deserializing a known
;                return structure.
;
; Contact     : oneiros@grace.nascom.nasa.gov
;-
; a generic SOAP object, based on D.Zarro's HTTP object, to support VSO requests
; requires 'xmlparser' object, to handle temp file generation


;=========

function soap::init, _ref_extra=extra

; I know, this is overhead if someone overrides the 'send' or 'deserialize'
; methods, but well, I'll deal with that in the future, as it would mean
; I'd not get reports until later if something went wrong with loading the
; helper objects

    self.http = obj_new('http',_extra=extra)
    if ~obj_valid(self->getprop(/http))   then return, 0

; make sure HTTP times out if something goes wrong
    if since_version('6.0') then read_timeout=330 else read_timeout=0

;-- protect against pre-V 5.6

    if since_version('5.6') then begin
        self.parser = obj_new('xmlparser', _extra=extra)
        if ~obj_valid(self->getprop(/parser))  then return, 0
    endif else message,'Warning, IDL version 5.6 or better needed for XML parsing',/cont

;-- identify ourselves
    
    if getenv('USER_AGENT') eq '' then $
     user_agent='IDL/SOAP '+!version.release+' on '+!version.os+'/'+!version.arch
    self.http->hset,read_timeout=read_timeout,user_agent=user_agent,_extra=extra

;   hack to try to deal with IDL8's garbage collection
    if since_version('8.0') then x = call_function( 'heap_refcount', /disable )

    return, 1

end

;=========

pro soap::cleanup

    if obj_valid( self->http()   ) then obj_destroy, self->http()
    if obj_valid( self->parser() ) then obj_destroy, self->parser()

    if since_version('8.0') then x = call_function( 'heap_refcount', /enable )
 


return & end

;=========
;-- useful GET method

function soap::get,_ref_extra=extra,count=count

;-- check SELF first

    val=self->getprop(_extra=extra,count=count)
    if count ne 0 then return,val

;-- check HTTP helper object next

    return,(self->http())->getprop(_extra=extra,count=count)

end

;=========

function soap::http
    return, self->getprop(/http)
end

function soap::parser
    return, self->getprop(/parser)
end

;=========

; Input:
;   METHOD : a string, giving the name of the remote method
;   ARGS   : whatever arguments to send to the remote method
; Optional Flags:
;   DEBUG : print debugging info (XML message sent/received) to STDOUT
;   XML   : return the XML structure, without deserializing
; Output:
;   The deserialized structure (format depending on 'deserialize' call)

;-- handy to have POST be a separate method

function soap::post,method,args,debug=debug,_ref_extra=extra,err=err

; DMZ - prefer not to make extra headers properties since these can be
;       arbitrary. Instead pass them as keywords. Also /XML should probably
;       be the default for XML POST.

    http = self->http()
    extra_headers=self->header(method)

    if keyword_set(debug) then begin
        request = self->envelope(method, args)
        print, request
        print, "POSTING! : " + self->getprop(/proxy)
        http->post, self->getprop(/proxy), request, $
          response,info=extra_headers,/xml,_extra=extra,err=err
        print, response
        stop,'Stopping following POST'
    endif else $
        http->post, self->getprop(/proxy), self->envelope(method, args), $
          response,info=extra_headers,/xml,_extra=extra,err=err

    return,response
end

;=========

function soap::send, method, args,xml=xml,_ref_extra=extra,err=err

    response=self->post(method,args,_extra=extra,err=err)
    if keyword_set(xml) then return, response
    if is_string(err) or is_blank(response) then return,''
    return, self->deserialize(response, method=method,_extra=extra)

end

;=========

; this is not going to be useful for most folks, as there is no XPath support
; in IDL ... I'd try to deserialize into anonymous structures, but that's
; going to take time ... it'd almost be easier to write a WSDL to IDL program.

; see vso__define.pro for an example of overriding this.

; Input:
;   XMLSTRING : the XML string to deserialize
; Optional Input:
;   METHOD    : the name of the method, if this is an RPC/Encoded response
; Output:
;   An XML DOM Node (or Document, if no method supplied, or no Response found)

function soap::deserialize, xmlstring, method=method,_ref_extra=extra

    parser = self->parser()

    dom = parser->dom(xmlstring,_extra=extra)

    if n_elements(method) eq 0 then return, dom

    temp = parser->findelement( '(^|:)'+method[0]+'Response$', dom )

    if ( temp->n_elements() eq 1 ) then $
        response=temp->item(0) $
    else $
        response = parser->walktree( dom, ['Envelope','Body','.+Response'] )

; 2005/11/17 -- garbage collection -- JAH
    if obj_valid(temp) then obj_destroy, temp

    ; should we return the '<method>Response', or its children?
    ; problem -- the children will be placed in a node list, not as individual
    ; nodes.

    ; we return the first item ... like w/ SOAP::Lite's ->result() call.

;    if n_elements(response) eq 0 then return, self->dom2struct(dom) ; need better error handling.
    if n_elements(response) eq 0 then return, dom ; need better error handling.

;    return, self->dom2struct(response->getFirstChild())

    return, response->getFirstChild()

end


;========

; this exists for those people who would rather override this within
; their soap client, rather than needing to replace the parser object,
; as well.

function soap::dom2struct, node
    parser = self->parser()
    return, parser->dom2struct(node)
end

;========
;-- construct extra headers needed for SOAP

function soap::header, method

    if is_blank(method) then return,''

    uri=self->getprop(/uri)
    action='SOAPAction: "'+uri+'#'+method+'"'
    headers=['Accept: text/xml','Accept: multipart/*',action]
    return,headers

end

;========

; Input:
;   METHOD  : string ; the method being called
;   PAYLOAD : string ; the arguments to the method
; Output:
;   string ; SOAP message, with serialized arguments

function soap::envelope, method, payload

    return, '<?xml version="1.0" encoding="UTF-8"?>' $
        + '<SOAP-ENV:Envelope xmlns="' + self->getprop(/uri) + '"' $
        + ' xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"' $
        + ' xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"' $
        + ' SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"' $
        + ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' $
        + ' xmlns:xsd="http://www.w3.org/2001/XMLSchema">' $
        + ' <SOAP-ENV:Body>' $
        + self->serialize( method, payload )$
        + '</SOAP-ENV:Body></SOAP-ENV:Envelope>'

end

;========

; Attempt to connect to the SOAP proxy

; Input:
;   PROXY : The endpoint to connct to
;   URI   : The 'URI' for this SOAP service
; Output:
;   0 -> failure
;   1 -> success

function soap::open, proxy, uri

    self.proxy = proxy
    self.uri   = uri

    if ~stregex( proxy, '^http://', /boolean ) then begin
        message, 'SOAP object only supports HTTP proxies.  (please start proxy with "http://")'
        return, 0
    endif

    http = self->http()
    http->open, proxy

    return, 1
end

;========
;-- need a close routine

pro soap::close

    (self->http())->close

return & end

;=======

; Given an IDL struct, generate an XML complex element

; Input:
;   NAME : The name for the element
;   ITEM : The contents of the element (ie, the struct)
; Optional Input:
;   CLASS : The 'type' of the element
; Output :
;   string ; the structure serialized in XML

; Note -- 'CLASS' is not used in this code, but may be useful
;         for someone inheriting this object, who wishes to
;         override this function (passed in from serializeObject)

function soap::serializeStruct, name, item, class=class
    ReturnValue = '<' + name + '>'
    fields = tag_names( item )

    for i = 0, n_elements(fields)-1 do begin
        ReturnValue = ReturnValue + self->serialize( fields[i], item.(i) )
    endfor

    ReturnValue = ReturnValue + '</' + name + '>'
    return, ReturnValue
end

;========

; Given an IDL object, attempts to generate an XML complex element
; based on the object's underlying struct

; Input:
;   NAME : The name for the element
;   ITEM : The contents of the element (ie, the object)
; Output :
;   string ; the object serialized in XML

; Note -- you can add a 'serialize' method to your object, to
; make sure it gets serialized how you want

function soap::serializeObject, name, item

    catch, error
    if ( error ne 0 ) then begin
        catch, /cancel

        catch, error
        if ( error ne 0 ) then begin
            ; we can't serialize it ... blah
            catch, /cancel
            return, '<' + name + '/>'
        endif

        ; break encapsulation ... this only works if the class is a struct,
        ; and not some sort of lightweight object
        class = obj_class(item)
        ok = execute( 'obj = {' + class + '}' )
        return, self->serializeStruct(name, obj, class=class)
    endif

    ; we ask the object to serialize itself (so others can add the hook)
    return, item->serialize(name)

end

;========

; attempts to determine if an item should be serialized as an array

; Input:
;   ITEM : the item being tested
; Optional Input:
;   NAME : string ; the name of the object (see is_array_name method)
; Output:
;   0 -> not an array
;   1 -> is an array

function soap::is_array, item, name=name
    if ( n_elements(item) gt 1 ) then return, 1

; n_elements! can't tell the difference between a scalar, and a 1 element array.
; there's probably a better way to do this, but this is only my third day of
; IDL programming.

; If you try to cast an array as a string, you'll get 'Array[n_elements]'
; but then there's the odd chance that we have a string 'Array[1]'.
; hopefully, this won't generate too many false positives/false negatives.

; figures --  structures can't be cast as strings

    ; stupid test first ... for those element names that are always arrays
    if ~is_blank(name) then begin
        test = self->is_array_name( name )
    if ( test ne -1 ) then return, test
    endif


    catch, error
    if error ne 0 then begin
        return, 0
        catch, /cancel
    endif


    test = strtrim(item,2)

    return, ( test ne strtrim(item[0],2) ) and ( stregex( test, '^Array\[\d+\]$', /boolean ) )
end

;========

; you can override this, so that anything that comes through with a
; specific name is automatically converted to an RPC/Encoded array

; return :
; 1  : always an array
; 0  : never an array
; -1 : no idea

; see vso__define for an example of its use

function soap::is_array_name, name
    return, -1
end

;========

; convert IDL struct elements into XML element names.
; This is necessary because IDL struct elements names can't
; be IDL reserved words.

; To get around this, if you want something serialized with the
; name of a reserved word, prefix it with '_'.  prefix it with
; '__' to keep it from being serialized.

; Therefore, we can serialize:
;   { mystruct, start:0, _end:5000, __ignore:'blah' }
; as
;   <mystruct><start>0</start><end>5000</end></mystruct>

; Input :
;   NAME : name as used in IDL
; Output :
;   string ; name to be used in XML (or blank, if you should ignore it)
function soap::element_name, name

    if ( stregex( name, '^_', /boolean ) ) then  begin
        ; one _ to get around reserved names
        ; two __ to hide it
        if ( stregex( name, '^__', /boolean ) ) then return, ''
        name = strmid( name, 1 )
    endif

    return, name
end

;========

; Attempt to serialize an IDL variable as an XML string

; Input:
;   NAME : string ; the name of the IDL variable
;   ITEM : the variable to be serialized
; Output:
;   string ; the xml representation

function soap::serialize, name, item

    name = self->element_name(name)
    if is_blank(name) then return, ''

    if ( n_params() ne 2 ) then begin
        message, 'Usage: soap->serialize( name, variable )'
        return, ''
    endif

    if ( n_elements(item) eq 0 ) then $
        ; an array with no items
        return, '<' + name + ' xsi:nil="1"/>'

    if ( self->is_array(item) ) then begin
        ; an array
        type = name;
;
; TODO : fix this ... this is sloppy logic, but I'm trying to suppress an error.
;
        switch ( size( item, /tname ) ) of
            'POINTER':
            'OBJREF':
            'STRUCT':  begin
                    ;name='SOAP-ENC:Array'
                    type='xsd:anyType' ; type='xsd:ur-type'
                    break
                end
            else : type='xsd:string' ; <-- WARNING : really sloppy coding (works for perl, though)
        endswitch

        ReturnValue = '<'+name+' SOAP-ENC:arrayType="' + type + '[' + strtrim(n_elements(item),2) + ']" xsi:type="SOAP-ENC:Array">
        for i = 0, n_elements(item)-1 do $
            ReturnValue = ReturnValue + self->serialize( 'item', item[i] )
        ReturnValue = ReturnValue + '</'+name+'>'
        return, ReturnValue
    endif


    switch ( size( item, /tname ) ) of
        'POINTER':  if ( ptr_valid(item) ) then $
                        if (item ne ptr_new() ) then $
                            return, self->serialize( name, *item )
        ; UNDEF also handles null pointers
        'UNDEFINED':    return, '<' + name + ' xsi:nil="1"/>'

        'OBJREF':   begin
                        ; we attempt to call 'serialize' on the object.
                        catch, error
                        if ( error ne 0 ) then begin
                            ; we can't serialize it ... blah
                            catch, /cancel
                            return, self->serializeObject( name, item )
                        endif
                        ReturnValue = item->serialize(name)
                        return, ReturnValue
                    end

        'STRUCT':   return, self->serializeStruct( name, item )

; need to add handling for complex types, but well, VSO doesn't use them,
; so I'm skipping them for now --Joe

;       6: $ ; 'COMPLEX':
;       9: $ ; 'DCOMPLEX':

; there is no 'null' in idl that I can find other than a null string.
; this is going to make it impossible to send an empty string
        'STRING':   begin
                        if ( item eq '' ) then $
                            return, '<' + name + ' xsi:nil="1"/>'
                        return, '<' + name +'>' + item + '</' + name +'>'
                    end
        else: $ ; non-complex numbers
                    return, '<' + name +'>' + strtrim(string(item),2) + '</' + name +'>'
    endswitch

end

;========




;=========

; Define the underlying structure to represent the object

pro soap__define

    struct = { soap, INHERITS gen, proxy:'', uri:'', http:obj_new(), parser:obj_new()}

; DMZ - absorb user_agent into http

return & end
