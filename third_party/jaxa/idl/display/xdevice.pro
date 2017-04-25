;+
; PROJECT:
;	SDAC
; NAME: 
;	XDEVICE
;
; PURPOSE: Returns the name of the windows device suitable for current os.
;
;
; CATEGORY: DISPLAY, SYSTEM
;
;
; CALLING SEQUENCE: 
;	device = xdevice()
;	or 
;	device = xdevice(!d.name) ;returns windows device only if windows device is present.
;
;
; CALLS:
;	OS_FAMILY
;
; INPUTS:
;       Current_device - string name of current plot device.
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	IS_IT_X - Return 'X' if the passed current_device is a windowing device, X, Mac, Win.
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	Uses os_family to resolve device.
;
; MODIFICATION HISTORY:
;	Version 1, richard.schwartz@gsfc.nasa.gov, 2-feb-1998.
;-
function xdevice, current_device, is_it_x=is_it_x

arg = fcheck(current_device,'X')

list2 = ['WIN','MAC','X']
list1 = ['Windows','MacOS']

i = where(list1 eq os_family(), nmatch)
i = ([2, i])(i+1)
device = list2(i)

wx = where(strpos(list2,strupcase(arg)) ne -1, nx)


if nx then arg = device

if keyword_set( is_it_x ) then arg= ([arg,'X'])(where( arg eq list2) +1 < 1)
return, arg(0)

end



