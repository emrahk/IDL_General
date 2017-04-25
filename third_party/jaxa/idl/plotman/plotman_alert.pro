FUNCTION PLOTMAN_ALERT, message, XOffSet=xoff, YOffSet=yoff

   ; Put up a message box

IF N_PARAMS() EQ 0 THEN message = 'Please wait...'
Device, Get_Screen_Size=screenSize
IF N_ELEMENTS(xoff) EQ 0 THEN xoff = (screenSize(0)/2.0 - 100)
IF N_ELEMENTS(yoff) EQ 0 THEN yoff = (screenSize(1)/2.0 - 75)

tlb = Widget_Base(Title='Writing a File...', XOffSet=xoff, YOffSet=yoff)
label = Widget_Label(tlb, Value=message)
Widget_Control, tlb, /Realize
RETURN, tlb
END ;*******************************************************************