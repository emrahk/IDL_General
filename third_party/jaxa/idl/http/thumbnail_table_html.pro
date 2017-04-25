function thumbnail_table_html, giffiles, thumbnails, $
	       ttext=ttext, tperline=tperline, ncols=ncols,  $
	       make_thumbnails=make_thumbnails, factor=factor
;
;+   Name: thumbnail_table_html
;
;    Purpose: Make an html thumbnail table - optionally make the thumbnails
;
;    Input:
;      giffiles   - list of giffile names (including full path)
;      thumbnails - corresponding thumbnails (default is GIFFILES_thumb.gif)
;
;    Keyword Parameters:
;      make_thumbnails - if set, make the thumbnails (via call mkthumb)
;      factor - if set, use as thumbnail factor (implies /MAKE_THUMBNAIL)
;      ncols - number of columns (thumbnails) in html table
;      tperline - ncols synonym - 'thumbnails per line'  
;      text - optional text desciption (one element per giffiles)
;             (default is name of giffile and full gif file size)
;  
;    Calling Sequence:
;       IDL> html=thumbnail_table_html(giffiles [,thumbnails] [,make_thumb]
;                                               [,ncols=xx] )
;    Calling Example:
;          
;     IDL> html=thumbnail_table_html(giffiles, ncols=5, /make_thumb,factor=.1)
;     IDL> file_append,hdoc, html     ; << insert table in html document
;
;    Calls:
;      str2html, strtab2html, mkthumb, str2arr, str_replace, concat_dir, $
;      break_file, data_chk,   
;
;    History:
;      24-Aug-1998 - S.L.Freeland - break code from image2movie,/still  
;
;-  
  
if not data_chk(giffiles,/string) then begin
      box_message,'IDL> html=thumbnail_table_html(giffiles [,thumbnails] [,/generate])
      return,''
endif

nfiles=n_elements(giffiles)
break_file,giffiles,flogs,fpaths,fnames,fextens,fvers
if not data_chk(thumbnails,/string) then $
   thumbnails=concat_dir(fpaths,fnames+'_thumb'+fextens+fvers)
break_file,thumbnails,tlogs,tpaths,tnames,textens,tvers

if keyword_set(make_thumbnails) then begin
  if not keyword_set(factor) then factor=.2    
  for i=0,n_elements(giffiles)-1 do $
     out=mkthumb(ingif=giffiles(i),outfile=thumbnails(i), factor=factor)
endif

stab=str2html(fnames+fextens,link_text=tnames+textens,/nopar)
table=str_replace(stab,'</A>','<br><em><font size=-1>')+fnames+$
       '<br>(' +file_size(giffiles,/string,/auto)+')</em></font></A>'
nt=n_elements(table)

case 1 of                                     ; number of columns
   keyword_set(tperline): ncols=tperline
   keyword_set(ncols):
   else: ncols=5                              ; default number of columns
endcase

nrows=(nt/ncols)+(nt mod ncols ne 0)           ; number of rows (boost for max)
embed=strarr(ncols*nrows) & embed(0)=table    ; table 'vector' / insert
table=reform(embed,ncols,nrows)                 ; reform vector->table
html=strtab2html(table)                       ; table->html
return, html
end
