pro genx2html, genxfiles, outfiles=outfiles,  $
   thumbnail=thumbnail, thumbfact=thumbfact, maxthumb=maxthumb, addlink=addlink, $
   top_http=top_http, path_http=path_http, $		; top level http path
   image_http=image_http, html_http=html_http, $	; optional subdirect.
   debug=debug, header=header, trailer=trailer, noupdate=noupdate
;+
;   Name: genx2html
;
;   Purpose: convert a 'genx' file to an html file in a 'standard' format
;
;   Calling Sequence:
;      genx2html,genxfile [,outfile=outfile, httpdir=httpdir, thumbfact=N,/thumb]
;
;   Input Parameters:
;      genxfiles - one or more genx files to convert
;
;   Keyword Parameters:
;      outfiles -  if set, output filenames (default derived from genx name)
;      thumbnail - if set, make thumbnail and link
;      thumbfact - if set, scale factor for thumbnail
;      maxthumb  - if set, scale thumbnail to this size (largest dimension)
;      addlinks  - if set, filename to add a link to this image (uniq)
;
;   Restrictions:
;       must define the parameters (pass keyword in or via environmental)
;          top_http  -  top http path known to outside world
;          path_http -  top http local disk name (for writing)
;       optionally define subdirectories (may be relative)
;          image_http - path to images (gif) created by this routine
;          html_http  - path to html files created by this routines
;
;	optionally, the address written at the end of the html file can
;	be changed from the default (sxtwww@...) by setting the enviroment 
;       variable "address_http" to the required string.
;      
;   History:
;      3-Feb-1995 (SLF) - Written to convert show_pix images to gif/html
;      6-Feb-1995 (SLF) - Added auto-scaling for thumbnail, ADDLINK keyword
;			  and function (update a linked list)
;      8-Feb-1995 (SLF) - Add text about full image file size
;     13-Feb-1995 (SLF) - parameterized (site independent)
;     29-mar-1995 (SLF) - remove <br>x around text
;     29-mar-1995 (SLF) - break text formatting into str2html.pro
;      7-jun-1995 (SLF) - increase min_col to str2html
;     12-Jul-1995 (RDB) - added address_http changing of "address"
;     31-aug-1995 (SLF) - add HEADER and TRAILER keywords
;     19-dec-1995 (SLF) - fix ADDLINK bug
;     22-apr-1996 (SLF) - add NOUPDATE switch
;     13-Aug-2003, William Thompson, Use SSW_WRITE_GIF instead of WRITE_GIF
;-
noupdate=keyword_set(noupdate)

thumbnail=keyword_set(thumbnail) or keyword_set(thumbfact) or keyword_set(max_thumb)

debug=keyword_set(debug)

if n_elements(maxthumb) eq 0 then maxthumb=150

if not keyword_set(top_http) then begin
   chkenv=get_logenv('top_http')
   if chkenv ne '' then top_http=chkenv else begin
      message,/info,"Must pass in <top_http> or assign environmental/logical
      return
   endelse      
endif

if not keyword_set(path_http) then begin
   chkenv=get_logenv('path_http')
   if chkenv ne '' then path_http=chkenv else begin
      message,/info,"Must pass in <path_http> or assign environmental/logical
      return
   endelse      
endif

if keyword_set(image_http) then img=image_http else $
   image_http=get_logenv('image_http')

if keyword_set(html_http) then html=html_http else $
   html_http=get_logenv('html_http')

images=concat_dir(path_http,image_http)
htmls=concat_dir(path_http,html_http)
limages=concat_dir(top_http,image_http)
lhtmls=concat_dir(top_http,html_http)

if debug then begin
   help,images(0),htmls(0),limages(0),lhtmls(0)
   stop
endif

if n_elements(outfiles) eq 0 then outfiles=strarr(n_elements(genxfiles))

;--------------- file loop ---------------------------------------
for i=0,n_elements(genxfiles)-1 do begin	
   genxfile=genxfiles(i)
   message,/info,"Working on file: " + genxfile 
   if not file_exist(genxfile) then message,"NO genx file found..."
   break_file,genxfile, log, path, file, ext, ver
   
;  --------- derive output file names for gif and thumbnail -------------
   if not keyword_set(outfiles(i)) then outfile=file else outfile=outfiles(i)
   outgif=concat_dir(images,outfile + '.gif')
   outthumb=concat_dir(images,outfile + '_thumbnail' + '.gif')
   outhtml=concat_dir(htmls,outfile + '.html')

   if noupdate and file_exist(outhtml) then begin
      message,/info,"NOUPDATE set and html file exists..."
      message,/info,"NOT regenerating..."     
   endif else begin
;  -------------- read genx, write gif -------------------------
      restgen, file=genxfile(0), image, r,g,b,text=text
      ssw_write_gif,outgif,image,r,g,b
      sizeimage=file_size(outgif,/str,/auto)		
      lastupdate=ut_time() + ' UT'
      ;-------------------- - thumbnail ------------------------
      if thumbnail then begin
         message,/info,"Creating Thumbnail...."
         if keyword_set(thumbfact) then tfact=thumbfact else tfact=$
            (where(max([(size(image))(1),(size(image))(2)])/(lindgen(10)+1) le maxthumb))(0) > 1
         message,/info,"Thumbnail factor: " + strtrim(tfact,2)
         ssw_write_gif,outthumb,congrid(image, $
           (size(image))(1)/tfact,(size(image))(2)/tfact), r,g,b
      endif

;  write html image desription
       otext=$
        ['<html>','<head>','<title>','XTITLE','</title>','</head>','<body>']
      if not keyword_set(title) then title=outfile
      if keyword_set(header) then $
         exestat=execute('sxt_html,outhtml,/header,title=title') else $
         file_append,outhtml,str_replace(otext,'XTITLE',title),/new

      imref='<a href="XIMG">'
      imginfo='<h2>' + strupcase(outfile) + '</h2>' + 	     $
           'File Created: ' + lastupdate  + 		$
           '<p>Full size [' + sizeimage + ']<p>'
      thumbref=imginfo + '<center><img src="XTHUMB"></center></a><p>' 

      break_file,[outgif,outthumb],log,path,file,ext,ver
      relgif=concat_dir(limages,file(0)+ext(0)+ver(0))   
      relthumb=concat_dir(limages,file(1)+ext(1)+ver(1))

;     --------- thumbnail link and reference (*** Forced ON ***)
      if thumbnail then begin
         file_append,outhtml, $
            [str_replace(imref,'XIMG',relgif),str_replace(thumbref,'XTHUMB',relthumb)]
      endif else begin
         file_append,outhtml, $
            [str_replace(imref,'XIMG',relgif),str_replace(thumbref,'XTHUMB',relthumb)]
      endelse
      file_append,outhtml, str2html(text, min_line=3,min_col=4)

;     html close 
      if keyword_set(trailer) then $
        exestat=execute('sxt_html,outhtml,/trailer,/credits') else begin
         chkenv=get_logenv('address_http')
         if chkenv ne '' then address=chkenv else $
           address = ['sxtwww@sxt.space.lockheed.com', 'freeland@sxt1.space.lockheed.com']
           trailer=['<hr>','<address>',address,'</address>']
         otext=[trailer,'</body>','</html>']
          file_append,outhtml,otext
      endelse
;     ---------------------- finished writing html description ------------

   endelse ; end of IF NOUPDATE ... BLOCK

;  ------------ add image link to link list --------------------------
   if keyword_set(addlink) then begin
      case data_chk(addlink,/type) of
         7: linkfile=addlink
         else: begin
            linkfile=get_logenv('mosaic_images')
            if linkfile eq '' then linkfile= $
               concat_dir(htmls,'data.html')
          endcase
      endcase
         if not file_exist(linkfile) then begin
            message,/info,"No image list file: " + linkfile
         endif else begin
            linkinfo=rd_tfile(linkfile)
;           dont add existing file
            newlist=(where(strpos(linkinfo,"Recent Gallery Additions") ne -1))(0)
            if newlist(0) eq -1 then $
            newlist=(where(strpos(linkinfo,"Recent Additions") ne -1))(0)
		
            head='<LI><A HREF="'
            list=where(strpos(linkinfo,head) eq 0,imgcnt)
            link=concat_dir(lhtmls,file(0) + '.html')
            existing=where(strpos(linkinfo,link) ne -1,ecnt)
            if ecnt eq 0 then begin
               newline=$
                   head + link + '"><B>' + $
                   strupcase(str_replace(outfile,"_"," ")) + $
                  '</B></A>'
               newinfo=[linkinfo(0:newlist),newline,linkinfo(newlist+1:*)]
               message,/info,"Updating file: " + linkfile
               file_append,linkfile,newinfo,/new
            endif else message,/info,"Link to: " + outhtml  + ' already exists"
         endelse
   endif
endfor
; ---------------------- end of file loop ---------------------------

return
end



   
