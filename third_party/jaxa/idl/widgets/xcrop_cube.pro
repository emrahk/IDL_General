;+
; Project     : SOHO - CDS     
;                   
; Name        : XCROP_CUBE
;               
; Purpose     : General N-dimensional cube cropping.
;               
; Explanation : This is a routine that allows the user to interactively pick
;               out a "rectangular" subset of any N-dimensional data cube in
;               IDL.
;
;               Although IDL allows up to 8 dimensions in an array, only 7
;               subscripts are allowed (!) so any "cropping" can be described
;               by the start and stop indices of 7 dimensions. Thus a cropping
;               is defined as a structure:
;
;                        c = {b:lonarr(7), e:lonarr(7)}
;
;               and cropping an array given such a structure is done by
;
;                 cropped = cube(c.b(0):c.e(0),c.b(1):c.e(1),$
;                                c.b(2):c.e(2),c.b(3):c.e(3),$
;                                c.b(4):c.e(4),c.b(5):c.e(5),$
;                                c.b(6):c.e(6))
;
; Use         : XCROP_CUBE,CUBE,CROP
;    
; Inputs      : CUBE : Any data array.
;
;               CROP : A structure {b:lonarr(7), e:lonarr(7)}, where the B and
;                      E array describe the start and stop indices of the
;                      cropping, respectively.
;                      
; Opt. Inputs : CROP does not need to be defined on input.
;               
; Outputs     : CROP is modified by the user.
;               
; Opt. Outputs: None.
;               
; Keywords    : FIXED_SIZE : The size of the cropping region may be fixed in
;                            each dimension individually. E.g.,
;                            FIXED_SIZE=[0,1,0,1,0,0,0] will fix the size of
;                            dimensions 2 and 4.
;
;               MISSING : The value of missing data (for color scaling
;                         purposes).
;
;               GROUP_LEADER : Group leader.
;
; Calls       : default, cw_enterb(), trim(), cw_cubeview(), prestore,
;               find_draw_widget(), handle_killer_hookup, xmanager,
;
; Common      : None
;               
; Restrictions: ...
;               
; Side effects: ...
;               
; Category    : Utility, Widgets
;               
; Prev. Hist. : None
;
; Written     : SVH Haugan, UiO, 26 September 1997
;               
; Modified    : Not yet.
;
; Version     : 1, 26 September 1997
;-            
PRO xcrop_cube_oplot,info
  
  ;; Get info on what's displayed
  ;;
  widget_control,info.int.cube_id,get_value=cube_val
  
  ;; These are the displayed image dimensions
  xdi = cube_val.image_dim(0) & ydi = cube_val.image_dim(1)
  
  ;; Get the current crop
  handle_value,info.int.crop_h,crop
  
  ;; Get the device coordinates of the current crop

  x = [crop.b(xdi),crop.e(xdi)]+[-0.5,0.5]
  y = [crop.b(ydi),crop.e(ydi)]+[-0.5,0.5]
  
  prestore,info.int.cube_image_preg
  
  oplot,[x(0),x(0),x(1),x(1),x(0)],[y(0),y(1),y(1),y(0),y(0)]
END



PRO xcrop_cube_crop,info,ev
  
  ;; Get info on what's displayed
  ;;
  widget_control,info.int.cube_id,get_value=cube_val
  
  ;; These are the displayed image dimensions
  xdi = cube_val.image_dim(0) & ydi = cube_val.image_dim(1)
  
  ;; Get the current crop
  handle_value,info.int.crop_h,crop
  
  ;; Used to add halfpixels to enclose the pixels included.
  addsize = [-0.5d,0.5d]
  
  ;; Get the device coordinates of the current crop
  cip = info.int.cube_image_preg ;; shorthand
  x = pconvert(cip,[crop.b(xdi),crop.e(xdi)]+addsize,/data,/to_device)
  y = pconvert(cip,[crop.b(ydi),crop.e(ydi)]+addsize,/Y,/data,/to_device)
  
  x0 = x(0) & x1 = x(1) & y0 = y(0) & y1 = y(1)
    
  ;; Read state of motion events, and set them (for box_cursor)
  
  motion = widget_info(info.int.cube_image_win_id,/draw_motion_events)
  widget_control,info.int.cube_image_win_id,/draw_motion_events
  
  nx = (x(1)-x(0)) > 1
  ny = (y(1)-y(0)) > 1
  
  fixed = info.int.fixed_size([xdi,ydi])
  
  ;; Do the box-cursor thingy
  ;;
  wset,info.int.cube_image_win
  box_cursor,x0,y0,nx,ny,/init,/anywhere,fixed_size=fixed
  widget_control,info.int.cube_image_win_id,draw_motion_events=motion
  
  orgsize = crop.e([xdi,ydi])-crop.b([xdi,ydi])
  
  REPEAT BEGIN
     
     ;; try_again: ;; (with new addsize
  
     ;; Convert to data (i.e., cube pixel) coordinates
     ;;
     x = pconvert(cip,[x0,x0+nx],/device,/to_data)
     y = pconvert(cip,[y0,y0+ny],/device,/to_data,/Y)
     x = round(x-addsize)
     y = round(y-addsize)
     
     ;; Make sure we don't go outside limits
     ;; 
     maxsz = info.int.sz(1+[xdi,ydi])-1
     
     crop.b([xdi,ydi]) = ([x(0),y(0)] > 0) < maxsz
     crop.e([xdi,ydi]) = ([x(1),y(1)] > crop.b([xdi,ydi])) < maxsz
     
     ;; If any of the dimension sizes are fixed, make sure we stick to the
     ;; original size (by expanding/contracting the area and recalculate the
     ;; pixel sizes)
     
     redo = 0
     
     ixi = [xdi,ydi]
     FOR i = 0,1 DO BEGIN
        IF info.int.fixed_size(ixi(i)) THEN BEGIN
           newsize = crop.e(ixi(i))-crop.b(ixi(i))
           IF newsize NE orgsize(i) THEN BEGIN
              redo = 1
              IF newsize GT orgsize(i) THEN addsize(i) = addsize(i)+0.05 $
              ELSE                          addsize(i) = addsize(i)-0.05
              print,"Redoing, addsize=",addsize
           ENDIF 
        ENDIF
     END
     
  END UNTIL NOT redo
  
  ;; Get current sizes, update displayed values
  csz = crop.e-crop.b+1
  FOR i = 0,6 DO widget_control,info.int.sztext_ids(i),set_value=trim(csz(i))
  
  ;; Put back crop
  handle_value,info.int.crop_h,crop,/set
  
  ;; Redisplay the image
  widget_control,info.int.cube_id,set_value={origin:[0]} ;; Dummy 
  ;; Overplot the crop
  xcrop_cube_oplot,info
END



PRO xcrop_cube_resize,info,dim,ev
  ;; Get crop
  handle_value,info.int.crop_h,crop
  
  
  sz = fix(ev.value)
  sz = (sz > 1) < info.int.sz(dim+1)
  widget_control,ev.id,set_value=trim(sz)
  
  current = crop.e(dim)-crop.b(dim)+1
  delta = sz-current
  
  crop.b(dim) = (crop.b(dim)-(delta+sgn(delta))/2) > 0
  crop.e(dim) = crop.b(dim)+sz-1
  overshoot = crop.e(dim)-info.int.sz(dim+1)-1
  IF overshoot GT 0 THEN BEGIN
     crop.b = crop.b-overshoot
     crop.e = crop.e-overshoot
  END
  
  ;; Set crop
  handle_value,info.int.crop_h,crop,/set
  
  xcrop_cube_oplot,info
END

PRO xcrop_cube_help,top
  
  htx = $
     ['',$
      'XCROP_CUBE is a general widget for cropping (defining subsets of)',$
      'N-dimensional data cubes.',$
      '',$
      'Below the command buttons are buttons showing the current size of',$
      'the cropping. You may change the sizes of the cropped region by',$
      'clicking on these buttons and typing in a different number',$
      '',$
      'Below the size fields are two draw windows. The upper one shows',$
      'an image formed by taking a two-dimensional slice through the data',$
      'cube. The identity of the dimensions used to form the image are',$
      'shown by two buttons e.g.,', $
      '',$
      '  [ Dim:0 ] x [ Dim:1 ] ',$
      '',$
      'meaning that the image displays dimensions 0 and 1. To view images',$
      'formed in other dimensions, click the buttons to change their values.',$
      '',$
      'The lower draw window shows a plot of the data along one dimension,',$
      'shown with a similar button as e.g., [ Dim:2 ], which may also be',$
      'changed by clicking on it.',$
      '',$
      'You may zoom in or out in the image/plot by clicking the right/left',$
      'buttons respectively, or move around (move the "focus point" of the',$
      'cube) by clicking the middle mouse button.',$
      '',$
      'The outline of the current cropping region (in the two image',$
      'dimensions) is shown by a white rectangle plotted on top of the',$
      'image.',$
      '',$
      'To modify the size or position of the cropping interactively, push',$
      'the "Crop" button at the top of the widget. This will cause the',$
      'upper plot region to act as a "box_cursor" zoom, and you may move',$
      'the box by clicking down the left mouse button and moving the cursor,',$
      'or resize the box by clicking down the middle button (near the corner',$
      'that you wish to move), moving the cursor around.',$
      '',$
      'It is important that you remember to *end* this special mode by ',$
      'clicking the *right* mouse button - since normal event processing is',$
      'turned off during the box_cursor operation.',$
      '',$
      'When you are satisfied with the result, press the [Exit] button']
  
  xtext,htx,group=top
  
END


PRO xcrop_cube_event,ev
  
  widget_control,ev.top,get_uvalue=info,/no_copy
  
  widget_control,ev.id,get_uvalue=uval
  
  uval = str_sep(uval,':')
  
  CASE uval(0) OF 
  'EXIT':BEGIN 
     widget_control,ev.top,/destroy
     return
     ENDCASE
     
  'HELP':BEGIN
     xcrop_cube_help,ev.top
     ENDCASE
     
  'CUT':BEGIN
     xcrop_cube_crop,info,ev
     ENDCASE
     
  'SIZE':BEGIN
     xcrop_cube_resize,info,trim(uval(1)),ev
     ENDCASE
     
  'CUBEVIEW':BEGIN
     xcrop_cube_oplot,info
     ENDCASE
     
  END
  
  widget_control,ev.top,set_uvalue=info,/no_copy
END


PRO xcrop_cube,cube,crop,group_leader=group_leader,fixed_size=fixed_size, $
               missing=missing
  
  default,group_leader,0L
  
  sz = size(cube)
  
  ;; IDL v 4 allows 8-dimensional data, but just 7 subscripts!
  dcrop = {b:lonarr(7),e:lonarr(7)}
  dcrop.e = sz(1:sz(0))-1
  
  IF sz(0) LT 7 THEN sz = [sz(0:sz(0)),replicate(1L,7-sz(0)),sz(sz(0)+1:*)]
  sz(0) = 7
  
  default,crop,dcrop
  
  default,fixed_size,bytarr(7)
  
  IF n_elements(fixed_size) LT 7 THEN fixed_size = [fixed_size,bytarr(7)]
  
  top = widget_base(group_leader=group_leader,/column)
  
  commands = widget_base(top,/row)
  dummy = widget_button(commands,value='Help',uvalue='HELP')
  dummy = widget_button(commands,value='Exit',uvalue='EXIT')
  dummy = widget_button(commands,value='Crop',uvalue='CUT')
  
  ;; Display size.
  
  szbase = widget_base(top,/row)
  dummy = widget_label(szbase,value='Size:')
  
  sztext_ids = lonarr(7)
  
  currsize = crop.e-crop.b+1
  
  FOR i = 0,6 DO BEGIN
     sztext_ids(i) = cw_enterb(szbase,value=trim(currsize(i)),$
                               uvalue='SIZE:'+trim(i))
     IF fixed_size(i) THEN widget_control,sztext_ids(i),sensitive=0
     IF i NE 6 THEN dummy = widget_label(szbase,value='x')
  END
  
  cube_id = cw_cubeview(top,value=cube,uvalue='CUBEVIEW',/all_events,$
                        xsize=400,ysize=300,missing=missing,$
                        origin=origin,scale=scale,phys_scale=phys_scale)
  
  widget_control,top,/realize
  
  widget_control,cube_id,get_value=cube_value
  widget_control,cube_value.internal.image_id,get_value=cw_pzoom_val
  widget_control,cube_value.internal.plot_id,get_value=cw_plotz_val
  
  prestore,cw_pzoom_val.plotreg
  cw_pzoom_win = !D.window
  prestore,cw_plotz_val.plotreg
  cw_plotz_win = !D.window
  
  cw_pzoom_win_id = find_draw_widget(cw_pzoom_win)
  cw_plotz_win_id = find_draw_widget(cw_plotz_win)
  
  int = {sz:sz,$
         cube_id           : cube_id,$
         cube_plot_win     : cw_plotz_win,$
         cube_plot_win_id  : cw_plotz_win_id,$
         cube_plot_preg    : cw_plotz_val.plotreg,$
         cube_image_win    : cw_pzoom_win,$
         cube_image_win_id : cw_pzoom_win_id,$
         cube_image_preg   : cw_pzoom_val.plotreg,$
         fixed_size        : fixed_size,$
         sztext_ids        : sztext_ids,$
         crop_h            : handle_create(value=crop)}
  
  info = { int:int }
  
  xcrop_cube_oplot,info
  
  widget_control,top,set_uvalue=info
  
  handle_killer_hookup,int.crop_h ;; Will at least kill it on xkill,/all
  
  xmanager,'xcrop_cube',top,/modal
  
  handle_value,int.crop_h,crop
  handle_free,int.crop_h
  
END
