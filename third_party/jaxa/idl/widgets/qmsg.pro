;+
; Project     :STEREO - SECCHI
;
; Name        :QMSG
;
; Purpose     : Non-blocking Non-modal Popup Dialogue Widget 
;
; Category    : utility widget
;
; Explanation : This widget asks the user a yes or no question and returns the
;             : answer. It also displays a large list of data that is scrollable
;		    : 
;			 
; Syntax      : answer = qmsg(list,question)
;
; Inputs	    : list - string array data to be displayed
; 		    : question - yes or no question asked
;
; Outputs     : 'yes' or 'no'
;
; History     : Kevin Wei, 14-Jan-2010
;-


;;
; Returns string 'yes' or 'no' depending on which button is pressed
;;
pro qmsg_event, event

widget_control, event.top, get_uvalue = answer_ptr
widget_control, event.id, get_uvalue = uval

if uval eq 'yes' or uval eq 'no' then begin
	*answer_ptr = uval
	widget_control, event.top, set_uvalue = answer_ptr
	widget_control, event.top, /destroy
endif

end

function qmsg, list, txt

 ;;
 ; Error Checking
 ;;

 if n_elements(list) eq 0 then begin
 	message, 'Syntax: answer = qmsg(list,txt)',/cont
	return, -1
 endif

 if size(list,/tname) ne 'STRING' then begin
	message, 'List must be of type STRING,', /cont
	return, -1
 endif

 ;;
 ; Create buttons
 ;;

base = widget_base(title = 'Question',/column,space =10)

listlbl = widget_text(base, value = list, /scroll, ysize=n_elements(list)<20,xsize=max(strlen(list))<100 )
txtlbl = widget_text(base, value = txt)
button_base = widget_base(base,/row, space = 40, /align_center)
yes = widget_button(button_base,value = 'Yes',uvalue='yes')
no = widget_button(button_base,value = 'No',uvalue='no')

;pointer being used with empty string to return when wigit is destroyed
answer_ptr = ptr_new('')

widget_control, base, /realize, /no_copy
widget_control, base, set_uvalue=answer_ptr

xmanager, 'qmsg',base

answer = *answer_ptr
ptr_free, answer_ptr

return, answer

end
