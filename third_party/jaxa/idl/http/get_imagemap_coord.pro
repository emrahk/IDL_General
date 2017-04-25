function get_imagemap_coord, bef_2d, aft_2d, $
    circle=circle, rectangle=rectangle, $
    string_out=string_out, noconvert=noconvert , debug=debug
;
;+
;   Name: get_imagemap_coord
;
;   Purpose: return html imagemap coordinates from difference of 2 input images
;
;   Input Parameters:
;      bef_2d, aft_2d - image pair, assumed to be 'tvrd' output
;                            before and after some tv or plot command was issued
;
;   Keyword Parameters:
;      circle - if set, fit circle to difference and return [xc,yc,radius]
;      rectangle (default) - return bounding rectangle [minx,miny,maxx,maxy]
;      string_out if set, return imap/html ready strings ex: "21,158,170,211"
;      noconvert - if set, return IDL orientation (imap has 0,0 upper right)=

;   Calling Sequence:
;      imap_coord=get_imagemap_coord(before,after [,/circle] ,[/string_out])
;       idl_coord=get_imagemap_coord(before,after,/noconvert [,/circle] )
;
;   Context Example/Demo - circle an annotation
;      ; assume window exists
;      IDL> before=tvrd()                        ; get before image
;      IDL> xyouts,xx,yy,TEXT                    ; some annotation
;      IDL> after=tvrd()                         ; after image 
;      IDL> xyr=get_imagemap_coord(dat0,dat1,/circle,/noconvert)  ; IDL conven
;      IDL> draw_circle,xyr(0),xyr(1),xyr(2),/device   ; circle TEXT
; 
;   Restrictions:
;      assume 2 images are same dimmensions and that difference activity
;      between images is ~spacially restricted such as a single xyouts call
;
;   History:
;      28-Feb-2002 - S.L.Freeland - for WWW interaction with things 
;                    like utplot and plot_map annotations.
;

if data_chk(bef_2d,/nimag) ne 1 or data_chk(aft_2d,/nimage) ne 1 then begin 
   box_message,'Need two input images (before and after plot activity)
   return,-1
endif

if data_chk(bef_2d,/nx) ne data_chk(aft_2d,/nx) or $
   data_chk(bef_2d,/ny) ne data_chk(aft_2d,/ny) then begin 
   box_message,'Input images must have identical dimensions'
   return,-1
endif

; define some keywords/defaults
string_out=keyword_set(string_out)
convertit=1-keyword_set(noconvert)     ; default is IMAP convention 
debug=keyword_set(debug)

; make the "diff" image (boolean -  changed?)
dimage=bef_2d ne aft_2d                
rowtot=total(dimage,1)
coltot=total(dimage,2)

rtot=rotate(rowtot,([0,3])(convertit)) 
retval=[min(where(coltot)-1),min(where(rtot)-1), $
        max(where(coltot)+1),max(where(rtot)+1)]
      
if keyword_set(circle) then begin
   if debug then stop,'circle'
   diam=max([abs(retval(2)-retval(0)), $
             abs(retval(3)-retval(1))])
   xc=average([retval(0),retval(2)])
   yc=average([retval(1),retval(3)])
   retval=call_function((['float','round'])(convertit),[xc,yc,diam])
endif

if string_out then retval=arr2str(round(retval),/compress,/no_dup,/trim)
if debug then stop,'prereturn'
return,retval
end
