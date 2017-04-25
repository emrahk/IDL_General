pro tvmulti,image,ctables,post=post,row=row,file=file,landscape=landscape,$
    labels=labels,below=below,charsize=charsize,charthick=charthick,$
    log=log,odd=odd,title=title,tpos=tpos,tex=tex

;+
;   Name: 
;       tvmulti
;   Purpose: 
;       display multiple images in a single window or postscript page
;       with each images having a separate color table
;   Input Parameters:
;      image   - 3 dimensional array (m,n,num_images)
;      ctables - array of color tables, can be absolute numbers or EIT
;                 specific wavelengths
;
;   Output Parameters:
;      
;   Keyword Parameters:
;       log    - set if want alog10 scaling of image
;       post   - set if want postscript output
;       row    - set if want a single row of output (default is to let
;                routine determine image positions)
;       file   - set for output PS file name
;       landscape - set for landscape PS plots
;       labels - array of labels corresponding to each image
;       below  - set of want labels below image (default is above)
;       charsize - label character size
;       charthick - label character thickness
;       odd    - set if want last row centered as opposed to default
;       title  - set to figure title
;       tpos - set for position of title
;       tex  - set for encapsulated postscript output
;
;   Calling Sequence:
;        tvmulti,image,ctable,[/post],[/below],[/landscape],[/row],$
;           [file=file],[labels=labels],[charsize=charsize],$
;           [charthick=charthick],[log=log],[odd=odd], [title=title]
;           [tpos=tpos], [tex=tex]
;
;   Method:
;        If postscript output - load appropriate color table, call
;        put to display image. If X output, break up color table into
;        num_images sections and load color table into each section,
;        then call put to display images
;  
;   History:
;      1997 Feb 24 - J. Newmark
;      2000 Jul 07 - J. Newmark add TEX keyword for encapsulated PS output.
;      2010 Sep 24 - William Thompson, use [] indexing
;-

sz=size(image)
if sz[0] ne 3 then begin
  message,/info,'This routine is for multiple images'
  return
endif

if n_elements(ctables) ne sz[3] then begin
  message,/info,'You must input a color table for each image'
  return
endif

device = !d.name
if keyword_set(post) then begin
  if not keyword_set(file) then file = 'idl.ps'
  if keyword_set(landscape) then portrait = 0 else portrait = 1
  ps,file,/color,portrait=portrait,tex=tex
  device,/isolatin,/palatino
endif

if not keyword_set(tpos) then tpos=0.2
if keyword_set(title) then relat = 0.85 else relat = 0.95

uniq_color=ctables(uniq(ctables,/first))
ncolors = !d.table_size/n_elements(uniq_color)
waves=[171,195,284,304]
eitcolors = getenv('coloreit')
if eitcolors eq '' then eitcolors = filepath('colors1.tbl', $
        subdir=['resource', 'colors'])

geometry = [0,0,0,0]
lastodd = 0
for i = 0, sz[3] -1 do begin
  table = ctables[i]
  case 1 of 
      n_elements(table) eq 0: itable=0
      is_member(table[0],waves): itable=(where(table[0] eq waves))[0]+42
      else:itable=table[0]	
  endcase
  if keyword_set(post) then begin
       loadct,file=eitcolors,itable 
       if keyword_set(log) then dimage = alog10(image[*,*,i]>0.25) $
           else dimage = image[*,*,i]
       case 1 of
         keyword_set(row): put, dimage, i+1, sz[3], 1, 1, /noexact, relat=relat
         keyword_set(odd) and i gt sz[3]-geometry[1]: begin
                    put,dimage,lastodd+1.5,geometry[1],geometry[3],geometry[3],$
                      /noexact,relat=relat 
                    lastodd = lastodd + 1
                           end
         else: put, dimage,i+1,sz[3],/noexact,relat=relat, geometry=geometry 
       endcase
       if keyword_set(labels) then label_image,labels[i],below=below,$
           charsize=charsize,charthick=charthick
       if keyword_set(title) then $
          xyouts,0.2,tpos,title,chars=2.5,charth=2,/normal
  endif else begin
       c_pos = where(uniq_color eq ctables[i])
       loadct,file=eitcolors,itable,ncolors=ncolors,bottom=c_pos[0]*ncolors
       if keyword_set(log) then dimage = alog10(image[*,*,i]>0.25) $
           else dimage = image[*,*,i]
       dimage = bytscl(dimage, top = ncolors-1) + byte(c_pos[0]*ncolors)
       case 1 of
         keyword_set(row): put, dimage, i+1, sz[3], 1, 1, /noexact, relat=relat,$
                       /noscale
         keyword_set(odd) and i gt sz[3]-geometry[1]: begin
                    put,dimage,lastodd+1.5,geometry[1],geometry[3],geometry[3],$
                      /noexact,/noscale,relat=relat 
                      lastodd = lastodd + 1
                           end
         else: put, dimage,i+1,sz[3],/noexact,/noscale,relat=relat, $
               geometry=geometry 
       endcase
       if keyword_set(labels) then label_image,labels[i],below=below,$
           charsize=charsize,charthick=charthick
       if keyword_set(title) then $
          xyouts,0.2,tpos,title,chars=2.5,charth=2,/normal
  endelse
  dimage = 0
endfor

if keyword_set(post) then psclose
end
