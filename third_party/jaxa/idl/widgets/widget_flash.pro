;+ 
; NAME:
;             WIDGET_FLASH 
; PURPOSE:
;             routine to create an eye-catching flashing widget
; CATEGORY: 
;             widgets 
; CALLING SEQUENCE:
;             widget_flash,mess,label
; INPUTS:
;             mess=string message to be flashed
;             label=ID of widget to be flashed
; OPTIONAL INPUTS:
;             delay=secs between flashing
; COMMON BLOCKS:
;             COMMON fsign,fmess,flabel,fdelay  
;
;             This is the only way I know of communicating information 
;             (such as the flash delay time) to the flashing background event.
; PROCEDURE:
;             Flashes a message by toggling between printing the message
;             and a blank string.
; RESTRICTIONS: 
;             Background flasher routine must be registered first by:
;
;             XMANAGER,'NAME',BACKGROUND='FLASH_BCK'
;
;             where NAME is the main widget application.
;             Flashing widget should preferably be a label type or else
;             strange things will occur!
; EXAMPLE:
;             The flashing widget can be initiated by:
;              
;             WIDGET_FLASH,'YOUR FLASHING MESSAGE HERE', FLABEL
; 
;             where FLABEL is the id of the widget that you wish to flash.
;             After initiating the flashing widget, you can change the 
;             message by:
;
;             WIDGET_CONTROL,FLABEL,SET_VALUE='YOUR NEW FLASHING MESSAGE HERE'
;    
;
; MODIFICATION HISTORY:
;             written Jan'92 by: Dominic Zarro 
;             (Applied Research Corp. Landover MD)
;-


pro flash_bck,topid        ;-- WIDGET FLASHER (background routine)

common fsign,fmess,flabel,fdelay

if n_elements(flabel) eq 0 then flabel=topid
if n_elements(fmess) eq 0 then fmess=''
widget_control,flabel,set_value=fmess        ;-- turn-on
if n_elements(fdelay) eq 0 then fdelay=1
wait,fdelay
widget_control,flabel,set_value='      '     ;-- turn-off

return & end

;----------------------------------------------------------------

pro widget_flash,mess,label,delay     ; FLASH initiator

;-- pass MESS and LABEL to background routine via COMMON

common fsign,fmess,flabel,fdelay  

on_error,1
if n_elements(label) eq 0 then  message,'need a valid a widget label' 
if n_elements(delay) eq 0 then delay=1
if n_elements(mess) eq 0 then mess='EAT AT JOES'

fmess=mess & flabel=label & fdelay=delay

return & end

