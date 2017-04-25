function html_highlight, strarray, row_number, column_number, $
			 color=color, rsize=rsize, emphasize=emphasize, $
			 _extra=_extra
;+
;   Name: html_highlight
;
;   Purpose: highlight some user specified html (usually tables)  
;
;   Input Parameters:
;      strarray - 1d or 2d (table) string array
;      row_number - subscripts of rows to highlight (default=all)
;      column_number - subcripts of columns to highlight (default=all)  
;
;   Keyword Parameters:
;      color - html color command (mnemonic like 'red', 'blue' or #RRGGBB)
;              (can also set color by keyword inheritance, /red,/blue, etc)
;      rsize - relative font size  
;      emphasize - use <em>xxx</em>
;      /XXX - keyword inheritance - assumed COLOR (/yellow, /blue, /green..)
;  
;   Calling Sequence:
;      highlighted=html_highlight(strarray [,row,col], $
;         color='color', rsize=nn [,/emphasize]
;
;   Calling Example:
;      Use in conjunction with 'str2cols' and 'strtab2html' and
;      file_append to include html tables with accented information.
;
;      IDL> table=str2cols(string_array)    ; column justified 1D->2D table
;      IDL> hightab=html_highlight(table, -1, 4, color='red',rsize=2)
;      IDL> htmltab=strtab2html(hightab)    ; convert ascii 2D strarry
;                                           ; to an html table
;
;   History:
;      12-June-1998 - S.L.Freeland - break out an a useful function
;  
;-
if not data_chk(strarray,/string) then begin
   box_message,$
     'IDL> highlighted=html_highlight(strarray [,rownos,colnos] , color=color, rsize=rsize, emphasize=emphasize'
   return,''
endif

nrows=data_chk(strarray,/ny)            ; total number of rows
ncols=data_chk(strarray,/nx)            ; ncols

case 1 of
   n_elements(row_number) eq 0: ssr=lindgen(nrows)
   row_number(0) eq -1: ssr=lindgen(nrows)
   else: ssr=row_number
endcase

case 1 of 
  ncols eq 0:ssc=0
  n_elements(column_number) eq 0: ssc=lindgen(ncols)
  column_number(0) eq -1: ssc=lindgen(ncols)
  else: ssc=column_number
endcase  

if not keyword_set(color) and data_chk(_extra,/struct) then begin
   color=(tag_names(_extra))(0)
   box_message,'Keyword Inherit, Setting COLOR='+color  
endif  

fontcmd=keyword_set(color) or keyword_set(rsize)
emph=keyword_set(emphasize)

openstr=(['','<em>'])(emph)   + (['','<font '])(fontcmd) 
closestr=(['','</em>'])(emph) + (['','</font>'])(fontcmd)

if keyword_set(color) then  openstr=openstr+' color='+ color
if keyword_set(rsize) then  openstr=openstr+' size=' + $
    (['','+'])(positive(rsize)) + strtrim(rsize,2)
openstr=openstr +(['','>'])(fontcmd)

outarray=strarray

for cols=0,n_elements(ssc)-1 do begin
   outarray(ssc(cols),ssr)=openstr+reform(outarray(ssc(cols),ssr))+closestr   
endfor

return,outarray
end
