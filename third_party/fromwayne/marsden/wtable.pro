pro wtable,base,dt,idfs,idfe,cp,livetime,chisqr,nfree
;****************************************************************************
; Routine constructs the standard widget header
; Variables are:
;      base.............The base for the header 
;        dt.............start,stop date and time string array
; idfs,idfe.............start,stop idfs
;        cp.............cluster position string
;  livetime.............livetime
;    chisqr.............chisquared for fitting
;     nfree.............# of degrees of freedom
; 6/10/94 Current version
;****************************************************************************
r1 = widget_base(base,/row,/frame)
row1 = widget_base(r1,/column)
w1 = widget_label(row1,value = 'START DATE:')
w1 = widget_text(row1,value=dt(0,0),uvalue=0,xsize=10,ysize=1)
w1= widget_label(row1,value = 'STOP DATE:')
w1 = widget_text(row1,value=dt(1,0),uvalue=0,xsize=10,ysize=1)
row2 = widget_base(r1,/column)
w1 = widget_label(row2,value='START TIME:')
w1 = widget_text(row2,value=dt(0,1),uvalue=2,xsize=8,ysize=1)
w1 = widget_label(row2,value='STOP TIME:  ')
w1 = widget_text(row2,value=dt(1,1),uvalue=2,xsize=8,ysize=1)
row2_6 = widget_base(r1,/column)
w1 = widget_label(row2_6,value='IDF START:   ')
w1 = widget_text(row2_6,value=idfs,uvalue=3,xsize=15,ysize=1)
w1 = widget_label(row2_6,value='IDF STOP:    ')
w1 = widget_text(row2_6,value=idfe,uvalue=1,xsize=15,ysize=1)
row2_5 = widget_base(r1,/column)
w1 = widget_label(row2_5,value='LAST POSITION:')
w1 = widget_text(row2_5,value=cp,uvalue=5,xsize=17,ysize=1)
w1 = widget_label(row2_5,value='LIVETIME:     ')
w1 = widget_text(row2_5,value=livetime,uvalue=7,xsize=10,ysize=1)
;****************************************************************************
; Do the chisquared/DOF if chisqr present. Round to thousands
;****************************************************************************
if (keyword_set(chisqr) ne 0)then begin   
   row2_7 = widget_base(r1,/column)
   w1 = widget_label(row2_7,value='CHISQUARED/DOF:')
   ch = widget_text(row2_7,value=strcompress(chisqr),$
   uvalue=5,xsize=17,ysize=1)
   w1 = widget_label(row2_7,value='D.O.F.:')
   nu = widget_text(row2_7,value=strcompress(nfree),$
   uvalue=7,xsize=10,ysize=1)
endif
;****************************************************************************
; Thats all ffolks
;****************************************************************************
return
end
