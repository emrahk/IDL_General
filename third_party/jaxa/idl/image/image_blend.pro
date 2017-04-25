;+
; NAME:
;       IMAGE_BLEND
;
; PURPOSE:
;       The purpose of this program is to demonstrate how to
;       use the alpha channel to blend one image into another.
;       The specific purpose is to see a color image on top of
;       a gray-scale image, with the gray-scale image showing
;       through behind the color image.
;
; AUTHOR:
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Widgets, Object Graphics.
;
; CALLING SEQUENCE:
;
;       Image_Blend
;
; REQUIRED INPUTS:
;
;       None. The images "worldelv.dat" and "ctscan.dat" from the
;       examples/data directory are used.
;
; OPTIONAL INPUTS:
;
;       backgroundImage::  A 2D image variable that will be used for the background image.
;       foregroundImage:   A 2D image variable that will be used for the foreground image.
;
; OPTIONAL KEYWORD PARAMETERS:
;
;       COLORTABLE: The number of a color table to use for the foreground image.
;       Color table 3 (red temperature) is used as a default.
;
;       DIMENSIONS: window dimensions (def = [512,512])
;
; COMMON BLOCKS:
;
;       None.
;
; SIDE EFFECTS:
;
;       None.
;
; RESTRICTIONS:
;
;       None. The program XCOLORS is required from the Coyote library.
;
; EXAMPLE:
;
;       Image_Blend, Colortable=5
;
; MODIFICATION HISTORY:
;
;       Written by David Fanning, 30 March 99.
;       Fixed bug where I redefined the image parameter. Duh... 1 April 99. DWF.
;       Moved the program into the 21st century. :-) 21 March 2003. DWF.
;       Added TIFF, GIF (if version supports it), and PS output. 27
;       December 2006. DWF.
;       Added DIMENSIONS keyword. 3 April 2007, Zarro (ADNET)
;-
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 1999-2006 Fanning Software Consulting
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################


PRO Image_Blend_Output, event

   ; This event handler creates PNG and JPEG files.

Widget_Control, event.top, Get_UValue=info, /No_Copy

   ; Get a snapshop of window contents. (TVRD equivalent.)

Wait, 0.5 ; Give the pull-down menu time to snap back.
info.thisWindow->GetProperty, Image_Data=snapshot

   ; JPEG or PNG file wanted?

Widget_Control, event.id, Get_UValue=whichFileType
CASE whichFileType OF

   'GIF': BEGIN

      filename = Dialog_Pickfile(/Write, File='idl.gif')
      image2D = Color_Quan(snapshot, 1, r, g, b, COLORS=256)
      IF filename NE '' THEN Write_GIF, filename, image2d, r, g, b
      END

   'PNG': BEGIN

      filename = Dialog_Pickfile(/Write, File='idl.png')
      IF filename NE '' THEN Write_PNG, filename, snapshot
      END

   'PS': BEGIN

      filename = Dialog_Pickfile(/Write, File='idl.eps')
      IF filename EQ '' THEN  RETURN
      dims = info.thisWindow -> GetDimensions()
      aspect = Float(dims[1]) / dims[0]
      IF aspect GT 1.0 THEN BEGIN
         width = 6.0
         height = 7.0/aspect
      ENDIF ELSE BEGIN
         height = 6
         width = 6.0 * aspect
      ENDELSE
      dimensions = [width, height] * 2.54
      clipboard = Obj_New("IDLgrClipboard", Dimensions=dimensions, Units=2)
      clipboard -> Draw, info.thisView, Filename=filename, /PostScript
      Obj_Destroy, clipboard
      END

   'JPEG': BEGIN

      filename = Dialog_Pickfile(/Write, File='idl.jpg')
      IF filename NE '' THEN Write_JPEG, filename, snapshot, True=1
      END

   'TIFF': BEGIN
      filename = Dialog_Pickfile(/Write, File='idl.tif')
      IF filename NE '' THEN Write_TIFF, filename, Reverse(snapshot,3)
      END

ENDCASE

    ;Put the info structure back.

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;-------------------------------------------------------------------



PRO Image_Blend_Exit, event

   ; Exit the program via the EXIT button.
   ; The Image_Blend_CLEANUP procedure will be called automatically.

Widget_Control, event.top, /Destroy
END
;-------------------------------------------------------------------



PRO Image_Blend_Foreground_Colors, event

    ; This event handler changes foreground image colors.

Widget_Control, event.top, Get_UValue=info, /No_Copy

    ; Is this an XCOLORS event?

thisEvent = Tag_Names(event, /Structure_Name)
IF thisEvent EQ 'XCOLORS_LOAD' THEN BEGIN

   ; Set the color palette with the new colors.

   s = Size(*info.foregroundImage, /Dimensions)
   alpha_image = BytArr(4, s[0], s[1])
   alpha_image[0,*, *] = event.r[*info.foregroundImage]
   alpha_image[1,*, *] = event.g[*info.foregroundImage]
   alpha_image[2,*, *] = event.b[*info.foregroundImage]
   Widget_Control, info.sliderID, Get_Value=currentBlend
   alpha_image[3, *, *] = info.blendMask * currentBlend
   info.alphaImage->SetProperty, Data=alpha_image
   info.thisWindow->Draw, info.thisView

ENDIF ELSE XColors, NotifyID=[event.id, event.top], $
   Group_Leader=event.top, Title='Foreground Image Colors', $
   XOffset=100, YOffset=100
Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;---------------------------------------------------------------------



PRO Image_Blend_Background_Colors, event

    ; This event handler changes background image colors.

Widget_Control, event.top, Get_UValue=info, /No_Copy

    ; Is this an XCOLORS event?

thisEvent = Tag_Names(event, /Structure_Name)
IF thisEvent EQ 'XCOLORS_LOAD' THEN BEGIN

   ; Set the color palette with the new colors.

   info.grayPalette->SetProperty, Red=event.r, Green=event.g, Blue=event.b
   info.thisWindow->Draw, info.thisView

ENDIF ELSE XColors, NotifyID=[event.id, event.top], $
   Group_Leader=event.top, Title='Background Image Colors', $
   XOffset=100, YOffset=200
Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;---------------------------------------------------------------------



PRO Image_Blend_CleanUp, id

    ; Come here when the widget dies. Free all the program
    ; objects, pointers, pixmaps, etc. and release memory.

Widget_Control, id, Get_UValue=info
IF N_Elements(info) NE 0 THEN BEGIN
   Obj_Destroy, info.thisContainer
   Ptr_Free, info.foregroundImage
ENDIF
END
;---------------------------------------------------------------------



PRO Image_Blend_Slider, event

    ; This event handler sets the blending values.

Widget_Control, event.top, Get_UValue=info, /No_Copy

    ; Set the blend value.

info.alphaImage->GetProperty, Data=thisData
s = Size(*info.foregroundImage, /Dimensions)
thisData[3, *, *] = info.blendMask * event.value
info.alphaImage->SetProperty, Data=thisData
info.thisWindow->Draw, info.thisView

    ;Put the info structure back.

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;---------------------------------------------------------------------



PRO Image_Blend_Expose, event

    ; This event handler responds to draw widget expose events..

Widget_Control, event.top, Get_UValue=info, /No_Copy

   ; Redisplay the graphic.

info.thisWindow->Draw, info.thisView

    ;Put the info structure back.

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;---------------------------------------------------------------------



PRO Image_Blend_Event, event

    ; This is main event handler for the TLB. It currently
    ; handles resize events.

Widget_Control, event.top, Get_UValue=info, /No_Copy

    ; Resize the draw widget.

info.thisWindow->SetProperty, Dimension=[event.x, event.y*info.drawScale+15]

   ; Redisplay the graphic.

info.thisWindow->Draw, info.thisView

    ;Put the info structure back.

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;---------------------------------------------------------------------



PRO Image_Blend, backgroundImage, foregroundImage, Colortable=colortable,$
                 dimensions=dimensions

if n_elements(dimensions) ne 2 then dimensions=[512,512]

    ; Get images to display

IF N_Elements(backgroundImage) EQ 0 THEN BEGIN
   filename = Filepath(SubDir=['examples', 'data'], 'worldelv.dat')
   OpenR, lun, filename, /Get_LUN
   backgroundImage = BytArr(360,360)
   ReadU, lun, backgroundImage
   Free_Lun, lun
ENDIF

IF N_Elements(foregroundImage) EQ 0 THEN BEGIN
   filename = Filepath(SubDir=['examples', 'data'], 'ctscan.dat')
   OpenR, lun, filename, /Get_LUN
   foregroundImage = BytArr(256,256)
   ReadU, lun, foregroundImage
   Free_Lun, lun
ENDIF

IF N_Elements(colortable) EQ 0 THEN colortable = 3

    ; Create the gray color palette.

grayPalette = Obj_New('IDLgrPalette')
grayPalette->LoadCT, 0

   ; The foreground image must be 24-bit for alpha blending to work.

s = Size(foregroundImage, /Dimensions)
alpha_image = BytArr(4, s[0], s[1])
LoadCT, colortable
TVLCT, r, g, b, /Get
alpha_image[0, *, *] = r[foregroundImage]
alpha_image[1, *, *] = g[foregroundImage]
alpha_image[2, *, *] = b[foregroundImage]

   ; Pixels with value 0 with be totally transparent.
   ; Other pixels will start out half transparent.

blendMask = BytArr(s[0], s[1])
blendMask[Where(foregroundImage GT 0)] = 1B
alpha_image[3, *, *] = blendMask * 128B

backgroundImgObj = Obj_New('IDLgrImage', backgroundImage, $
   Dimensions=dimensions, Palette=grayPalette)

alphaImage = Obj_New('IDLgrImage', alpha_image, $
   Dimensions=dimensions, Interleave=0, $
   Blend_Func=[3,4])

   ; Create a model for the images. Add images to model.

thisModel = Obj_New('IDLgrModel')
thisModel->Add, backgroundImgObj
thisModel->Add, alphaImage

    ; Create a view.

viewRect = [0, 0, dimensions[0],dimensions[1]]
thisView = Obj_New('IDLgrView', Viewplane_Rect=viewRect)
thisView->Add, thisModel

    ; Create the widgets for this program.

tlb = Widget_Base(Title='Image Overlay Example', $
   MBar=menubase, TLB_Size_Events=1, Column=1)

drawID = Widget_Draw(tlb, XSize=dimensions[0], YSize=dimensions[1], $
   Graphics_Level=2, Expose_Events=1, Retain=0, $
   Event_Pro='Image_Blend_Expose')

   ; Create a slider widget to control the amount of
   ; transparency in the foreground image.

sliderID = Widget_Slider(tlb, Scr_XSize=406, Min=0, Max=255, $
   Value=128, Title='Opacity Control', Event_Pro='Image_Blend_Slider')

    ; Create FILE menu buttons for output and exiting.

filer = Widget_Button(menubase, Value='File', /Menu)

   ; Create OUTPUT menu buttons for formatted output files.

output = Widget_Button(filer, Value='Output', /Menu)
IF Float(!Version.Release) GE 6.2 THEN BEGIN
   b = Widget_Button(output, Value='GIF File', $
      UValue='GIF', Event_Pro='Image_Blend_Output')
ENDIF
b = Widget_Button(output, Value='PNG File', $
   UValue='PNG', Event_Pro='Image_Blend_Output')
b = Widget_Button(output, Value='JPEG File', $
   UValue='JPEG', Event_Pro='Image_Blend_Output')
b = Widget_Button(output, Value='TIFF File', $
   UValue='TIFF', Event_Pro='Image_Blend_Output')
b = Widget_Button(output, Value='Encapsulated PS File', $
   UValue='PS', Event_Pro='Image_Blend_Output')
b = Widget_Button(filer, Value='Quit', /Separator, $
   Event_Pro='Image_Blend_Exit')

   ; Create a colors menu.

colors = Widget_Button(menubase, Value='Colors', /Menu)
b = Widget_Button(colors, Value='Foreground Image Colors', $
   Event_Pro='Image_Blend_Foreground_Colors')
b = Widget_Button(colors, Value='Background Image Colors', $
   Event_Pro='Image_Blend_Background_Colors')

   ; Get geometry information for resizing.

tlbGeo = Widget_Info(tlb, /Geometry)
drawGeo = Widget_Info(drawID, /Geometry)
drawScale = Float(drawGeo.Scr_YSize) / tlbGeo.YSize

    ; Realize the widgets and get the window object.

Widget_Control, tlb, /Realize
Widget_Control, drawID, Get_Value=thisWindow

thisWindow->Draw, thisView

   ; Create a container object to hold all the other
   ; objects. This will make it easy to free all the
   ; objects when we are finished with the program.

thisContainer = Obj_New('IDL_Container')
thisContainer->Add, backgroundImgObj
thisContainer->Add, thisWindow
thisContainer->Add, thisModel
thisContainer->Add, grayPalette
thisContainer->Add, thisView

    ; Create an info structure to hold program information.

info = { thisContainer:thisContainer, $              ; The container object.
         thisWindow:thisWindow, $                    ; The window object.
         alphaImage:alphaImage, $                    ; The foreground image object.
         foregroundImage:Ptr_New(foregroundImage), $ ; The original foreground image.
         blendMask:blendMask, $                      ; A mask for screening blending values.
         grayPalette:grayPalette, $                  ; The background image palette.
         drawScale:drawScale, $                      ; The draw widget scaling factor.
         drawID:drawID, $                            ; The draw widget identifier.
         sliderID:sliderID, $                        ; The slider widget identifier.
         thisView:thisView}                          ; The object view.

Widget_Control, tlb, Set_UValue=info, /No_Copy

XManager, 'Image_Blend', tlb, Cleanup='Image_Blend_Cleanup', $
   Group_Leader=group, /No_Block
END
