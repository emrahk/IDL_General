function strtab2html, table_array, $
    cellspacing=cellspacing, cellpadding=cellpadding, 	border=border,	$
    spacing=spacing,         padding=padding,				$
    row0header=row0header, header=header, null_fill=null_fill, $
    right=right, left=left, center=center
;+
;   Name: strtab2html
;
;   Purpose: generate html Table (V3 table format) from table (string array)
;
;   Input Parameters:
;      table_array - 1D or 2D table (1D will be -> 2D)
; 
;   Optional Keyword Parameters:
;      cellpadding, cellspacing - per html table formatting spec.
;      padding, spacing		- synonyms for above
;      border			- per html table formatting spec.
;      row0header - switch, if set, use row0 values for header labels (bold)
;      right,left,center - switches - alignment of values in cells
;   
;   Calling Sequence:
;      table_html=strtab2html(table_array, /center, /right, /left, $
;    		                           border=NN, cellpad=NN, cellspace=NN)
;
;   Calling Examples:
;      table_html=strtab2html(strarr_1D)	; break into columns, -> html
;      table_html=strtab2html(strarr_2D)	; user table -> html
;      table_html=strtab2html(strarr_2D,cellspac=10,border=20)
;      table_html=strtab2html(strarr_2D,/row0head) ; use row 0 as header lables
;
;   History:
;      8-march-1996 S.L.Freeland
;      7-May-1996   S.L.Freeland - changed to keyword inheritance
;      9-May-1996   S.L.Freeland - force output to be 1D vector 
;     10-May-1996   S.L.Freeland - add NULL_FILL keyword (default to '-')
;     14-May-1996   S.L.Freeland - call 'strarrcompress' to remove null rows
;     15-May-1996   S.L.Freeland - remove keyword inheritance
;     23-Jul-1997   S.L.Freeland - dont call str2cols (assume user knows)     
;     19-jan-1998   S.L.Freeland - added missing /LEFT, /RIGHT, /CENTER KWs
;-
; ----------- check keywords and assign defaults ------------

if keyword_set(padding) then cellpadding=padding	; synonym
if keyword_set(spacing) then cellspacing=spacing	; synonym
if n_elements(cellpadding) eq 0  then cellpadding=5	; pad default
if n_elements(cellspacing) eq 0  then cellspacing=3	; space default
if n_elements(border)  eq 0      then border=5
case 1 of 						; set cell alignment
   keyword_set(right):  align='right'
   keyword_set(left):   align='left'
   else: 		align='center'			; default
endcase
; ---------------------------------------------------------------
stable=size(table_array)
;if stable(0) eq 1 then $			; 1D passed in - columnize it
;   columns=str2cols(table_array) else $        ; SLF - remove auto-str2cols

columns=table_array			; 2D (already columnized)

columns=strarrcompress(columns,/rows)		; remove null rows
stable=size(columns)
columns=strtrim(columns,2)
if n_elements(null_fill) eq 0 then null_fill='-'
null=where(columns eq '',null_cnt)
if null_cnt gt 0 then columns(null) = null_fill
; ---------------------------------------------------------------

if keyword_set(row0header) then begin
   columns(*,0)='<th>' + columns(*,0) + '</th>'		; label header cells
   columns(*,1:*)='<td>' + columns(*,1:*) + '</td>'	; label data cells 
endif else columns(*)='<td>' + columns(*) + '</td>'	; label data cells
columns(0,*)='<tr align=' + align + '>' + columns(0,*)  ; add row html 


; --------------- define table header html --------------------
head_html='<table border='      + strtrim(border,2) + $
                ' cellpadding=' + strtrim(cellpadding,2) + $
	        ' cellspacing=' + strtrim(cellspacing,2) + '>'
; ---------------------------------------------------------------

; --------------- now glue it all together ----------------
columns(0)=head_html + columns(0)
columns(n_elements(columns)-1)=$
   columns(n_elements(columns)-1) + '</table>
table_html=reform(columns,n_elements(columns))		; make 1D vector
; ---------------------------------------------------------------

return, table_html
end
