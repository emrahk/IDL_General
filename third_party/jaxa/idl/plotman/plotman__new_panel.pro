; PLOTMAN__NEW_PANEL contains plotman methods dealing with storing and retrieving data
;	for each plot saved (called a panel).
;
; Modifications:
;   2/15/01 - Added _extra keyword to new_panel, save_panel, and getdata in save_panel
;   3/16/01 - In which_panel, if widget_id passed in is not valid (maybe destroyed in clean up of invalid
;     draw widgets) then exit with -1.
;	3/30/01 - In Save_panel method - was checking for specific object classes to clone and doing get
;		data on all others.  Now check for specific object classes to do getdata, and clone all others.  Prompted
;		by some of show_synop object will inherit MAP_LIST, but will be another class, like MDI.
;	1-May-2001 - When saving data from HSI_SPECTRUM object, use sp_data_structure & sp_data_unit keywords.
;	27-May-2001 - Added noplot keyword to new_panel and create_new_panel methods.  Also in create_new_panel,
;     set map=0 when creating new base for drawing, and if not noplot, then map it (so screen doesn't flash
;     alot when creating a bunch of draw bases, but not plotting them immediately, e.g. qlook images)
;	9-Jul-2001 - Added desc2panel function
;	1-Oct-2001 - Changed desc2panel to searching for a substring rather than the whole
;		string equal to the panel description.  Also added number keyword - if set, returns
;		panel number rather than panel structure.
;	20-May-2002, Kim.  Clone control and info structure before saving.  Otherwise might delete
;		needed pointers when destroy plotman object.
;	30-Jun-2002, Kim.  Get rid of Panel pulldown and summarize buttons at top of each plot panel-
;	  changes in create_new_panel and show_panel methods.
;	20-Aug-2002, Kim.  For hessi image panels, only get info params for image alg used. Disabled on 21-aug-2002
;     because get doesn't work correctly this way.
;	07-Oct-2002, Kim. Added specplot capability.
;		Also in save_panel method, set new cloned pointer back into *self.data
;	08-Oct-2002, Kim. In create_new_panel, if noplot is set, make draw window 5x5 to conserve
;		backing store space
;	09-Oct-2002, Kim.  Added nacross option in show_panel
;	22-Nov-2002, Kim.  Added nodup keyword to new_panel method
;	03-Dec-2002, Kim.  In restore_saved_data method, don't call set, input= because
;		that will call set_props_from_obj.  Also if do that need to save and reset
;		utrange, timerange, and utbase.  Just need to save in *self.data
;	11-Dec-2002, Kim.  In save_panel, set self.plot_control to cloned structure from panel
;		structure. (after DMZ fixed memory leak in linkedlist, not doing this caused object
;		in plot_args to be deleted.)
;	11-Dec-2002, Kim.  Only draw red box around plot if device is WIN or X
;	05-Feb-2003, Kim.  Added yaxis to saved_data structure.  Previously in save_panel method,
;		for hsi_spectrum object, forced /sp_data_structure and sp_data_unit='flux'.  Now use
;		whatever user set for those, and save yaxis (times) explicitly in case user didn't
;		select sp_data_structure (structure includes times)
;	28-Feb-2003, Kim.  Added replace keyword to new_panel. If set, deletes panel of same
;	    description before adding new panel.
;	19-Mar-2003, Kim.  In save_panel method, for hsi_spectrum, if xaxis is time, save times in
;		xaxis tag and energies in yaxis tag, otherwise do reverse.  Previously did getaxis(xaxis)
;		for xaxis, but this is always energy even for time plot.
;	30-Mar-2003, Kim.  Added minimal keyword to focus_panel, and changed around to only
;		change the minimal number of things when minimal keyword is set.
;	16-Sep-2003, Kim.  For <5.5, use scr_xsize, scr_ysize instead of xsize,ysize in create_new_panel
;	26-nov-2003, Kim.  If we restored a panel save file (using plotman__restore_panels), the widget
;	    ids that were stored are no longer valid (so plotman__restore_panels sets them to -1), so
;	    recreate the widgets if necessary.
;	7-Jan-2004, Kim.  In hide_all_panels, reduce size of all draw widget to 2x2 after hiding, so that
;		space isn't wasted by windows that aren't showing.  Also in show_panels, if draw widget isn't
;		alive for some reason, create it (this may not be necessary any more - may have been part of
;		an attempt to delete draw widgets to save window space, but it seems like a good idea anyway.
;               Previously every pixmap was stored
;		in the size it was displayed in, even when it wasn't showing, and eventually crashed.
;		Also added delay_set_pulldown in save_panel method.  This will be set when importing an image
;		cube file, so that we can wait until all image read in before setting panel names
;		in the Window_Control pulldown menu.
;	5-Jan-2005, Kim.  Call set_window_control_pulldown as a method, not subroutine.
;	10-Jan-2005, Kim.  Added description keyword to new_panel method. (keep description
;		argument so old way still works, but with keyword, can pass through with _extra)
;	29-Mar-2005, Kim.  Save xaxis,yaxis in panel as edges_2.  Also allow profiles for
;		spectrograms as well as images.
;	16-Nov-2006, Kim.  last_window_choice is now the panel description (previously was
;		'panel x'.  Got rid of delay_set_pulldown option.  Added panel_button_ids and
;		set_window_control_pulldown methods.  The latter was a separate routine before,
;		modified it for new way of setting panel buttons, and added it to this file.
;		Pop up 'Deleting...' message if deleting > 20 panels.
;	7-Mar-2007, Kim.  In save_panel, use used_xyoffset in info rather than xyoffset in control
;	5-Jul-2008, Kim. In new_panel, added input and plot_type keywords and call to setdefaults.  Previously
;		for new plot needed to call setdefaults, and then new_panel.  Now just call new_panel.  Also,if
;		the current plotman instance doesn't have multi_panel capability (the old default), then
;		before adding a new panel, delete the old panels, so there's always only one panel.
;		Also call hsi_compute_image_axis via call_function so can compile without hessi tree
; 14-Oct-2008, Kim. Added noclone keyword to save_panel method.  show_synop will call
;   plotman with /noclone to save overhead for huge images.
; 03-Feb-2009, Kim. In focus_panel, made adjustments for 12 possible overlays (increased from 4)
; 27-Apr-2009, Kim.  For some reason spectrogram options widget button was de-sensitized. Fixed.
; 04-Aug-2009, Kim. In save_panel, call free_var, self.plot_control before reassigning.  Memory leak.
; 17-Aug-2009. Kim. Undo 4-Aug change.  Now self.plot_control is always independent of panel plot_control. Also
;   in focus_panel, use set_plotman_control.  And in update_panel, free old panel.. and set to clone of plot_control.
;   Also, in hide_all_panels, check if w_drawbase is alive before hiding - if not, get into infinite loop
; 11-Nov-2009, Kim. Added panel number to dropdown list (in set_window_control_pulldown and panel_button_ids), but
;   commented it out because when delete a panel would have to renumber existing panels, so would have to change
;   the entire pulldown list
; 14-Jan-2011, Kim. In desc2panel method, added strip_time keyword, and check for equality.  Previously
;   was just checking that string was contained in all_panel_desc, but wrong in cases where one
;   panel has same name as another, but with 'prepped_' in front.
;   Also, in new_panel method, for nodup and replace blocks, add /strip_time to call to desc2panel
; 21-Jan-2011, Kim.  In desc2panel method, use where_arr instead of where for cases where desc is an array
; 12-Jun-2012, Kim.  In new_panel, if description is an array, make it scalar (otherwise crashes in display opt widg
; 16-Oct-2014, Kim.  Added quiet keyword to new_panel method.  Controls 'using previously saved plot' message.
; 27-Jul-2015, Kim.  Added show_recent_panel_type method
; 23-Oct-2015, Kim. In new_panel, if description is blank, don't do nodup check
;
;-----
; INIT_SAVED_DATA method - Saved_data is structure for saving data from objects.  Initialize
;	to just new pointers and blanks for strings.  Don't free pointers first because they're
;	pointing to things being saved in the panels structure.

pro plotman::init_saved_data

  self.saved_data.data = ptr_new()
  self.saved_data.xaxis = ptr_new()
  self.saved_data.yaxis = ptr_new()
  self.saved_data.control = ptr_new()
  self.saved_data.info = ptr_new()
  self.saved_data.class = ''
  self.saved_data.class_name = ''
  self.saved_data.save_mode = ''
  
end

;-------
; RESTORE_SAVED_DATA method - Restore data that was saved in a panel (in the panel linked list)
;	to the current data location (self.saved_data or self.data depending on how that data
;	was saved for the panel.  If save_mode is obj_extract, then restore the
;	saved_data structure and set use_extracted flag to 1.  Otherwise, initialize saved_data
;	structure to no data, restore self.data from the panel's saved data, and set use_extracted flag to 0.
;
; Input: panel - structure containing all info for a panel
;

pro plotman::restore_saved_data, panel

  save_mode = panel.saved_data.save_mode
  if save_mode eq 'obj_extract' then begin
    self.saved_data = panel.saved_data
    self.use_extracted = 1
  endif else begin
    self -> init_saved_data
    *self.data = *panel.saved_data.data
    if save_mode eq 'clone' then self -> set, class_name = panel.saved_data.class_name
    self.use_extracted = 0
  endelse
  
  
end


;-----
; SAVE_PANEL method - Save data for a panel in the self.saved_data structure for current
;	plotting, and in the panel structure.  There are three modes for saving:
;		obj_extract - save data, control, and info from object
;	 	clone - init saved_data to nulls and save clone of object in self.saved_data.data
;		data - init saved_data to nulls and save data itself in self.saved_data.data
;	Save panel structure in the linked list of panels for retrieval later, and add the current
;	plot to the list of panels in the Window Control pulldown menu.
;
; Input: description - string describing data (for single panel plotman's, can be blank)

pro plotman::save_panel, description=description,  noclone=noclone, _extra=_extra

  checkvar,  description, ' '
  widget_control, self.plot_base, get_uvalue=state
  
  if xalive(state.widgets.w_drawbase) then begin
  
    if not ptr_valid (self.saved_data.data) then begin
    
      self -> init_saved_data
      
      isobj = size(*self.data,/tname) eq 'OBJREF'
      
      if isobj then begin
        obj_class = obj_class (*self.data)
        if obj_class eq 'HSI_IMAGE' or $
          obj_class eq 'HSI_LIGHTCURVE' or $
          obj_class eq 'HSI_SPECTRUM' or $
          obj_class eq 'HSI_BPROJ' then begin
          
          ; don't know why, but causes errors if don't extract data, xaxis, etc first and
          ; then put in saved_data pointer, i.e. can't do it in one step
          
          data = *self.data->getdata(class_name=self.class_name, _extra=_extra)
          self.saved_data.data=ptr_new(data)
          
          self.saved_data.save_mode = 'obj_extract'
          sub_class = self.class_name
          self.saved_data.control = ptr_new(stc_clone(*self.data -> get(class_name=sub_class, /control)))
          self.saved_data.class = obj_class
          self.saved_data.info = ptr_new(stc_clone(*self.data -> get(class_name=sub_class, /info)))
          self.saved_data.class_name = self.class_name
          self.use_extracted = 1
          
          if obj_class eq 'HSI_SPECTRUM' or obj_class eq 'HSI_LIGHTCURVE' then begin
            times = *self.data->getaxis(class_name=self.class_name, /ut, /edges_2)
            energies = *self.data->getaxis(class_name=self.class_name, /energy, /edges_2)
            if self.plot_control.plot_type eq 'xyplot' then begin
              self.saved_data.xaxis=ptr_new(energies)
              self.saved_data.yaxis=ptr_new(times)
            endif else begin
              self.saved_data.xaxis=ptr_new(times)
              self.saved_data.yaxis=ptr_new(energies)
            endelse
            
          endif else begin
            ; use hsi_compute_image_axis because using getaxis is slow
            xyoffset = (*self.saved_data.info).used_xyoffset
            image_dim = (*self.saved_data.control).image_dim
            pixel_size = (*self.saved_data.control).pixel_size
            pixel_scale = (*self.saved_data.control).pixel_scale
            xaxis = call_function('hsi_compute_image_axis', xyoffset, image_dim, pixel_size, pixel_scale, /xaxis, /edges_2)
            yaxis = call_function('hsi_compute_image_axis', xyoffset, image_dim, pixel_size, pixel_scale, /yaxis, /edges_2)
            self.saved_data.xaxis=ptr_new(xaxis)
            self.saved_data.yaxis = ptr_new(yaxis)
          endelse
          
        endif else begin
          ;	if obj_class eq 'MAP_LIST' or obj_class eq 'LTC'  or obj_class eq 'HSI_OBS_SUMMARY' then  begin
          self.saved_data.save_mode = 'clone'
          self.saved_data.data = keyword_set(noclone) ? ptr_new(*self.data) : ptr_new(obj_clone(*self.data ))
          *self.data = *self.saved_data.data
          self.saved_data.class_name = self.class_name
          self.use_extracted = 0
        endelse
      endif else begin
        self.saved_data.save_mode = 'data'
        self.saved_data.data = ptr_new(*self.data)
        self.use_extracted = 0
      endelse
      
    endif
    
    ;print,'In save_panel, self.plot_control.plot_args and panel...:'
    ;help,self.plot_control.plot_args
    ;print,ptr_valid(self.plot_control.plot_args)
    
    panel = {w_drawbase: state.widgets.w_drawbase, $
      w_draw: state.widgets.w_draw, $
      window_id: state.widgets.window_id, $
      plot_control: stc_clone(self.plot_control), $
      saved_data: self.saved_data, $
      description: description}
      
    ;help,panel.plot_control.plot_args
    ;print,ptr_valid(panel.plot_control.plot_args)
      
    self.panels -> add, panel  ; add this panel to linked list
    
    self.current_panel_number = self.panels -> get_count() - 1
    ;self.last_window_choice = 'panel ' + strtrim(self.current_panel_number, 2)
    self.last_window_choice = description
;    17-Aug-2009, don't need this - already separate from panel since did a clone above
;    ; 4-Aug-2009 This free_var will deallocate any pointers in self.plot_control structure because
;    ; otherwise they're inaccessible, and a memory leak
;    free_var, self.plot_control 
;    17-Aug-2009 - don't need following now.  self.plot_control is now separate from the clone
;    that is saved in panel structure, but at this moment has the same values (but not pointers)
;    self.plot_control = panel.plot_control
    
    ; add button to pulldown for window control for new  panel
    self -> set_window_control_pulldown, add_panel=self.current_panel_number
    
  endif
  
end

;-----
; HIDE_ALL_PANELS method - unmap all panels and set current panel number to -1 to show that
;	no panel is active.

pro plotman::hide_all_panels

  nump = self.panels -> get_count()
  if nump gt 0 then begin
    for ip = 0,nump-1 do begin
      panel = self.panels -> get_item (ip)
      if xalive((*panel).w_drawbase) then begin
        mapped = since_version ('5.6') ? widget_info ((*panel).w_drawbase, /map) : 1
        if mapped then xhide, (*panel).w_drawbase
        ; reduce size of hidden panels so don't run out of window space 7-Jan-2003
        sz = widget_info ((*panel).w_draw, /geom)
        if sz.xsize*sz.ysize gt 4. then widget_control, (*panel).w_draw, xsize=2, ysize=2
      endif
    endfor
  endif
  
  self.current_panel_number = -1
  
end

;-----
; PANEL_SUMMARY method - List summry of what's in each panel

pro plotman::panel_summary

  nump = self.panels -> get_count()
  print, ''
  print, 'Summary of Current Panels: '
  print , ''
  print, 'Number of panels = ', nump
  
  if nump gt 0 then begin
    for ip = 0,nump-1 do begin
      print, ' '
      print, 'Panel ', ip
      panel = self.panels -> get_item (ip)
      p = *panel
      print, 'Draw base, draw, window ids = ', p.w_drawbase, p.w_draw, p.window_id, '  ', p.description
      g = widget_info(p.w_drawbase, /geom)
      print,'Draw base X offset, size, scr_size, draw_size = ', g.xoffset, g.xsize, g.scr_xsize, g.draw_xsize
      print,'Draw base Y offset, size, scr_size, draw_size = ', g.yoffset, g.ysize, g.scr_ysize, g.draw_ysize
      print,'Plot Type: ', p.plot_control.plot_type
      help,*p.saved_data.data, out=text
      print,'Panel Data: ', text
      if p.saved_data.save_mode eq 'obj_extract' then begin
        help,*p.saved_data.control, out=text
        print,'Control Parameters: ', text
        help, *p.saved_data.info, out=text
        print,'Info Parameters: ', text
      endif
      print,'Save Mode: ', p.saved_data.save_mode,  '    Object Class: ', p.saved_data.class
      print,'Class_name:', p.saved_data.class_name
    ;help, *panel,/st
    endfor
  endif
  
end

;-----
; WHICH_PANEL method - Function to return the panel structure (or the pointer to it)
; corresponding to the draw widget ID (or the draw widget's base ID) passed in.
; err=1 and return value is -1 if can't find a match.  Optionally returns
; the panel_number (item number in the linked list) in keyword panel_number.

function plotman::which_panel, widget_id, panel_number=panel_number, err=err, $
    pointer=pointer, draw_base=draw_base
  ;print, 'draw_id=', draw_id
    
  draw_base = widget_id
  
  all_panel_drawbase = self -> get(/all_panel_drawbase)
  
  ; first remove any stray panel draw bases that are not being used ( certain crashes can cause this)
  xwidump, self.plot_base, text,  id
  for i = 0,n_elements(id)-1 do  begin  ; can't seem to call with widget_info with array of ID's - bug? , so loop
    if xalive(id[i]) then if widget_info(id[i], /uname) eq 'panel_draw_base' then begin
      if not is_member(id[i], all_panel_drawbase) then widget_control, id[i], /destroy
    endif
  endfor
  
  if xalive (draw_base) then begin
    while widget_info(draw_base, /uname) ne 'panel_draw_base' do  draw_base = widget_info(draw_base, /parent)
  endif else goto, error_exit
  
  err = 0
  q = where (draw_base eq all_panel_drawbase, count)
  if count gt 0 then begin
    panel_number = q[0]
    panel = self.panels -> get_item (panel_number)
    if keyword_set(pointer) then return, panel else return, *panel
  endif else goto, error_exit
  
  error_exit:
  err = 1
  panel_number = -1
  return, -1
  
end

;----- function to return pointer to panel structure matching panel description passed in
; Keywords:
; number - if set, then returns number of panel instead of pointer to panel structure.
; all - if set, and number is set, then returns all panel numbers that match description passed in.
; (all has no effect if number is not set.)
; latest - if set, returns most recent panel matching description.  Otherwise returns first one found.
; strip_time - if set, remove panel creation time from panel descriptions before checking

function plotman::desc2panel, panel_desc, number=number, all=all, latest=latest, strip_time=strip_time

  desc = strlowcase(panel_desc)
  
  ;desc = strlowcase(panel_desc eq 'self' ? self->get(/current_panel_desc) : panel_desc)
  all_panel_desc = strlowcase(self -> get(/all_panel_desc))
  
  ; for some cases, want to get rid of panel creation time at end of description.
  ; for those cases, make sure also that there are no leading or trailing blanks.
  if keyword_set(strip_time) then begin
    desc = strtrim(self->strip_panel_desc(panel_desc=desc, /time_only), 2)
    all_panel_desc = strtrim(self->strip_panel_desc(panel_desc=all_panel_desc, /time_only), 2)
  endif
  
  q = where_arr(all_panel_desc, desc, count)
  ;q = where (desc eq all_panel_desc, count)
  ;q = where (strpos(all_panel_desc, desc) ne -1, count)
  
  if count ne 0 then begin
    if keyword_set(number) then begin
      if keyword_set(all) then return, q
      if keyword_set(latest) then return, last_item(q)
      return, q[0]
    endif else begin
      if keyword_set(latest) then ind = last_item(q) else ind=q[0]
      panels_obj = self -> get(/panels)
      panel = panels_obj -> get_item(ind)
      return, panel
    endelse
  endif
  
  return, -1
end

;-----
; FOCUS_PANEL method - Set focus on selected panel.  Set current widget draw widgets
; to point to this panel, and restore plotman plot_control and data
; to those saved for this panel

pro plotman::focus_panel, panel, panel_number, minimal=minimal

  if exist(panel_number) then if panel_number eq -1 then begin
    message, 'Bad panel.', /cont
    return
  endif
  
  if not keyword_set(minimal) then begin
    ; first show that we're unselecting current window (if there is a valid window showing)
    ; by overwrite red highlight square with background color.  need to select first
    ; in case user was working in a graphics window outside of this plotman interface
    if self->valid_window() then begin
      self -> select
      screen_output = (!d.name eq 'WIN') or (!d.name eq 'X')
      if screen_output then plots, [0,1,1,0,0], [0,0,1,1,0], /norm, thick=5, color=0, psym=0
    ;print,'drawing black outline in plotman__focus_panel  ', self.current_panel_number
    endif
    
    widget_control, self.plot_base, get_uvalue=state
  endif
  
  if size(panel,/tname) ne 'STRUCT' then panel = *(self.panels -> get_item (panel_number))
  self.current_panel_number = panel_number
  
  ; 17-Aug-2009, use set_plot_control to prevent memory leaks
  self -> set_plot_control, panel.plot_control
;  self.plot_control=panel.plot_control
  
  self -> restore_saved_data, panel
  
  if not keyword_set(minimal) then begin
    state.widgets.w_drawbase = panel.w_drawbase
    state.widgets.w_draw = panel.w_draw
    state.widgets.window_id = panel.window_id
    
    ; set pulldown plot_control menus for image and xy plots to be sensitive or not depending
    ; on type of plot.
    plot_type = self.plot_control.plot_type
    desc = self->get(/current_panel_desc)
    widget_control, state.widgets.w_img, sensitive = (plot_type eq 'image')
    widget_control, state.widgets.w_imgprofile, sensitive = (plot_type eq 'image' or plot_type eq 'specplot')
    widget_control, state.widgets.w_imgflux, sensitive = (plot_type eq 'image')
    widget_control, state.widgets.w_colors, sensitive = (plot_type eq 'image' or plot_type eq 'specplot')
    widget_control, state.widgets.w_xy, sensitive = (plot_type eq 'xyplot' or plot_type eq 'utplot')
    widget_control, state.widgets.w_spec, sensitive = (plot_type eq 'specplot')
    q = where (self.plot_control.overlay_panel ne '', noverlay)
    widget_control, state.widgets.w_spec_integr, sensitive = (plot_type eq 'specplot') and $
      strpos(desc,'Integrated') eq -1 and $
      noverlay eq 0
    ;		same_data(self.plot_control.overlay_panel, ['','','',''])
      
    widget_control, self.plot_base, set_uvalue=state
  ;print,'saving state with window_id = ', state.widgets.window_id
  endif
  
  self -> select
  
end

;-----
; UPDATE_PANEL method - In case user changed some of plot control settings for active panel,
;	save plot control structure back into panel structure, so next time it is made active will
;	remember plot controls selected.

pro plotman::update_panel

  widget_control, self.plot_base, get_uvalue=state
  
  if self.current_panel_number ne -1 then begin
    panel = self.panels -> get_item(self.current_panel_number)
    
    if ptr_exist(panel) then begin
      ; 17-Aug-2009 free before setting (memory leak). And set to clone of self.plot_control, so stays separate. 
      free_var, (*panel).plot_control
      (*panel).plot_control = stc_clone(self.plot_control)
      widget_control, self.plot_base, set_uvalue=state
    endif
  endif
  
end

;-----
;DELETE_PANEL method - Delete specified panel (or current or all) from linked list.

pro plotman::delete_panel, panel_number=panel_number, current=current, all=all

  widget_control, self.plot_base, get_uvalue=state
  
  if keyword_set(current) then panel_number = self.current_panel_number
  
  nump = self.panels -> get_count()
  
  if nump gt 0 then begin
  
    if keyword_set(all) then begin
      ip1 = 0
      ip2 = nump - 1
      numdelete=nump
    endif else begin
      checkvar, panel_number, nump - 1
      ip1 = panel_number
      ip2 = panel_number
      numdelete = ip2 - ip1 + 1
    endelse
    
    
    if numdelete gt 20 then $
      xmessage,['', '     Deleting panels ...       ', ''], wbase=wxmessage
    ; have to delete widget button before deleting panel since use panel desc
    self -> set_window_control_pulldown, delete_panel=indgen(numdelete)+ip1
    
    ; do loop backwards since when delete a panel, all higher numbered panels shift down one.
    for ip = ip2, ip1, -1 do begin
      panel = self.panels -> get_item (ip)
      xhide, (*panel).w_drawbase
      if xalive((*panel).w_drawbase) then widget_control, (*panel).w_drawbase, /destroy
      free_var, (*panel).saved_data
      self.panels -> delete, ip
    endfor
    if xalive(wxmessage) then widget_control, wxmessage, /destroy
  endif
  
  self.current_panel_number = -1
  
; set elements of pulldown for window control to include all current panel descriptions
;self -> set_window_control_pulldown
  
end

;-----
; SHOW_PANEL method - Called when user selects an item under the Window Control
;	pulldown on the menu bar.  Current options are:
;	panel_number - show selected panel
;	maximize - display panel panel_number
;	p2x2 - display first four panels 2 across, 2 down
;	showall - show all panels
; Depending on how many panels to show, it figures out how big each panel it is going to show
; should be, resizes the draw widget, and displays it.

pro plotman::show_panel, $
    panel_numbers=panel_numbers, $
    maximize=maximize, $
    p2x2=p2x2, $
    showall=showall, $
    nacross=nacross, $
    all_1across=all_1across, $
    lineplots_1across=lineplots_1across
    
    
  widget_control, self.plot_base, get_uvalue=state
  
  self -> hide_all_panels
  
  xhide, state.widgets.w_drawbase
  
  panels = self -> get(/panels)
  
  num_panels = panels -> get_count()
  
  if num_panels eq 0 then begin
    a = dialog_message(' No plots to display.')
    return
  endif
  
  nshow = n_elements(panel_numbers)
  if nshow eq 1 then maximize = 1
  if nshow eq 0 then begin
    nshow = num_panels
    panel_numbers = indgen(num_panels)
  endif
  
  
  case 1 of
    keyword_set (maximize): begin
      if nshow eq 0 then begin
        nshow = 1
        panel_numbers = 0
      endif
      numx = 1
      numy = 1
    end
    keyword_set(nacross): begin
      numx = nacross < nshow
      numy = ceil(float(nshow) / numx)
    end
    keyword_set (p2x2): begin
      nshow = 4 < num_panels
      panel_numbers = indgen(nshow)
      numx = 2
      numy = 2
    end
    keyword_set (showall):  begin
      numx = ceil (sqrt (nshow) )
      numy = ceil (float(nshow) / numx)
    end
    keyword_set(all_1across): begin
      numx = 1
      numy = nshow
    end
    keyword_set(lineplots_1across): begin
      for ip = 0,num_panels-1 do begin
        if is_member(ip, panel_numbers) then begin
          p = panels -> get_item(ip)
          plot_type = (*p).plot_control.plot_type
          if plot_type ne 'image' then lineplots = append_arr(lineplots,ip)
        endif
      endfor
      if exist(lineplots) then begin
        nlineplots = n_elements(lineplots)
        nimages = nshow - nlineplots
        if nimages eq 0 then begin
          numx = 1
          numy = nlineplots
        endif else begin
          nximages = ceil (sqrt(nimages) )
          nyimages = ceil (float(nimages) / nximages)
          numx = nximages
          numy = nlineplots + nyimages
        endelse
      endif
    end
    else:
  endcase
  
  if not exist (numx) then begin
    numx = ceil (sqrt (nshow) )
    numy = ceil (float(nshow) / numx)
  endif
  
  ; if lineplots are being plotted full width, then reorder panels, so all lineplots
  ; are before any image plots
  if not exist (lineplots) then lineplots = -1 else begin
    not_lineplots_elems = rem_elem (panel_numbers, lineplots, count)
    if count gt 0 then panel_numbers = [lineplots, panel_numbers(not_lineplots_elems)]
  endelse
  
  
  geom = widget_info (state.widgets.w_maindrawbase, /geom)
  
  newxsize = (geom.scr_xsize - 5) / numx
  newysize = (geom.scr_ysize - 5) / numy
  fullxsize = geom.scr_xsize - 5
  
  ;ip1 = panel_number
  ;ip2 = (panel_number + nump -1) < (num_panels-1)
  
  ;print,'newsizes = ', newxsize, newysize,   '  ip1,ip2 = ', ip1, ip2
  
  count = 0
  
  xoffset = 0
  yoffset = 0
  count = 0
  
  for iy = 0, numy-1 do begin
  
    for ix = 0, numx-1 do begin
    
      if count ge nshow then goto, getout
      ip = panel_numbers(count)
      
      widget_control, /hourglass
      
      panel = panels -> get_item(ip)
      if not ptr_exist(panel) then goto, next
      
      print, 'panel = ', ip, '  panel desc = ', (*panel).description
      ;print, 'count =', count
      
      full_width = 0
      xsize = newxsize
      
      if is_member(ip, lineplots) then begin
        full_width = 1
        xsize = fullxsize
        xoffset = 0
      endif
      
      ; 26-nov-2003, try this.  If restored panel save file, don't have widgets
      if not xalive( (*panel).w_drawbase) then begin
        self -> create_new_panel, /using_saved
        widget_control, self.plot_base, get_uvalue=state
        (*panel).w_drawbase = state.widgets.w_drawbase
        (*panel).w_draw = state.widgets.w_draw
        (*panel).window_id = state.widgets.window_id
      endif
      
      widget_control, (*panel).w_drawbase, xsize=xsize, ysize=newysize, $
        xoffset=xoffset, yoffset=yoffset
        
        
      if not xalive( (*panel).w_draw) then begin
        state.widgets.w_draw = widget_draw (state.widgets.w_drawbase, $
          xsize=xsize-8, ysize=newysize-8, $
          /button_events, $
          event_pro='plotman_draw_event' )
          
        widget_control, state.widgets.w_draw, /map, get_value=window_id
        state.widgets.window_id = window_id
        wset, window_id
        wshow, window_id
        (*panel).w_draw = state.widgets.w_draw
        (*panel).window_id = state.widgets.window_id
        widget_control, self.plot_base, set_uvalue=state
      endif else widget_control, (*panel).w_draw, /map, xsize=xsize-8, ysize=newysize-8
      
      state.plotman_obj -> focus_panel, *panel, ip
      state.plotman_obj -> select
      state.plotman_obj -> plot
      xshow, (*panel).w_drawbase
      
      count = count + 1
      
      if full_width then goto, endofxloop
      xoffset = xoffset + newxsize
      next:
    endfor	; end of ix loop
    
    endofxloop:
    xoffset = 0
    yoffset = yoffset + newysize
    
  endfor	;end of iy loop
  
  getout:
end

;-----
; SET_WINDOW_CONTROL_PULLDOWN method
;
; Purpose: Add or delete buttons in the plotman Window_Control pulldown menu.  Each
;   plotman panel has a button in this pulldown so you can replot it.
;
; Arguments:  (must call with either add_panel or delete_panel keyword)
;	add_panel - number of panel to add a button for (must be a scalar)
;	delete_panel - number of panel(s) to delete buttons for (can be vector)
;
; Method: panel buttons have the panel description as their uvalue, so all
;	operations here are based on panel desc.  For deleting panels, get panel desc
;	for delete_panel and find the button having those uvalues (in panel_buttons method)
; Modifications:
;	30-Jun-2002, Kim.  Use xwidump to find widget id's
;	5-Jan-2005, Kim.  Changed from subroutine to object method.
;	Re Written: Kim Tolbert, 15-Nov-2006
;	Previously, every time we added or deleted a panel to this menu, had to delete
;		the whole thing, and refill it again (don't remember why).  So first removed all
;		buttons, then added the basic, generic buttons, then added a button for each panel.
;		Now, just add a single panel button to list, or remove one (or multiple) panel
;		buttons from existing list.  Wish I remember why I didn't do this in the first place.
;-

pro plotman::set_window_control_pulldown, add_panel=add_panel, delete_panel=delete_panel

  widget_control, self.plot_base, get_uvalue=state
  
  w_window_control = state.widgets.w_window_control
  
  ; if have single panel plotman, then don't have window_control widget
  if xalive (w_window_control) then begin
  
    panel_descs = self -> get(/all_panel_desc)
    
    if exist(add_panel) then begin
      desc = panel_descs[add_panel]
      tmp = widget_button(w_window_control, $
;        value=trim(add_panel) + ' ' + desc, $
        value=desc, $
        uvalue = desc, $
        event_pro='plotman_window_control_event' )
      return
    endif
    
    if exist(delete_panel) then begin
      id = self -> panel_button_ids (w_window_control, desc=panel_descs[delete_panel], count=count)
      if count gt 0 then for i=0,count-1 do widget_control, id[i], /destroy
      return
    endif
    
  endif
  
end

;-----
; PANEL_BUTTON_IDS method
; Get widget ids for buttons for panels with descriptions equal to desc
; w_window_control is id of top Window_Control button

function plotman::panel_button_ids, w_window_control, desc=desc, count=count

  count = 0
  
  if since_version('6.3') then wbut = widget_info(w_window_control, /all_children) $
  else xwidump, w_window_control, text,wbut
  
  nbut = n_elements(wbut)
  wval = strarr(nbut)
  for i=0,nbut-1 do begin
    widget_control, wbut[i], get_value=val
    wval[i] = val
  endfor
  
;  dummy = ssw_strsplit(wval, ' ', /head, tail=tail)
;  wval = tail

  if keyword_set(desc) then begin
    q = where_arr(wval, desc, count)
    return, count gt 0 ? wbut[q] : -1
  endif
  
end

; Find all panels with plot_type equal to type, and plot the most recent one
; type - 'xyplot', 'utplot', 'image', or 'specplot'
pro plotman::show_recent_panel_type, type, success
success = 0
pt = self->get(/all_panel_plot_type)
q = where(pt eq type, count)
if count gt 0 then begin
  self->show_panel,panel_number=q[count-1]
  success = 1
endif else message,'No panels of plot type ' + type + ' to show.', /info
end

;-----
; CREATE_NEW_PANEL method - hides all current panels, creates a new draw base in the main draw base,
;	and creates a new draw widget inside the new draw base.  Stores the new draw base,
;	draw widget, and window id in state structure.

pro plotman::create_new_panel, using_saved=using_saved, description=description, noplot=noplot

  widget_control, self.plot_base, get_uvalue=state
  
  ;widget_control, state.widgets.plot_base, update=0
  
  if tag_exist (state, 'w_splashdraw') then begin
    if xalive (state.w_splashdraw) then widget_control, state.w_splashdraw, /destroy
  endif
  
  self -> hide_all_panels
  
  ; on unix, widgets keep growing and and widget_info doesn't seem to return the true size.
  ;	set the size of the widget to what it was supposed to be, then get the size as it actually is.
  geom = widget_info ( state.widgets.w_maindrawbase, /geom)
  if since_version('5.5') then $
    widget_control, state.widgets.w_maindrawbase, xsize=geom.xsize, ysize=geom.ysize $
  else $
    widget_control, state.widgets.w_maindrawbase, scr_xsize=geom.scr_xsize, scr_ysize=geom.scr_ysize
  geom = widget_info ( state.widgets.w_maindrawbase, /geom)
  
  state.widgets.w_drawbase = widget_base ( state.widgets.w_maindrawbase, $
    /column, /frame, $
    xsize=geom.scr_xsize-4, ysize=geom.scr_ysize-4, $
    uname='panel_draw_base', map=0)
    
  xs = keyword_set(noplot) ? 5 : geom.scr_xsize-8
  ys = keyword_set(noplot) ? 5 : geom.scr_ysize-8
  state.widgets.w_draw = widget_draw (state.widgets.w_drawbase, $
    ;xsize=geom.scr_xsize-10, ysize=geom.scr_ysize-10, $
    xsize=xs,ysize=ys, $
    /button_events, $
    event_pro='plotman_draw_event' )
    
  widget_control, state.widgets.w_draw, get_value=window_id
  state.widgets.window_id = window_id
  if not keyword_set(noplot) then begin
    widget_control, state.widgets.w_drawbase, /map
    wset, window_id
    wshow, window_id
  endif
  ;print, 'window_id in create_new_panel = ', window_id
  widget_control, self.plot_base, set_uvalue=state
  
  ; if we're not already using saved data (from saved_data structure) then initialize saved_data
  ; structure so when we call save_panel, this new panel will be saved.
  if not keyword_set(using_saved) then self -> init_saved_data
  
;widget_control, state.widgets.plot_base, /update
  
end

;-----
; NEW_PANEL method - Calls routines needed to make a new panel -  create_new_panel, save_panel, select, and plot
; Keywords:
;	description - (same as description arg) - panel name, current time is appended to make unique
;	input - input data array, structure, or object
;	plot_type - plot type, one of 'xyplot', 'utplot', 'image', 'specplot'
;	noplot - make panel, but don't plot right now (useful if adding a bunch of panels, just plot last)
;	nodup - if set and panel with this description exists, don't add, just show the old one
;	replace - if set and panel with this description exists, delete old and replace with new
;	status - 1 if successful
;	err_msg - error message if any


pro plotman::new_panel, description, description=desc, $
    input=input, plot_type=plot_type, $
    using_saved=using_saved, $
    noplot=noplot, nodup=nodup, replace=replace, $
    status=status, err_msg=err_msg, quiet=quiet, _extra=_extra
    
  checkvar, quiet, 0
  checkvar, plot_type, self->get(/plot_type)
  checkvar, description, desc, strupcase(plot_type)
  description = description[0] ; just in case array passed in
  
  status = 1
  err_msg = ''
  
  ; if multi_panel option isn't set, get rid of existing panels, and add new one.
  if self -> get(/multi_panel) eq 0 then self -> delete_panel, /all
  
  ; if nodup is set, then check if a panel by this name is already saved, and if so,
  ; just show it instead of saving a new panel
  if description ne '' and keyword_set(nodup) then begin
    panel = self -> desc2panel(description, /number, /strip_time)
    if panel ne -1 then begin
      if ~quiet then xtext,'Using previously saved plot... ', $
        /just_reg, wait=1, /center
      self -> show_panel, panel_number=panel
      return
    endif
  endif
  
  ; if replace is set, then check if a panel by this name is already saved, and if so,
  ; delete it before saving a new panel
  if keyword_set(replace) then begin
    panel = self -> desc2panel(description, /number, /strip_time)
    if panel ne -1 then self->delete_panel, panel_number=panel
  endif
  
  if keyword_set(input) then begin
    status = self -> setdefaults(input=input, plot_type=plot_type, _extra=_extra)
    if not status then begin
      err_msg = 'Unable to add panel.  See IDL log.
      return
    endif
  endif
  
  description = description + ' (' + strmid (anytim(!stime,/ecs,/time,/trunc), 0, 8) + ')'
  self -> create_new_panel, using_saved=using_saved, description=description, noplot=noplot
  ; save data before plotting (instead of after as I was doing previously) so that it can
  ;	use saved data when plotting instead of having to retrieve it for plot, and then
  ;	retrieve it again for saving (so takes half the time)
  self -> save_panel, desc=description, _extra=_extra
  if not keyword_set(noplot) then begin
    self -> select
    status = 1
    self -> plot, status=status, err_msg=err_msg
    if not status then begin
      self -> delete_panel, /current
      a = dialog_message('PLOTMAN::NEW_PANEL - Plot error:  ' + err_msg)
    ;widget_control, self.plot_base, get_uvalue=state
    ;widget_control, state.widgets.w_message, set_value='Plot error:  ' + err_msg
    endif
  endif
  
end
