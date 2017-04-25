function gt_sxs1, item, header=header, string=string, short=short, spaces=spaces, title=title
;
;+
;NAME:
;	gt_sxs1
;PURPOSE:
;	To extract the word corresponding to the SXS1 counts.  The units
;	are cnts/sec
;CALLING SEQUENCE:
;	x = gt_sxs1(roadmap)
;	x = gt_sxs1(index)
;	x = gt_sxs1(index.sxt, /string)		;return variable as string type
;METHOD:
;	The input can be a structure or a scalar.  The structure can
;	be the index, or roadmap, or observing log.
;INPUT:
;	item	- A structure or scalar.  It can be an array.  
;OPTIONAL INPUT:
;	string	- If present, return the string mnemonic (long notation)
;	short	- If present, return the short string mnemonic 
;	spaces	- If present, place that many spaces before the output
;		  string.
;OUTPUT:
;	returns	- The SXS1 counts per sec, a integer value or a string
;		  value depending on the switches used.  It is a vector
;		  if the input is a vector
;OPTIONAL OUTPUT:
;       header  - A string that describes the item that was selected
;                 to be used in listing headers.
;HISTORY:
;	Written 7-Mar-92 by M.Morrison
;       20-Mar-92 (MDM) - Added "title" option
;	 6-Jun-92 (MDM) - Corrected observing log extraction (data type prob)
;       12-Oct-92 (MDM) - Modified to correct for integer*2 overflow
;	 7-Jan-94 (MDM) - Updated title
;-
;
;title = 'WBS SXS12 (7.5-15 keV)
title = 'WBS SXS-12 (3-15 keV)
header_array = "SXS1 Cnts"
header_array = [header_array, header_array]	;no short option at this time
fmt = "(i9)"
;
siz = size(item)
typ = siz( siz(0)+1 )
if (typ eq 8) then begin
    ;Check to see if an index was passed (which has the tag
    ;nested under "wbs", or a roadmap or observing log entry was passed
    tags = tag_names(item)
    case tags(0) of
	'GEN':		out = item.wbs.sxs1
	'ENTRY_TYPE':	out = fix(item.wbs_sxs1)^2		;data is stored compressed
	else:		out = item.sxs1
    endcase
end else begin
    out = item
end
;
ss = where(out lt 0, count)     ;added 12-Oct-92
if (count ne 0) then begin
    out = long(out)
    out(ss) = out(ss) + long(2)^16
end
;
out = gt_conv2str(out, conv2str, conv2short, header_array, header=header, $
	string=string, short=short, spaces=spaces, fmt=fmt)
;
return, out
end
