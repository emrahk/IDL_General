;+
;
; File WINUP.PRO
;   routines: GET_MY_WINDOWS, REMOVE_MY_SAVED, WINUP_EV, WINUP
;
;-

;============================================================================

;+
;
;  FUNCTION GET_MY_WINDOWS
;
;  Creates and returns a string array containing all active IDL window,
;  and if any windows were saved to the window_array common with WINUP.PRO
;  then a description will also be present.
;
;  Calling sequence:    x = GET_MY_WINDOW
;
;  INPUT: 	none
;  OUTPUT:	string array of alll active window
;
;  COMMON: 	window_array 
;
;-

function get_my_windows

@winup_common

	device, window=w				; get active windows
	indexs=where(w)	& active=n_elements(indexs)	
	if indexs[0] eq -1 then begin			; no windows active
		list = 'No active windows'
		windows_index=-1
		windows_title=''
		return, list
	endif

	list = strarr(active)
	for i = 0, active-1 do begin		; for each active window
		; If this window's information was saved to the common
	        ;	then it will have a nice title associated with it
		;	else only the index number can be shown
		present = where(windows_index eq indexs[i]) 
		if present[0] ne -1 then begin 
		   list[i] = string(strtrim(windows_index[present],2),'(a3)') $
			 	+ '   ' + windows_title[present]  
		endif else begin 	; not recorded
			list[i] =string(strtrim(indexs[i],2),'(a3)') 
		endelse
	endfor
		   
return,list
end




;============================================================================

;+
;
; PRO REMOVE_MY_SAVED, [INDEX=INDEX]
;
; If the provided index number has been saved to the common window_array 
; then remove it and it's associated description from the commaon arrays.
; This reduces the arrays' size by one
;
; input: 
;	INDEX : 
;
;-


pro remove_my_saved, index=index
@winup_common

   rem = where(windows_index eq index)	; check common for this window   

   if rem[0] ne -1 then begin  			; was it saved before
      maxele = n_elements(windows_index) - 1

      n1 = rem[0]-1
      n2 = rem[0]+1
      n3 = maxele
      if maxele -1 lt 0 then begin   	; get rid of only element
		windows_index=-1 
		windows_title='' 
      endif else case 1 of
		n1 lt 0: begin		 ; get rid of first element
		 	 windows_index= windows_index[n2:n3]
		    	 windows_title= windows_title[n2:n3]
			 end
		n2 gt maxele : begin	 ; get rid of last element
		 	       windows_index= windows_index[0:n1]
		    	       windows_title= windows_title[0:n1]
			       end
		else : begin		 ; get rid of any middle element
		       windows_index=[windows_index[0:n1], windows_index[n2:n3]]
		       windows_title=[windows_title[0:n1], windows_title[n2:n3]]
		       end
		endcase
   endif 

return
end

;============================================================================

;+
;
; PRO WINUP_EV, EVENT
;
; Event handler for WINUP.PRO
;
;-

pro winup_ev, event
@winup_common

 widget_control, event.id, get_uvalue=input        ; user's name for widget
 widget_control, event.top, get_uvalue=pass        ; get stuff passed as
						   ;   a structure

 type = strmid(tag_names(event, /structure_name), 7, 4)  ; type of widget

 case type of 						    ; (button, list...)

    'BUTT' :  begin
      case input of   			; which button was selected
        'QUIT'   : begin
		   widget_control, event.top, /destroy   ; kill top widgets
		   end

	'DELETE' : begin
		   if pass.number eq -1 then return	; nothing to delete
		   wdelete, pass.number		; delete IDL window

		   remove_my_saved, index=pass.number

		   ; re-write widget with updated information
		   list=get_my_windows()
		   widget_control, pass.dlist, set_value=list, set_uvalue=list

		   end

	'DELALL' : begin
		      device,window=w			; get active windows
		      exists=where(w eq 1, count)	; windows' indexes
		      for i = 0, count-1 do wdelete, exists[i]
		      windows_index=-1 
		      windows_title='' 
		      widget_control, event.top, /destroy   ; kill top widgets
		   end
	else: message, 'Error matching case input in WINUP_EVENT'

      endcase
    end

    'LIST' : begin
	pass.place = event.index
       	value=input[pass.place] 	; file user selected from list
	if value[0] eq 'No active windows' then return
	pass.number = fix(strmid(value[0], 0, 3))  ; extract just index number
	widget_control, event.top, set_uvalue=pass	; save it
    end       

    else: return
 endcase

return
end

;=============================================================================

;+
; PROJECT:
;	SDAC
; NAME:
;	WINUP
; USE:
; 	WINUP, [/ALL, MESSAGE=MESSAGE, group_leader=group]
 	
;	WINUP, index, /ADD, [TITLE=TITLE, MESSAGE=MESSAGE]
; 	ADDS window indentifing information to the window_array common
;
; 	WINUP, [index], [TITLE=TITLE, MESSAGE=MESSAGE, COLORS, PIXMAP RETAIN,
;		XPOS, YPOS, XSIZE, YSIZE]
; PURPOSE:
;	CREATES a new window as with the WINDOW command but also adds the
;	indentifing information to the window_array common or provides
;	a widget dialog for deleting existing windows.
; 
; Description:
;	Depending on calling sequence this program either:
;	 Deletes an existing window via widget list selections
;	 or Adds window information about an existing window
;	 Creates a window for scratch
;   	DELETES: puts up a widget from which the user will select windows to
;	be deleted. Values in the widget are obtained from the window_array 
;	common.  If keyword all is present and non-zero then 
;	ALL active windows will be deleted.
;;
;   
; INPUTS:
; 	index	: The window index number of a window to be created or added 
;		  to the  window_array common block. Not needed when the 
;		  keyword FREE is used in the case of window creating.
; KEYWORDS:
;	ALL   	: indicates that all window will be summarily deleted
;	ADD  	: indicates that the window already exists and is just being
;		  added to the common WINDOW_ARRAY.  
; 	TITLE 	: When adding an already created window TITLE is any string 
;		  When creating a window TITLE is what appears in the banner
;		  it was input to the window's banner
;	COLORS, FREE, PIXMAP RETAIN, XPOS, YPOS, XSIZE, YSIZE:
;		  are the same a if WINDOW was being used
;       GROUP   : The widget id of a calling widget, so that when the calling
;		  widget is kill the deletion widget will be killed too.
; OUTPUT:
;	MESSAGE : a string is return with possible status information
;
;
; COMMON WINDOW_ARRAY,  WINDOWS_INDEX contains the index number 
;		        WINDOWS_TITLE contains the title
; History:
;	Extracted by Richard Schwartz from an Elaine Einfalt procedure, ~1993
;       27-Sep-2010, William Thompson, use [] indexing
;
;-

pro winup, number, all=all, add=add, title=title, colors=colors, free=free, $
	pixmap= pixmap, retain=retain, xpos=xpos, ypos=ypos, xsize=xsize, $
	ysize=ysize, message=message, group_leader=group
@winup_common

if n_elements(all) ne 0 then if all ne 0 then begin	; delete all windows
   device,window=w				; get all active windows
   exists=where(w eq 1, count)			; existing windows' indexes
   for i = 0, count-1 do wdelete, exists[i]
   return
end

if xregistered('winup') then return		; only one active at a time

; if there are no windows in the common window_array, yet
if n_elements(windows_index) eq 0 then windows_index=-1


case 1 of

   (n_elements(number) eq 0) and (n_elements(free) eq 0) : begin
	; there is niether an index number nor a request for an index number
 	;
	;	DELETING:
	;
	;  	Create a widget populated with all active windows
	;	for the purpose of deletion. 
	;	The windows stored in common window_array will have 
	;	a helpful description

	if (!d.flags and 65536) eq 0 then begin
		message = 'Requires widget capability'
		return			    ; can't do without widgets
	endif

	list=get_my_windows()


	; Now that LIST holds all the active windows, create a widget
	; so that the user may delete

	base = widget_base(title='Delete IDL windows', /column, xpad=20, $
					ypad=20, space=20)
	     lab = widget_label(base, value='Click on windows to be deleted')

	     dall= widget_button(base, value='DELETE ALL WINDOWS', $
					   uvalue='DELALL')

	     dlist = widget_list(base, ysize=10, value=list, uvalue=list)
;	     contrl = widget_base(base, space=20, /row)
	     del = widget_button(base, value='DELETE SELECTED WINDOW', $
					   uvalue='DELETE')
	     qut = widget_button(base, value='QUIT'  , uvalue='QUIT')
	widget_control, base, /realize

	; load everything that needs to be passed to the event handler
	;	into a structure and stuff it into UVALUE
	pass = { winup, base:base,	       		$	; main widget id
			number:-1,			$ 	; window index
			place:-1,			$ 	; array index
			dlist:dlist}        			; list widg id

	widget_control, base, set_uvalue = pass


	xmanager, 'winup', base, event_handler='winup_ev', $
				      group_leader=group, /modal


        message = 'Completed window deletion'
      end

   (n_elements(add) ne 0) and (n_elements(number) ne 0): begin
	; add keyword mean adding an existing window but there must be 
	; a suppied index number
	;
	;	ADDING:
	;
	;  	An existing window is just being added to the list,
	;	 it will be easier to deleted later if user suppies a title
	;

	if number lt 0 then begin
	   message = 'Window index must be greater than or equal to zero'
	   return
	endif

	remove_my_saved, index=number		; Remove current window
					        ; information if it already 
						; exists. New values will be
						; suppied below

	if n_elements(title) eq 0 then title=''		; no supplied title

	if windows_index[0] ne -1 then begin		
		windows_index = [windows_index, number] ; add index to common
		windows_title = [windows_title, title]  ; add title to common
  	endif else begin				
		windows_index = number			; first index in common
		windows_title = title			; first title in common
	endelse

	message = 'Added index ' + strtrim(number,2) + '/' + title
      end

   ((n_elements(number) ne 0 or n_elements(free) ne 0))  $
	and (n_elements(add) eq 0): begin
	; there is either an index number or a a request or an index number
	; but not an ADD keyword (which means /ADD fail the previous case)
	;
	;  	CREATING:
	;
	;  	Create a window as if with WINDOW but add it to the 
	; 	WINDOW_ARRAY common for possible deletion later
	;	ADD and  MESSAGE are keyword used for the program
	;

	com_str = ''

	; must have one of these two to be at this part of code
        if n_elements(number) ne 0 then $		; index entered
	   if number ge  0 then $			;   has a valid number
		com_str= com_str + ',' + string(number) $
	   else free=1					; invalid index #
  
	if n_elements(free) ne 0 then $			; takes presendence
	   if free ne 0 then com_str= com_str + ',free=' + string(free)


	; possible window keywords
	if n_elements(colors) ne 0 then $
		com_str= com_str + ',colors=' + string(colors)
	if n_elements(pixmap) ne 0 then $
		com_str= com_str + ',pixmap=' + string(pixmap)
	if n_elements(retain) ne 0 then $
		com_str= com_str + ',retain=' + string(retain)

	if n_elements(xpos) ne 0 then $
		com_str= com_str + ',xpos=' + string(xpos)
	if n_elements(ypos) ne 0 then $
		com_str= com_str + ',ypos=' + string(ypos)
	if n_elements(xsize) ne 0 then $
		com_str= com_str + ',xsize=' + string(xsize)
	if n_elements(ysize) ne 0 then $
		com_str= com_str + ',ysize=' + string(ysize)

	if n_elements(title) ne 0 then $
		com_str= com_str + ',title="' + title + '"'

	stat=execute('window' + com_str)
	
	if n_elements(title) eq 0 then title='IDL ' + strtrim(!d.window,2)
	if n_elements(free) ne 0 then if free ne 0 then number=!d.window

	remove_my_saved, index=number		; Remove current window
					        ; information if it already 
						; exists. New values will be
						; suppied below

	if windows_index[0] ne -1 then begin		
		windows_index = [windows_index, number] ; add index to common
		windows_title = [windows_title, title]  ; add title to common
  	endif else begin				
		windows_index = number			; first index in common
		windows_title = title			; first title in common
	endelse

	if stat eq 1 then message = 'Created and added index ' + $
				strtrim(!d.window,2) + '/' + title $
	else message = 'Error contructing window command - WINUP'
      end


   else:  message='Incorrect number of parameters or keywords - WINUP'
	 
endcase


if n_elements(message) eq 0 then message=''
return
end
