function ssw_imapcoord2html, mapfile, imapcoord, urls, mapname=mapname, $
     target=target, default_href=default_href, deftarget=deftarget, $
     mapsize=mapsize
;
;+
;   Name: ssw_imapcoord2html 
;
;   Puropose: return html for imagemap generation/reference 
;
;   Input Parameters:
;      mapfile - graphic file (gif/png/jpeg) of map relative or full URL 
;      imapcoord - strarry containing comma delimited lists of coord
;                  (for example, output of get_imagemap_coord,/string and
;                   evt_grid,/imap,IMAGEMAP_COORD=imapcoord , etc)
;      urls - urls mapping to imapcoord (1:1 vector) relative path names
;                  or fully qualified URLs
;   Keyword Parameters:
;      mapname - optional map reference name used in html
;                (default is derived from MAPFILE with extension removed)
;      default_href - optional URL redirect if "unimportant" regions selected
;
;   Output:
;      function returns html  for document insertion as follows
;         (items in brackets are inputs to this routine)
;
;      First element (0) is a reference line like:
;          <img border="0" src="[mapfile]" usemap="#[mapname]">
;      Second element (1) is map defiinition initiation line like:
;          <map name="[mapname]">
;      Elements(2:n) are mapfile:imapcoord:urls mapping lines like:
;          <area shape="rect" coords="[imapcoord[i]]" href="[urls[i]]">
;      Penultimate element and last elements are standard imap close..
;          <area shape="default" nohref> ; overrided NOREF via DEFAULT_HREF
;          </map>
; 
;    Note: region shape is currently either 'rect' or 'circle'
;          IMAPCORD input in form of "a,b,c,d" (4 elements) imlies RECT
;                                    "a,b,c"   (3 elements) implies CIRCLE
;
;   History:
;      28-Feb-2002 - S.L.Freeland - a piece of the utplot,plot_map..->www puzzle 
;       4-Mar-2002 - S.L.Freeland - added DEFAULT_HREF keyword/function
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;
;- 
;       
if n_params() lt 3 then begin 
   box_message,['Need 3 input parameters...',$ 
     'IDL> imaphtml=ssw_imapcoord2httml(mapfile,imapcoord,urls [,mapname=xx])']
   return,''
endif
if n_elements(imapcoord) ne n_elements(urls) then begin 
   box_message,'Number of coordinate sets (imapcoord) must = #urls"
   return,''
endif
 
case 1 of
   strpos(mapfile,'http:') ne -1: break_url,mapfile,servers,paths,files
   else: begin 
      break_file,mapfile,ll,paths,ff,vv,ee
      files=ff+vv+ee
   endcase
endcase

if not data_chk(default_href,/string) then default_href='noref' else $
   default_href=' href="'+default_href+'"' 

if not data_chk(mapname,/string) then mapname=ssw_strsplit(files,'.',/head)
mapname=mapname(0)

minit='<img border="0" src="'+mapfile(0)+'"" usemap="#'+mapname+'">'
mname='<map name="'+mapname+'">'

; do the coord:url mapping (mix of circles and rectangles ok?)
cbmap=fix(byte(imapcoord) eq 44)     ; boolean, where commas 
ctot=total(cbmap,1)-2                 ; normalized comma total for each element

if min(ctot) lt 0 or max(ctot) gt 1 then begin 
   box_message,'Incorrect coord format,Need "1,2,3,4" (rect) or "1,2,3" (circle)'
   return,''
endif

case 1 of 
   n_elements(target) eq 0: target=''
   strpos(target,'blank') ne -1: target='target="_blank"'
   else: target='target="'+target+'"'
      
endcase
shape=(['circle','rect'])(ctot) 
shapecmds='<area shape="'+shape+'" coords ="'+ imapcoord + $
                               '" href="' + urls+ '" ' + target +'>'

if keyword_set(deftarget) then deftarget='target="' + deftarget+'"' else $
   deftarget=''

case n_elements(mapsize)of 
   1: defline='<area shape="rect" coords="0,0,' + $
                  arr2str(replicate(mapsize,2),/trim,/compress) +'"'
   2: defline='<area shape="rect" coords="0,0,' + $
                  arr2str(mapsize,/trim,/compress) +'"'
   else: defline='<area shape="default"'
endcase 
mclose=[defline + ' '  +default_href+' ' + deftarget+'>','</map>']

retval=[minit,mname,shapecmds,mclose]
return,retval
end
