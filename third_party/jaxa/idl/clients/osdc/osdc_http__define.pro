;+
; Project     : Hinode Science Data Centre Europe (Oslo SDC)
;                   
; Name        : OSDC_HTTP__DEFINE
;               
; Purpose     : Specialized subclass of HTTP class, for OSDC objects
;               
; Explanation : Overrides the READF method of HTTP to handle structured data
;
; Use         : connection = obj_new('osdc_http',server=server)
;
; Inputs      : None required
; 
; Opt. Inputs : SERVER : Name of server
;
; Outputs     : READF method outputs structure array with OSDC results
;               
; Opt. Outputs: OUTPUT is optional but dropping it is meaningless
;               
; Keywords    : SERVER='sdc.uio.no' or other archive server
;
; Calls       : HTTP__DEFINE, DEFAULT
;
; Common      : None
;               
; Restrictions: Works best if server response is meaningful
;               
; Side effects: Submits search query to the server
;               
; Categories  : Archive interface, object, web client
;               
; Prev. Hist. : None
;
; Written     : SVH Haugan, UiO, 23 January 2007
;               
; Modified    : Relevant log entries below:
;
; $Log: osdc_http__define.pro,v $
; Revision 1.14  2009/09/23 10:15:01  steinhh
; Changed ::READF to ::PARSE, now letting unadulterated HTTP::READF do the
; reading and just parsing the (presumed ok) output. Cleaned log.
;
; Revision 1.12  2007/12/19 13:10:46  steinhh
; Closing on error (HTTP/1.0)
;
; Revision 1.11  2007/10/08 12:18:52  steinhh
; Added osdc_nmatch status and ::nmatch()
;
; Revision 1.10  2007/08/28 14:06:15  steinhh
; Etter sommerferien
;
; Revision 1.9  2007/04/03 12:34:12  steinhh
; Printing out N files matching, M files to be received
;
; Revision 1.7  2007/03/18 12:53:31  steinhh
; Promoted loop vars to 0L, included error_state in debug output
;
; Revision 1.6  2007/03/05 09:24:14  steinhh
; Just checking in...
;
; Version     : $Revision: 1.14 $$Date: 2009/09/23 10:15:01 $
;-

FUNCTION osdc_http::init,server=server
  default,server,'sdc.uio.no'
  
  ;; The http object does *not* handle chunked encoding correctly (correct
  ;; algorithm at the end of this file) as all HTTP 1.1 clients must, so we
  ;; downgrade to 1.0, which is just fine.
  
  res = self->http::init(protocol='1.0')
  IF NOT res THEN return,res
  
  self.osdc_nmatch = -1
  
  ;; Setting the port here is effectively ignored, seems http::parse_url has a
  ;; hardwired short-circuit of the port number to 80. So, to avoid anyone
  ;; else from having to figure that out, we have no keyword for that.  Let's
  ;; just bear over with this for now, since osdc is at port 80.
  
  self->hset,server=server
  return,1
END

PRO osdc_http::parse,output_in
  output = ''                   ; Default null result
  
  t = ''                        ; Always has last line read
  headers = ''                  ; Accumulate all headers
  ok = 1                        ; Getting here means we got a code 200 response
  
  catch,err
  
  IF err NE 0 OR NOT ok THEN BEGIN
     catch,/cancel
     ok = 0
  END
  
  IF NOT ok THEN BEGIN
     print,"","A problem seems to have occurred, headers and !error_state " + $
           "follow",headers,"",$
           "Last input line line reads: '"+t+"'","",format='(a)'
     help,!error_state,/str
     message,"Stopping"
  END

  nret = (nmatch = 0L)           ; No. of returned files vs no. of matches
  line = 0L                         ; Line number we're on
  t =  output_in[line++]            ; Get first line
  reads,t,nret,nmatch
  print,trim(nmatch)+" file(s) match, "+trim(nret)+" lines to be received"
  self.osdc_nmatch = nmatch
  IF nret EQ 0 THEN BEGIN
     self->close
     delvarx,output_in          ; No results
     return                     ; None found
  END
  
  ;; Files have been found - generate suitable structure for results without
  ;; using EXECUTE ('cause that won't work with IDL VM).  Details are given on
  ;; first line after nret / nmatch:
  
  t = output_in[line++]
  tarr = strtok(t,string(9b),/extract) ; Individual fields
  nfields = n_elements(tarr)
  FOR i=0L,nfields-1 DO BEGIN
     parts = strtok(tarr[i],':',/extract) ; Name:type definition
     CASE trim(parts[1]) OF 
        "text":   val = ''
        "double": val = 0.0d
        "LL":     val = 0LL
        "int":    val = 0
        "L":      val = 0L
     END
     IF i eq 0 THEN stc = create_struct(parts[0],val) $
     ELSE           stc = create_struct(stc,parts[0],val)
  END

  ;; Structure made - now replicate & read:
  res = replicate(stc,nret)
  FOR i=0L,nret-1 DO BEGIN
     t = output_in[line++]
     values = strtok(t,string(9b),/extract)
     FOR j=0,nfields-1 DO BEGIN
        res[i].(j) = trim(values[j])
     END
     IF i GE 1 AND ((i+1) MOD 500) EQ 0 THEN $
        message,"Received "+trim(i+1)+"/"+trim(nret)+" lines",/info
  END
  output_in = temporary(res)
  self->close ;; We're an http 1.0 object - get rid of LUN
END

FUNCTION osdc_http::nmatch
  return,self.osdc_nmatch
END

PRO osdc_http__define
  dummy = {osdc_http, inherits http, osdc_nmatch:0L}
END

;  Transfer-Encoding: chunked
;
;  length := 0
;  read chunk-size, chunk-extension (if any) and CRLF
;  while (chunk-size > 0) {
;     read chunk-data and CRLF
;     append chunk-data to entity-body
;     length := length + chunk-size
;     read chunk-size and CRLF
;  }
;  read entity-header
;  while (entity-header not empty) {
;     append entity-header to existing header fields
;     read entity-header
;  }
;  Content-Length := length
;  Remove "chunked" from Transfer-Encoding
