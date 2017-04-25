;+
; NAME
;	IMAGE_REGISTER
; PURPOSE:
;	Widget-based program to determine the geometric registration 
;       between two images of the same scene. Uses affine transformations 
;       to calculate relative scaling, rotation, displacement, and shear.
;
; CALLING SEQUENCE:
;	image_register,im1,im2,x,xp
; INPUTS:
;	im1 - image 1, defined as the "reference image"
;       im2 - image 2, image to be aligned/scaled/rotated to image 1.
;             
; OUTPUT:
;	x   - vector of points [2,N] where [0,N] are the x-values of
;             reference tie points selected by the user and [1,N} are
;             the y-values. 
;	xp  - vector of identical points located by the user in image2.
;
; KEYWORDS:
;       center - not implemented yet.
;
;       output - STRING filename. If set, program writes X and XP to 
;                the file specified by the string filename.
;
; USEAGE:
;       Upon calling, a widget with four display areas opens. In the 
;       left half of the widget the reference image (im1) is displayed
;       with a 4X zoom in the zoom window. In the right half, im2 is
;       similarly displayed. The user selects a point in im1 using 
;       the mouse and the left button. The user then finds this exact
;       same point in im2 and selects it using the mouse. For a robust
;       solution, usually more than 10 points are required.
;
;       If an incorrect selection is made, use the EDIT>Undo Selection
;       menu item.
;  
;       To see the points selected use the DISPLAY>selections menu
;       item.
;
;       To print the current solution in the active IDL window, use
;       the TRANSFORM>affine menu selection. Repeat this step periodically
;       during the selection process to see if the solution is converging.
;       In some cases, mis-paired points may cause the solution to
;       converge to erroneous values; this requires a restart of the 
;       procedure.
;
; NOTES:
;       Uses AFFINE_SOLVE.PRO to determine the affine transformation
;
; REVISION HISTORY:
;	Written    T. Berger              20-April-1998
;-
;=============================================================
        PRO Image_Register_event, event

;The main event handler called by XManager. "event" is a 
;structure returned by a the WIDGET_EVENT function within
;XManager.
;=============================================================

COMMON im_register,       $
  im1, im1_x0, im1_y0,    $     ;Image 1 and its dimensions.
  im2, im2_x0, im2_y0,    $     ;Image 2 and its dimensions.
  xyvis1, xyvis2,         $     ;Coordinates of draw windows (LL corner).
  magn1, magn2,           $     ;Current magnification of images 1 and 2.
  draw1id,draw2id,	  $	;Window IDs for display widgets.
  det1id, det2id,         $     ;Window IDs for detail displays.
  winsz,                  $     ;Size of the draw windows.
  outfile,unitnum,        $     ;Output file flag and unit number.
  mouseflag,xymouse,      $     ;Flag and position of mouse.
  x1, y1, x1flag,         $     ;Selected points in image 1 and flag.
  x2, y2, x2flag,         $     ;ditto for image 2.
  xr, xpr,                $     ;Returned arrays.
  detsz                         ;Size of detail windows

COMMON widget_ids,        $
  irbase,                 $     ;Main base ID.
  draw1, draw2,           $     ;Drawing areas.  
  detail1, detail2,       $     ;Detail view areas.
  text1x, text1y,         $     ;Text output areas for image 1.
  text2x, text2y                ;ditto for image 2.

WIDGET_CONTROL, event.id, GET_UVALUE=uval

;print,'Event: ', event
;print,'uval = ', uval

case uval of

  'menu': case event.value of

      'File.Save': begin         
          
          
      end
      'File.Save As': begin         
          
          
      end	
      'File.Exit': begin        ;close the points pairs output file if still open.
          if outfile eq 1 then CLOSE,unitnum 
          WIDGET_CONTROL, event.top, /DESTROY
      end
      'Edit.Undo Selection': begin         
          if x1flag eq 1 then begin
              nel = (SIZE(x1))[1]
              badx = x1[nel-1]
              bady = y1[nel-1]
              PRINT,badx,bady,': Selection removed. Reselect in Image 1.'
              x1 = x1[0:nel-2]
              y1 = y1[0:nel-2]
              x2flag = 1
          end else begin
              nel = (SIZE(x2))[1]
              badx = x2[nel-1]
              bady = y2[nel-2]
              PRINT,badx,bady,': Selection removed. Reselect in Image 2.'
              x2 = x2[0:nel-2]
              y2 = y2[0:nel-2]
              x1flag  = 1
          end 
      end	
      'Display.Selections.Print': begin
          npts = (SIZE(x1))[1]
          if npts gt 1 then begin
              x1t = x1[1:*]
              y1t = y1[1:*]
              x2t = x2[1:*]
              y2t = y2[1:*]
              PRINT,''
              PRINT,'Selections so far:'
              PRINT,''
              PRINT,'      IMAGE 1                  IMAGE 2'
              for i=0,npts-2 do begin
                  sx1 = STRCOMPRESS(x1t[i],/re)
                  sy1 = STRCOMPRESS(y1t[i],/re)
                  sx2 = STRCOMPRESS(x2t[i],/re)
                  sy2 = STRCOMPRESS(y2t[i],/re)
                  PRINT,'( ',sx1,', ',sy1,' )','     ( ',sx2,', ',sy2,' )'
              end
              PRINT,''
          end else PRINT,'No points selected yet.'
      end	
      'Display.Selections.Circle': begin         
          npts1 = (SIZE(x1))[1]
          npts2 = (SIZE(x2))[1]
          if npts1 gt 1 and npts2 gt 1 then begin
              x1t = x1[1:*]
              y1t = y1[1:*]
              x2t = x2[1:*]
              y2t = y2[1:*]
              WSET,draw1id
              for i=0,npts1-2 do TVCIRCLE,10,x1t[i]*magn1,y1t[i]*magn1,color=200
              WSET,draw2id
              for i=0,npts2-2 do TVCIRCLE,10,x2t[i]*magn2,y2t[i]*magn2,color=200
          end else PRINT,'Not enough points selected yet.'
      end	
      'Display.Selections.Highlight': begin         
          npts1 = (SIZE(x1))[1]
          npts2 = (SIZE(x2))[1]
          if npts1 gt 1 and npts2 gt 1 then begin
              x1t = x1[1:*]
              y1t = y1[1:*]
              x2t = x2[1:*]
              y2t = y2[1:*]
              WSET,draw1id
              for i=0,npts1-2 do PLOTS,[x1t[i]*magn1],[y1t[i]*magn1], $
                psym=4,thi=2,syms=0.2*magn1,color=200,/dev
              WSET,draw2id
              for i=0,npts2-2 do PLOTS,[x2t[i]*magn2],[y2t[i]*magn2],  $
                psym=4,thi=2,syms=0.2*magn2,color=200,/dev
          end else PRINT,'Not enough points selected yet.'       
      end	
      'Display.Color Table.Xloadct...': XLOADCT        
      'Display.Color Table.XPalette...': XPALLETE       
      'Transform.Affine': begin
          npts = N_ELEMENTS(x1)
          if npts gt 1 then begin
              x1t = x1[1:*]
              y1t = y1[1:*]
              x2t = x2[1:*]
              y2t = y2[1:*]
              x = [[x1t],[y1t]]
              xp = [[x2t],[y2t]]
              affine_solve,x,xp,/verb
          end else PRINT,'No points selected yet.'
      end
  end

  'menu1': case event.value of 

      'Zoom.1:4': begin
          IR_redraw, draw1, 0.25
      end
      'Zoom.1:2': begin
          IR_redraw, draw1, 0.5
      end
      'Zoom.1:1': begin
          IR_redraw, draw1, 1.0
      end
      'Zoom.2:1': begin
          IR_redraw, draw1, 2.0
      end
      'Zoom.4:1': begin
          IR_redraw, draw1, 4.0
      end
      'Zoom.8:1': begin
          IR_redraw, draw1, 8.0
      end
      'Move.Image Center':begin
          xyvis1[0] = im1_x0/2*magn1-winsz/2
          xyvis1[1] = im1_y0/2*magn1-winsz/2
          WIDGET_CONTROL,draw1,SET_DRAW_VIEW=xyvis1               
      end
      'Move.Mouse...':begin
          PRINT,'Image centers on next mouse down...'
          mouseflag = 1
      end
  end

  'menu2': case event.value of 

      'zoom.1:4': begin
          IR_redraw, draw2, 4
      end
      'Zoom.1:2': begin
          IR_redraw, draw2, 0.5
      end
      'Zoom.1:1': begin
          IR_redraw, draw2, 1.0
      end
      'Zoom.2:1': begin
          IR_redraw, draw2, 2.0
      end
      'Zoom.4:1': begin
          IR_redraw, draw2, 4.0
      end
      'Zoom.8:1': begin
          IR_redraw, draw2, 8.0
      end
      'Move.Image Center':begin
          xyvis2[0] = im2_x0/2*magn2-winsz/2
          xyvis2[1] = im2_y0/2*magn2-winsz/2
          WIDGET_CONTROL,draw2,SET_DRAW_VIEW=xyvis2               
      end
      'Move.Mouse...':begin
          PRINT,'Image centers on next mouse down...'
          mouseflag = 1
      end
  end

  'draw1': begin
      xm = FLOAT(event.x)/magn1
      ym = FLOAT(event.y)/magn1
      case event.type of
    
          0:begin ;only register point if previous pair is done and move.mouse is inactive.
              if x2flag eq 1 and mouseflag eq 0 then begin
                  x2flag = 0
                  PRINT,'Image 1: ',xm,ym
                  x1 = [x1,xm]
                  y1 = [y1,ym]
                  x1flag = 1
              end else if mouseflag eq 0 then  $
                PRINT,'Please select the previous point in Image 2.'
          end
      
          2: begin
              IR_detail,detail1, xm, ym
              strx = STRCOMPRESS(xm,/re)
              stry = STRCOMPRESS(ym,/re)
              WIDGET_CONTROL,text1x,SET_VALUE=strx
              WIDGET_CONTROL,text1y,SET_VALUE=stry
          end
          else:

      end
  end

  'draw2': begin
      xm = FLOAT(event.x)/magn2
      ym = FLOAT(event.y)/magn2
      case event.type of 
        
          0:begin 
            if x1flag eq 1 and mouseflag eq 0 then begin
                x1flag = 0
                PRINT,'Image 2: ',xm,ym
                PRINT,''
                x2 = [x2,xm]
                y2 = [y2,ym]
                x2flag = 1
            end else if maouseflag eq 0 then  $
              PRINT,'Please select a new point in Image 1.'
        end
      
        2: begin
            IR_detail,detail2,xm,ym
            strx = STRCOMPRESS(xm,/re)
            stry = STRCOMPRESS(ym,/re)
            WIDGET_CONTROL,text2x,SET_VALUE=strx
            WIDGET_CONTROL,text2y,SET_VALUE=stry
        end

        else:
      end
  end

      
end ;case uval


RETURN
END
;=============================================================
        PRO IR_Redraw, wid, mag, XCENTER=xcen, YCENTER=ycen

; Redispalys image after changes to MAG or ORIGIN
;=============================================================

COMMON im_register,       $
  im1, im1_x0, im1_y0,    $     ;Image 1 and its dimensions.
  im2, im2_x0, im2_y0,    $     ;Image 2 and its dimensions.
  xyvis1, xyvis2,         $     ;Coordinates of draw windows (LL corner).
  magn1, magn2,           $     ;Current magnification of images 1 and 2.
  draw1id,draw2id,	  $	;Window IDs for display widgets.
  det1id, det2id,         $     ;Window IDs for detail displays.
  winsz,                  $     ;Size of the draw windows.
  outfile,unitnum,        $     ;Output file flag and unit number.
  mouseflag,xymouse,      $     ;Flag and position of mouse.
  x1, y1, x1flag,         $     ;Selected points in image 1 and flag.
  x2, y2, x2flag,         $     ;ditto for image 2.
  xr, xpr,                $     ;Returned arrays.
  detsz                         ;Size of detail windows

COMMON widget_ids,        $
  irbase,                 $     ;Main base ID.
  draw1, draw2,           $     ;Drawing areas.  
  detail1, detail2,       $     ;Detail view areas.
  text1x, text1y,         $     ;Text output areas for image 1.
  text2x, text2y                ;ditto for image 2.

if N_ELEMENTS(mag) eq 0 then mag = 1
if wid eq draw1 then begin
    wnum = draw1id
    xyvis = xyvis1
    factor = mag/magn1
    zim = im1
    xs = im1_x0
    ys = im1_y0
end else begin
    wnum = draw2id
    xyvis = xyvis2
    factor = mag/magn2
    zim = im2
    xs = im2_x0
    ys = im2_y0
end
;find center of window on current image or set request:
WIDGET_CONTROL, wid, GET_DRAW_VIEW=xyvis
if KEYWORD_SET(xcen) then xc = xcen else xc = xyvis[0]+winsz/2
if KEYWORD_SET(ycen) then yc = ycen else yc = xyvis[1]+winsz/2
;PRINT,xc,yc

;display zoomed image 
WIDGET_CONTROL, wid, DRAW_XSIZE=xs*mag, DRAW_YSIZE=ys*mag
WSET, wnum
WIDGET_CONTROL,/HOURGLASS
TVSCL, confac(zim,mag)
xc = xc*factor
yc = yc*factor
xyvis = [xc-winsz/2,yc-winsz/2]
WIDGET_CONTROL, wid, SET_DRAW_VIEW=xyvis

;update common block:
if wid eq draw1 then begin
    magn1 = mag
    xyvis1 = xyvis
end else begin
    magn2 = mag
    xyvis2 = xyvis
end

RETURN
END

;=============================================================
        PRO IR_Detail, wid, xm, ym

; Dispalys magnified image in detail window. 
; Constant update from mouse motion in main window.
;=============================================================

COMMON im_register,       $
  im1, im1_x0, im1_y0,    $     ;Image 1 and its dimensions.
  im2, im2_x0, im2_y0,    $     ;Image 2 and its dimensions.
  xyvis1, xyvis2,         $     ;Coordinates of draw windows (LL corner).
  magn1, magn2,           $     ;Current magnification of images 1 and 2.
  draw1id,draw2id,	  $	;Window IDs for display widgets.
  det1id, det2id,         $     ;Window IDs for detail displays.
  winsz,                  $     ;Size of the draw windows.
  outfile,unitnum,        $     ;Output file flag and unit number.
  mouseflag,xymouse,      $     ;Flag and position of mouse.
  x1, y1, x1flag,         $     ;Selected points in image 1 and flag.
  x2, y2, x2flag,         $     ;ditto for image 2.
  xr, xpr,                $     ;Returned arrays.
  detsz                         ;Size of detail windows

COMMON widget_ids,        $
  irbase,                 $     ;Main base ID.
  draw1, draw2,           $     ;Drawing areas.  
  detail1, detail2,       $     ;Detail view areas.
  text1x, text1y,         $     ;Text output areas for image 1.
  text2x, text2y                ;ditto for image 2.

;Constants:
d2 = detsz/4

xpad = 0
ypad = 0

CASE wid of

    detail1: begin
        winid = det1id
        d2 = d2/magn1
        d = 2*d2
        subim = BYTARR(d,d)
        xlo = (xm-d2+1)
        xhi = (xm+d2)
        if xlo lt 0 then xpad = d-xhi-1
        ylo = (ym-d2+1)
        yhi = (ym+d2)
        if ylo lt 0 then ypad = d-yhi-1
        subim(xpad,ypad) = BYTSCL( im1[(xlo>0):(xhi<(im1_x0-1)), (ylo>0):(yhi<(im1_y0-1))] )
    end
    
    detail2: begin
        winid = det2id
        d2 = d2/magn2
        d = 2*d2
        subim = BYTARR(d,d)
        xlo = (xm-d2+1)
        xhi = (xm+d2) 
        if xlo lt 0 then xpad = d-xhi-1
        ylo = (ym-d2+1)
        yhi = (ym+d2)
        if ylo lt 0 then ypad = d-yhi-1
        subim(xpad,ypad) = BYTSCL( im2[(xlo>0):(xhi<(im2_x0-1)), (ylo>0):(yhi<(im2_y0-1))] )
    end
end

WSET,winid
TVSCL,CONGRID(subim,detsz,detsz)
TVCIRCLE,20,detsz/2,detsz/2,color=200
PLOTS,[0,detsz-1],[detsz/2,detsz/2],color=200,/device
PLOTS,[detsz/2,detsz/2],[0,detsz-1],color=200,/device

RETURN
END

;=========================================================================+
	PRO Image_Register, image1, image2, xret, xpret, $
                           CENTER=xycen, OUTPUT=output

; MAIN PROGRAM: Creates the main window widget and registers it with XManager.

;=========================================================================+

COMMON im_register,       $
  im1, im1_x0, im1_y0,    $     ;Image 1 and its dimensions.
  im2, im2_x0, im2_y0,    $     ;Image 2 and its dimensions.
  xyvis1, xyvis2,         $     ;Coordinates of draw windows (LL corner).
  magn1, magn2,           $     ;Current magnification of images 1 and 2.
  draw1id,draw2id,	  $	;Window IDs for display widgets.
  det1id, det2id,         $     ;Window IDs for detail displays.
  winsz,                  $     ;Size of the draw windows.
  outfile,unitnum,        $     ;Output file flag and unit number.
  mouseflag,xymouse,      $     ;Flag and position of mouse.
  x1, y1, x1flag,         $     ;Selected points in image 1 and flag.
  x2, y2, x2flag,         $     ;ditto for image 2.
  xr, xpr,                $     ;Returned arrays.
  detsz                         ;Size of detail windows

COMMON widget_ids,        $
  irbase,                 $     ;Main base ID.
  draw1, draw2,           $     ;Drawing areas.  
  detail1, detail2,       $     ;Detail view areas.
  text1x, text1y,         $     ;Text output areas for image 1.
  text2x, text2y                ;ditto for image 2.


;ON_ERROR,2

;check for previous registration: because of common block, can only have one 
;realization of XYView operating at a time.
if (Xregistered('Image_Register') ne 0) then MESSAGE,'Widget is already registered'

if N_ELEMENTS(image1) eq 0 then im1=DIST(512,512) else im1 = image1
if N_ELEMENTS(image2) eq 0 then im2=DIST(512,512) else im2 = image2
sz1 = SIZE(im1)
sz2 = SIZE(im2)
if sz1[0] ne 2 or sz2[0] ne 2 then MESSAGE,'One or both of the input images is not 2-D: returning'

;Initialize output state:
outfile = 0
if KEYWORD_SET(output) then begin
    outfile = 1
    OPENW,unitnum,STRING(output),/GET_LUN
end

;Initialize the selected points array (1-D coordinates):
x1 = [-1.]
x2 = x1
y1 = [-1.]
y2 = y1
x1flag=0
x2flag=1
mouseflag=0

;Widget creation:
;1. Main base:
irbase = WIDGET_BASE( TITLE='Image Registration', MBAR=bar )
pdstruct = {flags:0,name:''}
desc = REPLICATE(pdstruct,17)
desc.flags=[1,0,0,2, 1,2, 1,1,0,0,2,1,0,2,2, 1,2]
desc.name=[ 'File', $
                'Save', 'Save As', 'Exit',$
            'Edit', $
                'Undo Selection',$
            'Display', $
                'Selections', $
                    'Print','Circle','Highlight',$
                'Color Table', $
                     'Xloadct...', 'XPalette...', '', $
            'Transform',$
                'Affine']  
	
mainmenu = CW_PDMENU( bar, desc, /RETURN_FULL_NAME, UVALUE='menu', /MBAR )


;2. Display areas: main windows are 480x480 pixels, detail windows are 256x256
minsz = 380
winsz = 480
detsz = 256

im1_x0 = sz1[1]
im1_y0 = sz1[2]
magn1 = 1
im1s = MIN([im1_x0,im1_y0],xymin1)

im2_x0 = sz2[1]
im2_y0 = sz2[2]
magn2 = 1
im2s = MIN([im2_x0,im2_y0],xymin2)
imin = MIN(im1s,im2s)
if imin lt minsz then winsz = minsz else minsz = winsz

drawbase = WIDGET_BASE( irbase, GROUP_LEADER=irbase, /FRAME,/ROW )

desc2 = REPLICATE(pdstruct,11)
desc2.flags = [1,0,0,0,0,0,2, 1,0,0,2]
desc2.name = ['Zoom',$
                   '1:4','1:2','1:1','2:1','4:1','8:1',$
              'Move',$
                   'Image Center','Mouse...','Enter...']	

;Image 1 windows and controls
draw1_base = WIDGET_BASE( drawbase, GROUP_LEADER=drawbase, /COLUMN)
junk = WIDGET_LABEL( draw1_base,VALUE='Reference Image' ) 
draw1 = WIDGET_DRAW( draw1_base, RETAIN=2, GRAPHICS_LEVEL=1, $
                     XSIZE=im1_x0, YSIZE=im1_y0, FRAME=2,$
                     /BUTTON_EVENTS, /MOTION_EVENTS, UVALUE = 'draw1', $
                     /SCROLL, X_SCROLL_SIZE=winsz, Y_SCROLL_SIZE=winsz)
low1 = WIDGET_BASE( draw1_base, /ALIGN_LEFT, GROUP_LEADER=irbase,/ROW)
con1 = WIDGET_BASE( low1, GROUP_LEADER=irbase,/COL)
menu1 = CW_PDMENU( con1, desc2, /RETURN_FULL_NAME, UVALUE='menu1' )
text1x = WIDGET_TEXT( con1, FRAME=0, SCR_XSIZE=100, UVALUE='text1x' )
text1y = WIDGET_TEXT( con1, FRAME=0, SCR_XSIZE=100, UVALUE='text1y' )
detail1 = WIDGET_DRAW( low1, RETAIN=2, GRAPHICS_LEV=1, $
                       SCR_XSIZE=256, SCR_YSIZE=256, FRAME=2, $
                       /BUTTON_EVENTS, UVALUE='det1')
;Image 2 windows and controls
draw2_base = WIDGET_BASE( drawbase, GROUP_LEADER=drawbase, /COLUMN) 
junk = WIDGET_LABEL( draw2_base, VALUE='Test Image' )
draw2 = WIDGET_DRAW( draw2_base, RETAIN=2, GRAPHICS_LEVEL=1, $
                     XSIZE=im2_x0, YSIZE=im2_y0, FRAME=2, $ 
                     /BUTTON_EVENTS, /MOTION_EVENTS, UVALUE = 'draw2', $
                     /SCROLL, X_SCROLL_SIZE=winsz, Y_SCROLL_SIZE=winsz )
low2 = WIDGET_BASE( draw2_base, /ALIGN_LEFT, GROUP_LEADER=irbase,/ROW )	
con2 = WIDGET_BASE( low2, GROUP_LEADER=irbase,/COL)
menu2 = CW_PDMENU( con2, desc2, /RETURN_FULL_NAME, UVALUE='menu2' )
text2x = WIDGET_TEXT( con2, FRAME=0, SCR_XSIZE=100, UVALUE='text2x' )
text2y = WIDGET_TEXT( con2, FRAME=0, SCR_XSIZE=100, UVALUE='text2y' )
detail2 = WIDGET_DRAW( low2, RETAIN=2, GRAPHICS_LEV=1, $
                       SCR_XSIZE=256, SCR_YSIZE=256, FRAME=2, $
                       /BUTTON_EVENTS, UVALUE='det2')


;4. Widget initialization and window number retrieval:
WIDGET_CONTROL, irbase, /REALIZE
WIDGET_CONTROL, draw1, GET_VALUE=draw1id
WIDGET_CONTROL, draw1, GET_DRAW_VIEW=xyvis1
WIDGET_CONTROL, detail1, GET_VALUE=det1id
ir_redraw,draw1
ir_detail,detail1,winsz/2,winsz/2

WIDGET_CONTROL, draw2, GET_VALUE=draw2id
WIDGET_CONTROL, draw2, GET_DRAW_VIEW=xyvis2
WIDGET_CONTROL, detail2, GET_VALUE=det2id
ir_redraw,draw2
ir_detail,detail2,winsz/2,winsz/2

XMANAGER, 'Image_Register', irbase, NO_BLOCK=0

print,''
print,'End of Image_Register'

if N_ELEMENTS(x1) gt 1 then begin
    xret = [[x1[1:*]],[y1[1:*]]]
    xpret = [[x2[1:*]],[y2[1:*]]]
    if outfile then begin
        PRINTF,unitnum,xret
        PRINTF,unitnum,xpret
        FREE_LUN,unitnum
    end
end else PRINT,'No points selected - returning nothing.'

RETURN
END

