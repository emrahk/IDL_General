;+
; Name: find_all_uname
;
; Purpose: Find all widget ids with specified uname under a base widget
;   IDL's widget_info(b,/uname) only returns the first one found. This one
;   calls itself recursively with all siblings and children of base.
;
; Arguments:
;   base - base widget to start from
;   uname - string, uname to look for
;
; Output: array of widget id's with specified uname
;
; Written: Kim Tolbert, October 2007
;-

function find_all_uname, base, uname

next = widget_info(base,/child)

WHILE widget_info(next,/valid_id) DO BEGIN
	IF widget_info(next,/child) ne 0 THEN $
		ret = append_arr(ret, find_all_uname(next, uname)) $
	ELSE $
		ret = append_arr(ret, widget_info(next, /uname) eq uname ? next : 0)
	next = widget_info(next,/sibling)
END

q = where (ret ne 0, c)

return, c gt 0 ? ret[q] : 0

end
