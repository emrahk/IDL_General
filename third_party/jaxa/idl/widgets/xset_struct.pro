;+
; Name: XSET_STRUCT
;
; Purpose: Set up the structure for control parameter display.
;
; Category: OSPEX
;
; Written: 09-Aug-2004, Kim Tolbert/Sandhia Bansal
; Modifications:
;   5-Nov-2004, Kim.  status return value wasn't set if answer was not 'yes'
;   18-Nov-2009,Kim.  Use xanswer instead of dialog_message, so user can suppress warning in future.
;-
;---------------------------------------------------------------------------


function xset_struct, title, group, control, substr


;answer = dialog_message (['Caution!  This option is for experienced users only.', $
;         'Setting parameters wrong could make the object unusable.', $
;         '', 'Do you want to continue?'], $
;         /question, title='Warning!')
;         
msg = ['Caution!  This option is for experienced users only.', $
       'Setting parameters wrong could make the object unusable.', $
        '', 'NOTE: You will not be able to set values in nested structures.', ''] 
        
answer = xanswer(msg, /suppress, instruct='Do you want to continue?')
              
;if strlowcase(answer) eq 'yes' then begin
if answer then begin
   xhour

   hsi_ui_getfont, font, big_font, small_font=small_font
   xstruct, control, $
            /edit, $
            group=group, $
            title=title+' Control Parameters', $
            nx=5, xsize=10, /center, $
            /modal, $
            lfont=small_font, tfont=small_font, $
            status=status, c_tags=c_tags
   if status and c_tags[0] ne -1 then begin
      substr=str_subset(control, (tag_names(control))[c_tags])
   endif else status = 0
endif else status=0

return, status


end
