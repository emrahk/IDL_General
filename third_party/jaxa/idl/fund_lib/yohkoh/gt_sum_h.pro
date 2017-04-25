function gt_sum_h, item, header=header, string=string, short=short, spaces=spaces, title=title
;
;+
;NAME:
;	gt_sum_h
;PURPOSE:
;	To extract the word corresponding to the SUM_H.  It is the HXT
;	low channel counts per second.
;CALLING SEQUENCE:
;	x = gt_sum_h(roadmap)
;	x = gt_sum_h(index)
;	x = gt_sum_h(index.sxt, /string)		;return variable as string type
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
;	returns	- The sum_h counts per sec, a integer value or a string
;		  value depending on the switches used.  It is a vector
;		  if the input is a vector
;OPTIONAL OUTPUT:
;       header  - A string that describes the item that was selected
;                 to be used in listing headers.
;HISTORY:
;	Written 7-Mar-92 by M.Morrison
;       20-Mar-92 (MDM) - Added "title" option
;        6-Jun-92 (MDM) - Corrected observing log extraction (data type prob)
;	20-Jan-93 (MDM) - Updated energies listed in title
;-
;
title = 'HXT High Channels (53-93 keV)'
header_array = "Sum High"
header_array = [header_array, header_array]	;no short option at this time
fmt = "(i7)"
;
siz = size(item)
typ = siz( siz(0)+1 )
if (typ eq 8) then begin
    ;Check to see if an index was passed (which has the tag
    ;nested under "hxt", or a roadmap or observing log entry was passed
    tags = tag_names(item)
    case tags(0) of
	'GEN':		out = item.hxt.sum_h
	'ENTRY_TYPE':	out = fix(item.hxt_sum_h)^2		;data is stored compressed
	else:		out = item.sum_h
    endcase
end else begin
    out = item
end
;
out = gt_conv2str(out, conv2str, conv2short, header_array, header=header, $
	string=string, short=short, spaces=spaces, fmt=fmt)
;
return, out
end
