;+
; Project     : VSO
;
; Name        : GET_XML_VALUE
;
; Purpose     : extract XML value from <tag>value</tag>
;
; Category    : imaging, FITS
;
; Syntax      : IDL> value=get_xml_value(xml,tag)
;
; Inputs      : XML = XML string
;
; Outputs     : VALUE = string value matching tag
;
; Keywords    : FLOAT = return as FLOAT
;               PARTIAL = doesn't have to be exact match
;
; History     : 9 Oct 2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_xml_value,xml,tag,float=float,partial=partial

if is_blank(xml) or is_blank(tag) then return,''

anyone='[^<>]+'
anynone='[^<>]*'

vxml=strjoin(xml)
vtag=strtrim(tag[0],2)
if keyword_set(partial) then vtag=vtag+anynone

stag='<'+vtag+'>'
etag='<\/'+vtag+'>'

chk=stregex(vxml,stag+'('+anyone+')'+etag,/sub,/extract,/fold)

val=strtrim(chk[1],2)
if keyword_set(float) then begin
 if is_number(val) or is_blank(val) then val=float(val)
endif

return,val & end
