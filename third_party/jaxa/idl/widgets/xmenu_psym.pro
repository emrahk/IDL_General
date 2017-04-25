function xmenu_psym, dummy, group=group
;
;  27-Sep-2010, William Thompson, use [] indexing
;
list = [' 0: solid line', $
	' 1: plus sign (+)', $
	' 2: Astrik (*)', $
	' 3: Period (.)', $
	' 4: Diamond', $
	' 5: Triangle', $
	' 6: Square', $
	' 7: X', $
	'10: Histogram', $
	'-1: plus sign (+) connected with a line', $
	'-2: Astrik (*) connected with a line', $
	'-3: Period (.) connected with a line', $
	'-4: Diamond connected with a line', $
	'-5: Triangle connected with a line', $
	'-6: Square connected with a line', $
	'-7: X connected with a line']
;
out = xmenu_sel(list, /one, group=group)
out = out[0]	;turn into scalar
if (out eq -1) then out = -99 $
		else out = fix(strmid(list[out], 0, 2))
;
return, out
end
