function gt_total_cnts, item, ichan, header=header, string=string, short=short, spaces=spaces, title=title
;
;+
;NAME:
;	gt_total_cnts
;PURPOSE:
;	To extract the word corresponding to the BCS total counts (as 
;	derived from the spectra).  Default output is cnts/sec.
;CALLING SEQUENCE:
;	x = gt_total_cnts(roadmap)
;	x = gt_total_cnts(roadmap,1)
;	x = gt_total_cnts(index,2)
;	x = gt_total_cnts(index.sxt, /string)		;return variable as string type
;METHOD:
;	The input can be a structure or a scalar.  The structure can
;	be the index, or roadmap, or observing log.
;INPUT:
;	item	- A structure or scalar.  It can be an array.  
;OPTIONAL INPUT:
;	ichan	- Channel number to extract (1,2,3,4) - if not present,
;		  the output is an 4xN data array
;	string	- If present, return the string mnemonic (long notation)
;	short	- If present, return the short string mnemonic 
;	spaces	- If present, place that many spaces before the output
;		  string.
;OUTPUT:
;	returns	- The total counts per sec, a floating point value or a string
;		  value depending on the switches used.  It is a vector
;		  if the input is a vector.  If no channel was selected,
;		  then the output is a 2-D array (4xN)
;OPTIONAL OUTPUT:
;       header  - A string that describes the item that was selected
;                 to be used in listing headers.
;	title	- A string that can be used with a plotting title.  If
;		  no channel is specified, then title is an array of 4
;		  elements.
;HISTORY:
;	Written 7-Mar-92 by M.Morrison
;	20-Mar-92 (MDM) - Added "title" option
;	 4-Jun-92 (MDM) - The value being returned was NOT the counts/sec.
;			  The normalization was not being done right.  
;			  Previously the value returned was cnts/DGI.
;	 1-Jul-92 (MDM) - Adjusted so that the counts returned were 
;			  true counts/sec (perviously the *10 factor
;			  was missing)
;	24-Nov-92  RDB  - Made factor 10 a real to stop overflow...
;-
;
title = ['BCS Fe XXVI', 'BCS Fe XXV', 'BCS Ca XIX', 'BCS S XV']
header_array = " Cnt/sec "
header_array = [header_array, header_array]	;no short option at this time
fmt = "(f9.2)"
;
siz = size(item)
typ = siz( siz(0)+1 )
if (typ eq 8) then begin
    ;Check to see if an index was passed (which has the tag
    ;nested under "bcs", or a roadmap or observing log entry was passed
    tags = tag_names(item)
    case tags(0) of
	'GEN':	begin & out = item.bcs.total_cnts*10. 	& dgi = ((item.bcs.dgi>1)*.125)	& end
	else:	begin & out = item.total_cnts*10.	& dgi = ((item.dgi>1)*.125)	& end
    endcase
end else begin
    out = item
end
;
if (n_elements(ichan) ne 0) then begin
    out = reform(out(ichan-1,*)) / dgi
    title = title(ichan-1)
end else begin
    out = out / [[dgi], [dgi], [dgi], [dgi]]	;have to normalize every channel in the matrix
end
;
out = gt_conv2str(out, conv2str, conv2short, header_array, header=header, $
	string=string, short=short, spaces=spaces, fmt=fmt)
;
return, out
end
