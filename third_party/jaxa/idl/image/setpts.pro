
pro setpts,p,ima,imr,trima=trima,plotonly=pflg,noscale=tvflg,append=aflg, $
           key=ttyp

;+
;NAME:
;       SETPTS
;PURPOSE:
;       Interactively define reference points in two images.
;       These points can be used to calculate a linear transform which maps
;       image ima onto the comparison image imb.
;       After the points have been entered, image ima is transformed and
;       displayed with contours on top of image imb.
;CATEGORY:
;       Image processing.
;CALLING SEQUENCE:
;       setpts, p, ima, imr
;INPUTS:
;       ima = image to be transformed.
;       imr = reference image.
;             Usually, the lower resolution image is selected to be image ima.
;OPTIONAL (KEYWORD) INPUT PARAMETERS:
;       plotonly = flag. If this keyword parameter is present, no new points
;                  are added to p, but the result of the linear transform is
;                  displayed.
;       noscale = flag.  If present, the images are displayed unscaled.
;       append = flag.  If present, new points are appended to p if p exists
;                and contains points.  The default is to discard old points.
;       trima = transformed image ima.
;       key = transformation type.  See "transtype" keyword in CALTRANS for
;             details.  Default is a general linear transform.
;OUTPUTS:
;       p = array(2,2,*). p(0,0,*) and p(1,0,*) are the x and y coordinates
;           of the points in the reference image imb. p(0,1,*) and p(1,1,*)
;           are the x and y cordinates of the same points in the image ima.
;OPTIONAL (KEYWORD) OUTPUT PARAMETERS:
;       trima = transformed version of ima
;COMMON BLOCKS:
;       None.
;SIDE EFFECTS:
;       The program creates a new BIG graphics window.
;       After entering the procedure, follow the instructions printed
;       on the terminal.
;RESTRICTIONS:
;       The images have to be 2-dimensional. 
;MODIFICATION HISTORY:
;       JPW, Nov, 1989.
;       JPW, Aug, 1992  most changes from version 1.1 (GLS) adopted
;       JPW, Sep, 1992  added the noscale and append flags.
;       JPW, Jun, 1994  points plotted also with /plotonly option
;                       added key option
;       JPW, Nov, 1994  fixed some minor glitches
;       T. Metcalf, 2002 Apr 8, Remove the max 512 image size restriction.
;                               Should now work with any image size.
;-

; Get screen size

device,get_screen_size=scrsz

xmax = scrsz[0]
ymax = xmax/2

; create window if necessary
if (!d.window lt 0) or (!d.x_size ne xmax) or (!d.y_size ne ymax) then $
   window,/free,retain=2,title='left : image   right : reference', $
          xsize=xmax,ysize=ymax
erase

; display reference image (imr)
sizr = size(imr)
zomr=float([ymax,ymax])/max(sizr(1:2))
rnx = long(sizr(1)*zomr(0)+0.5)
rny = long(sizr(2)*zomr(1)+0.5)

if keyword_set(tvflg) then $
   tv,congrid(imr,rnx,rny,/interp),ymax,0 else $
   tvscl,congrid(imr,rnx,rny,/interp),ymax,0

; display image to be transformed (ima)
siza = size(ima)
zoma=float([ymax,ymax])/max(siza(1:2))
anx = long(siza(1)*zoma(0)+0.5)
any = long(siza(2)*zoma(1)+0.5)
if keyword_set(tvflg) then $
   tv,congrid(ima,anx,any,/interp),0,0 else $
   tvscl,congrid(ima,anx,any,/interp),0,0

if ((not keyword_set(aflg)) and (not keyword_set(pflg))) then p=0

; display existing points
if n_elements(p) ge 4 then begin
  for i=0,n_elements(p)/4-1 do begin
     ax=fix(p(0,1,i)*zoma(0))
     ay=fix(p(1,1,i)*zoma(1))
     rx=fix(p(0,0,i)*zomr(0))+ymax
     ry=fix(p(1,0,i)*zomr(1))
     plots,ax,ay,/device,psym=6
     xyouts,ax,ay,device=1,string(i,format='(i2)')
     plots,rx,ry,device=1,psym=6
     xyouts,rx,ry,device=1,string(i,format='(i2)')
  endfor
endif

; loop
if not keyword_set(pflg) then begin
 print,'Click on feature in left hand image using left hand mouse key.'
 print,'Then click on corresponding feature in right hand image.'
 print,'When finished entering points, click on right hand mouse key.'
 i = n_elements(p)/4
 repeat begin

   repeat begin
      cursor,ax,ay,/down,/device
      if (ax ge ymax) and (!err eq 1) then begin
         print,'\007'	; Ring the bell
         print,'wrong image, try again in left hand image '
         flg1 = 0
      endif else flg1 = 1
   endrep until (flg1 eq 1) or (!err gt 1)

   if (!err eq 1) then begin
     plots,ax,ay,/device,psym=6
     xyouts,ax,ay,device=1,string(i,format='(i2)')
     repeat begin
        cursor,rx,ry,/down,/device
        if rx lt ymax then begin
           print,'\007'	; Ring the bell
           print,'wrong image, try again in right hand image '
           flg1 = 0
        endif else flg1 = 1
     endrep until flg1 eq 1
     plots,rx,ry,device=1,psym=6
     xyouts,rx,ry,device=1,string(i,format='(i2)')

     if n_elements(p) lt 4 then begin
        p = [[float(rx-ymax)/zomr(0),float(ry)/zomr(1)], $
             [float(ax)/zoma(0),float(ay)/zoma(1)]]
        p = reform(p,2,2,1)                 ; make p 3-dimensional
     endif else begin
        p = [[[p]],[[float(rx-ymax)/zomr(0),float(ry)/zomr(1)], $
                    [float(ax)/zoma(0),float(ay)/zoma(1)]]]
     endelse
     print,'Total features entered = ',n_elements(p)/4
     i = i+1
   endif
 endrep until (!err gt 1)
endif

; calculate transform and plot contours of transformed image onto ref
m = caltrans(p,/residuals,transtype=ttyp)
trima = poly_2d(ima,m(*,0),m(*,1),1,sizr(1),sizr(2))
contour,trima,/noerase,/device,nlevels=8,xstyle=5,ystyle=5, $
   position=[ymax,0,ymax+(sizr(1)-1)*zomr(0),(sizr(2)-1)*zomr(1)]

end

