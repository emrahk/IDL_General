;                IN     OUT   OUT   OUT    OUT 
pro align_label, label, devx, devy, sizex, sizey, berase=berase, $
     breverse=breverse, bcolor=bcolor, _extra=_extra, pixpad=pixpad, pad=pad, $
     charsize=charsize, size=size, image=image, info_only=info_only, debug=debug
;+
;    Name:  align_label
;
;    Purpose:  meta-label (via xyouts) an image via relative positions/align
;
;    Input Parameters:
;      label - the text label
;    
;    Output Parameters:
;       ddevx, devy - derived x and y position in device coord
;       sizex, sizey - width and heighth of LABEL in device coord
;  
;    Keyword Parameters:
;       ur/ul/uc  - upper right, upper left, upper center
;       lr/ll/lc  - lower right, lower left, lower center
;       cr/cl/cc  - center right, center left, center center
;
;       charsize / size (synonums) - desired label SIZE (per xyouts) def=1.0
;       pixpad / pad (synonyms) - number of pixels to 'pad' 
;       info_only - if set, do not issue xyouts (return devx, devy...)
;       _extra - pass unknown keywords to xyouts via inherit.
;  
;    Calling Examples:
;       IDL> align_label,'Label Text', /ur            ; label upper right
;       IDL> align_label,'Label Text', /uc,pad=10     ; top center, 10 pix pad 
;       IDL> align_label,'TEXT',/lr,color=100,size=2  ; lower right
;                                                     ; keywords->xyouts
;    History:
;       17-Nov-1999 S.L.Freeland - integrate a couple of existing functions
;                                  size determination from xyouts/ 
;    See Also:
;       label_image.pro (W.Thompson)
;       legend.pro (Astronomy Lib, Knight et al)
;-
info_only=keyword_set(info_only)
debug=keyword_set(debug)

; ------ derive character size ----------
case 1 of
   n_elements(charsize) ne 0:
   n_elements(size) ne 0: charsize=size
   else: charsize=1.0
endcase
; ---------------------------------------

; ------- derive PIXPAD ------------
case 1 of
   n_elements(pixpad) ne 0:
   n_elements(pad) ne 0: pixpad=pad
   else: pixpad=5.                          ; default pad is 5 pixels
endcase
; ---------------------------------------

; --------- minimal protection ------------
case 1 of
   not data_chk(label,/string,/scalar): begin
      box_message,['Need at least LABEL (scalar string) input,' , $
		   'IDL> align_label, label [x,y,sx,sy] [/POSTITION-KEYWORDS]']
      return
   endcase
   strupcase(!d.name) eq 'X' and !d.window eq -1: begin
      box_message,'Display is "X" but no window defined - using PIXMAP'
      wdef,xx,/free,/pixmap,512,512
      info_only=1
   endcase
   else:
endcase
; ---------------------------------------

if not data_chk(_extra,/struct) then _extra={LL:1}    ;  default lower left
etags=strupcase(tag_names(_extra))
rtags=''

; ------------ set alignment factors based on keywords /ur, /cl,.. etc ---
xf=0. & yf=0.
for i=0,n_elements(etags)-1 do begin
   if strlen(etags(i)) eq 2 then begin
   case strmid(etags(i),0,1) of
      'L': yf=0.
      'C': yf=.5
      'U': yf=1.
      else: rtags=[rtags,etags(i)]
   endcase
   case strmid(etags(i),1,1) of
      'L': xf=0.
      'C': xf=.5
      'R': xf=1.
      else: rtags=[rtags,etags(i)]
   endcase
   endif else rtags=[rtags,etags(i)]            ; un recognized->xyouts   
endfor  

yfact=n_elements(str2arr(strupcase(label),'!C'))    ; number lines in label
xyouts, 0, 0, label, width=width, size=-1           ; width (normal coord)

; --------------- derive x,y,sx,sy -----------------
sizex=width*float(charsize)*!d.x_vsize              ; width in pixels
sizey=yfact*float(charsize)*!d.y_ch_size            ; height in pixels
xpad=([pixpad,0,-pixpad])(xf*2)                     ; x pad align
ypad=([pixpad,0,-pixpad])(yf*2)                     ; y pad align
devx=(xf*!d.x_vsize) + xpad - (sizex*xf)            ; X0 (device)
devy=(yf*!d.y_vsize) + ypad - (sizey*yf)            ; Y0 (device)
; --------------------------------------------------

; ------- if not otherwise specified, apply the label -------
if not keyword_set(info_only) then begin
   if n_elements(rtags) gt 1 then xyextra=str_subset(_extra,rtags)   
   case 1 of
      n_elements(bcolor) ne 0:
      keyword_set(berase): bcolor=0
      keyword_set(breverse): bcolor=!p.color
      else:
   endcase
   if n_elements(bcolor) gt 0 then begin
      cur=tvrd(devx-pixpad>0<!d.x_vsize,devy-pixpad>0<!d.x_vsize,$
	       sizex,sizey)
      cur(*)=bcolor
      tv,cur,devx,devy
   endif
   xyouts, devx, devy, label, size=charsize,  _extra=xyextra, /device
endif
; --------------------------------------------------

if n_elements(xx) ne 0 then wdelete,xx               ; delete temp pixmap  

if debug then stop
end
