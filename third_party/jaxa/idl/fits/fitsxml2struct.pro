;+
; Project     :	ORBITER - SPICE
;
; Name        :	FITSXML2STRUCT()
;
; Purpose     :	Convert FITS header in XML format to structure
;
; Category    :	FITS
;
; Explanation :	This routine takes a FITS header which has been converted into
;               XML format, such as those embedded within the Helioviewer
;               JPEG2000 files, into a standard header structure.  The FITS
;               header section begins with "<fits>" and ends with "</fits>",
;               and contains lines such as "<NAXIS>2</NAXIS>" for the various
;               FITS keywords.  HISTORY and COMMENT keywords are handled as
;               separate multiline sections within the XML, e.g.
;
;               <comment>
;               FITS (Flexible Image Transport System) format is defined in
;               'Astronomy and Astrophysics', volume 376, page 359;
;               bibcode: 2001A&amp;A...376..359H
;               </comment>
;
; Syntax      :	Result = FITSXML2STRUCT(xml)
;
; Examples    :	ohv = obj_new('IDLffJPEG2000', filename)
;               ohv->getproperty, xml=xml
;               struct = fitsxml2struct(xml)
;
; Inputs      :	XML     = The XML structure containing the FITS header.
;
; Opt. Inputs :	None
;
; Outputs     :	The result of the function is the header structure.
;
; Opt. Outputs:	None
;
; Keywords    :	HEADER  = Returns the intermediate FITS header.
;
;               Also accepts any keyword supported by the routine
;               FITSHEAD2STRUCT.
;
; Calls       :	DATATYPE, FXHMAKE, FXADDPAR, FITSHEAD2STRUCT
;
; Common      :	None
;
; Restrictions:	None
;
; Side effects:	None
;
; Prev. Hist. :	None
;
; History     :	Version 1, 16-Nov-2015, William Thompson, GSFC
;               Version 2, 08-Dec-2015, WTT, rewrote to not depend on ^J
;
; Contact     :	WTHOMPSON
;-
;
function fitsxml2struct, fitsxml0, header=hdr, _extra=_extra
;
if datatype(fitsxml0) ne 'STR' then message, $
  'Syntax: Result = FITSXML2STRUCT( xml )'
;
;  If the XML information is a string array, then concatenate it into single
;  string, demarcated with linefeed (^J) characters.
;
if n_elements(fitsxml0) eq 1 then fitsxml = fitsxml0 else begin
    fitsxml = fitsxml0[0]
    for i = 1,n_elements(fitsxml0)-1 do $
      fitsxml = fitsxml + string(10b) + fitsxml0[i]
endelse
;
;  Extract out the part between "<fits>" and "</fits>"
;
fitstart = strpos(strlowcase(fitsxml),'<fits>') + 6
fitslength  = strpos(strlowcase(fitsxml),'</fits>') - fitstart
fitsxml = strmid(fitsxml, fitstart, fitslength)
;
;  Create a basic FITS header.
;
fxhmake, hdr
;
;  Process FITS tags until the end is reached.
;
while strlen(fitsxml) gt 0 do begin
;
;  Get the tag name.
;
    tagstart = strpos(fitsxml,'<') + 1
    tagend = strpos(fitsxml,'>')
    taglen = tagend - tagstart
    tag = (strtrim(strupcase(strmid(fitsxml, tagstart, taglen)), 2))[0]
    fitsxml = strmid(fitsxml, tagend+1, strlen(fitsxml)-tagend-1)
;
;  Find the end tag marker, and extract the value field.
;
    valuelen = strpos(strupcase(fitsxml), '</' + tag + '>')
    value = (strmid(fitsxml, 0, valuelen))[0]
    nchar = valuelen + taglen + 3
    fitsxml = strmid(fitsxml, nchar, strlen(fitsxml)-nchar)
;
;  Ignore the SIMPLE tag.
;
    if tag ne 'SIMPLE' then begin
;
;  Check whether the value constitutes a valid number.  If it is, decide
;  whether it's a single or double-precision floating point number.
;
        if valid_num(value) then begin
            if (strpos(value,'.') ge 0) or (strpos(value,'e') ge 0) or $
              (strpos(value,'d') ge 0) then begin
                if (strpos(value,'d') gt 0) or (strlen(value) ge 8) then begin
                    value = double(value)
                end else value = float(value)
;
;  Otherwise, treat it as a long integer so long as it's within the
;  valid range.
;
            endif else begin
                lmax = 2.0d^31 - 1.0d
                lmin = -2.0d^31
                value = double(value)
                if (value ge lmin) and (value le lmax) then value = long(value)
            endelse
;
;  If a string value, separate it into lines demarked by linefeeds (^J)
;
        end else value=strsplit(strtrim(value,2), string(10b), /extract)
;
;  Add the keyword and value to the temporary header.  Ignore any keywords
;  longer than eight characters--these are explanatory lines added by the FITS
;  to XML conversion process.
;
        if taglen le 8 then for i=0,n_elements(value)-1 do $
          fxaddpar, hdr, tag, value[i]
    endif
endwhile
;
;  Call FITSHEAD2STRUCT to complete the conversion process.
;
return, fitshead2struct(hdr, _extra=_extra)
end
