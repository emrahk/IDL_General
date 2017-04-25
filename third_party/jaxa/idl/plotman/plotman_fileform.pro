PRO plotman_fileform_event, event

WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
WIDGET_CONTROL, event.id, GET_UVALUE=thisEvent
CASE thisEvent OF

   'SELECT_FILE': BEGIN

         ; Start in the current directory.

      CD, Current=startDirectory

         ; Use PICKFILE to pick a filename for writing.

      pick = Dialog_Pickfile(Path=startDirectory, /NoConfirm, $
         Get_Path=path, /Write)

         ; Make sure the user didn't cancel out of PICKFILE.

      IF pick NE '' THEN Widget_Control, info.filenameID, Set_Value=pick
      END ; of the Select Filename button case

    'CANCEL': BEGIN

         ; Have to exit here gracefully. Set CANCEL field in structure.

       formdata = {cancel:1, create:0}
       *info.ptr = formdata

         ; Out of here!

       Widget_Control, event.top, /Destroy
       RETURN
       END ; of the Cancel button case

    'ACCEPT': BEGIN  ; Gather the form information.

          ; Get the filename.

       Widget_Control, info.filenameID, Get_Value=filename

       filename = filename(0)

          ; Get the size info.

       Widget_Control, info.xsizeID, Get_Value=xsize
       Widget_Control, info.ysizeID, Get_Value=ysize

          ; Get the color info from the droplist widget.

       listIndex = Widget_Info(info.colordropID, /Droplist_Select)
       colortype = FIX(ABS(1-listindex))

          ; Get the order info from the droplist widget.

       order = Widget_Info(info.orderdropID, /Droplist_Select)
       order = FIX(order)

          ; Get the quality fromt he slider widget, if needed

       IF info.sliderID NE -1 THEN $
          Widget_Control, info.sliderID, Get_Value=quality ELSE quality=-1

          ; Create the formdata structure from the information you collected.

       formdata = {filename:filename, xsize:xsize, ysize:ysize, $
          color:colortype, order:order, quality:quality, create:0}

          ; Store the formdata in the pointer location.

       *info.ptr = formdata

         ; Out of here!

      Widget_Control, event.top, /Destroy
      RETURN
      END ; of the Accept button case

    'CREATE': BEGIN  ; Gather the form information.

          ; Get the filename.

       Widget_Control, info.filenameID, Get_Value=filename

       filename = filename(0)

          ; Get the size info.

       Widget_Control, info.xsizeID, Get_Value=xsize
       Widget_Control, info.ysizeID, Get_Value=ysize

          ; Get the color info from the droplist widget.

       listIndex = Widget_Info(info.colordropID, /Droplist_Select)
       colortype = FIX(ABS(1-listindex))

          ; Get the order info from the droplist widget.

       order = Widget_Info(info.orderdropID, /Droplist_Select)
       order = FIX(order)

          ; Get the quality fromt he slider widget, if needed

       IF info.sliderID NE -1 THEN $
          Widget_Control, info.sliderID, Get_Value=quality ELSE quality=-1

          ; Create the formdata structure from the information you collected.

       formdata = {filename:filename, xsize:xsize, ysize:ysize, $
          color:colortype, order:order, quality:quality, create:1}

          ; Store the formdata in the pointer location.

      *info.ptr = formdata

         ; Out of here!

      Widget_Control, event.top, /Destroy
      RETURN
      END ; of the Create button case

   ELSE:
ENDCASE

WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
END ; of plotman_fileform_event event handler ************************

;-----

FUNCTION plotman_fileform, filetype, config, TITLE=title, $
   XOFFSET=xoffset, YOFFSET=yoffset, Cancel=cancel, Create=create, $
   PARENT=parent

CATCH, error
IF error NE 0 THEN BEGIN
ok = WIDGET_MESSAGE(!Err_String)
RETURN, -1
ENDIF

IF N_ELEMENTS(filetype) EQ 0 THEN filetype = 'PNG'
IF N_ELEMENTS(config) EQ 0 THEN config = {XSIZE:400, YSIZE:400, $
   COLOR:1, FILENAME:'xwindow.png', NCOLORS:(!D.N_Colors < 256)}
filetype = STRUPCASE(filetype)
IF N_ELEMENTS(title) EQ 0 THEN title = 'Configure ' + $
   filetype + ' Output File'

   ; Check for placement offsets. Define defaults.

IF (N_ELEMENTS(xoffset) EQ 0) THEN BEGIN
   DEVICE, GET_SCREEN_SIZE=screenSize
   xoffset = (screenSize(0) - 200) / 2.
ENDIF
IF (N_ELEMENTS(yoffset) EQ 0) THEN BEGIN
   DEVICE, GET_SCREEN_SIZE=screenSize
   yoffset = (screenSize(1) - 100) / 2.
ENDIF

geom = widget_info (parent, /geometry)
if n_elements(xoffset) eq 0 then xoffset = geom.xoffset
if n_elements(yoffset) eq 0 then yoffset = geom.yoffset

   ; Create widgets.

tlb = WIDGET_BASE(Column=1, Title=title, XOffset=xoffset+50, $
   YOffset=yoffset+50, Base_Align_Center=1, /Modal, Group_Leader=parent)

bigbox = WIDGET_BASE(tlb, Column=1, Frame=1, Base_Align_Center=1)

   ; Create the filename widgets.
filebox = Widget_Base(bigbox, Column=1, Base_Align_Center=1)
filename = config.filename
filenamebase = Widget_Base(filebox, Row=1)
   filenamelabel = Widget_Label(filenamebase, Value='Filename:')
   filenameID = Widget_Text(filenamebase, Value=filename, /Editable, $
      Event_Pro='NULL_EVENTS', SCR_XSIZE=320)


   ; Create a button to allow user to pick a filename.

pickbutton = Widget_Button(filebox, Value='Select Filename', $
   UVALUE='SELECT_FILE')

   ; Create size widgets
sizebox = Widget_Base(bigbox, Column=1, Base_Align_Left=1)
sizebase = Widget_Base(sizebox, Row=1)
xsizeID = CW_FIELD(sizebase, Value=config.xsize, Title='XSize: ', $
   /Integer)
ysizeID = CW_FIELD(sizebase, Value=config.ysize, Title='YSize: ', $
   /Integer)

   ; File type and order.

orderbase = Widget_Base(sizebox, Row=1)
type = ['Color', 'Grayscale']
order = ['0', '1']
colordropID = Widget_Droplist(orderbase, Value=type, $
   Title='File Type: ', EVENT_PRO='NULL_EVENTS')
orderdropID = Widget_Droplist(orderbase, Value=order, $
   Title='Display Order: ', EVENT_PRO='NULL_EVENTS')


Widget_Control, colordropID, Set_Droplist_Select=FIX(ABS(config.color-1))
Widget_Control, orderdropID, Set_Droplist_Select=config.order

   ; Quality Slider if needed.

IF filetype EQ 'JPEG' THEN $
   sliderID = Widget_Slider(bigbox, Value=config.quality, Max=100, Min=0, $
      Title='Compression Quality', EVENT_PRO='NULL_EVENTS', $
      SCR_XSize=350) ELSE sliderID = -1

   ; Cancel and Accept buttons.

buttonbase = Widget_Base(tlb, Row=1)
cancelID = Widget_Button(buttonbase, Value='Cancel', UValue='CANCEL')
createID = Widget_Button(buttonbase, Value='Create File', UValue='CREATE')
ok = Widget_Button(buttonbase, Value='Accept', UValue='ACCEPT')

Widget_Control, tlb, /Realize

ptr = Ptr_New({cancel:1, create:0})

info = { filenameID:filenameID, xsizeID:xsizeID, $
         ysizeID:ysizeID, colordropID:colordropID, $
         orderdropID:orderdropID, ptr:ptr, sliderID:sliderID}

Widget_Control, tlb, Set_UValue=info, /No_Copy
XManager, 'plotman_fileform', tlb, $
   Event_Handler='plotman_fileform_event'

formdata = *ptr
Ptr_Free, ptr

IF N_ELEMENTS(formdata) EQ 0 THEN BEGIN
   cancel = 1
   create = 0
   RETURN, -1
ENDIF

fields = TAG_NAMES(formdata)
create = formdata.create
cancel = WHERE(fields EQ 'CANCEL')
IF cancel(0) EQ -1 THEN BEGIN
   cancel = 0
   newConfiguration = Create_Struct('XSIZE', formdata.xsize, $
      'YSIZE', formdata.ysize, 'COLOR', formdata.color, $
      'FILENAME', formdata.filename, 'ORDER', formdata.order, $
      'QUALITY', formdata.quality, NAME='XWINDOW_' + filetype)
   RETURN, newConfiguration
ENDIF ELSE BEGIN
   cancel = 1
   create = 0
   RETURN, -1
ENDELSE
END ; of plotman_fileform event handler *******************************
