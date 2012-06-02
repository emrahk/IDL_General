pro menu,base,num_spec,rcol,fnme,w2,prs=prs
;****************************************************************
; Routine does standard pulldown menus for widgets
; Variables are:
;       base..........widget base
;   num_spec..........number of spectra
;       fnme..........filename for saving
;        prs..........phase-resolved spectroscopy
; 6/10/94 Current version
; 8/26/94 Print statements
; 8/29/94 Fixed mistake in case loop
;********************************************************************
rcol = widget_base(base,/column)
rcol1 = widget_base(rcol,/column,/frame)
xpdmenu,['"DISPLAY"{','"1 IDF"','"ACCUM."','}'],rcol1
if (ks(prs) eq 1)then begin
   xpdmenu,['"DETS."{','"DET1"','}'],rcol1 
   str = strcompress('"' + string(indgen(num_spec)+1) +'"',/remove_all)
   xpdmenu,['"PHASE BIN"{',str,'}'],rcol1
endif else begin
   xpdmenu,['"DETS."{','"DET1"','"DET2"','"DET3"','"DET4"',$
      '"DET SUM"','"SHOW ALL"','}'],rcol1 
   case num_spec of
   0 : l = 0
   1 : xpdmenu,['"INT."{','"1 OF 1"','}'],rcol1
   2 : xpdmenu,['"INT."{','"1 OF 2"','"2 OF 2"','"SUM"','}'],rcol1
   4 : xpdmenu,['"INT."{','"1 OF 4"','"2 OF 4"','"3 OF 4"',$
         '"4 OF 4"','"SUM"','}'],rcol1
   8 : xpdmenu,['"INT."{','"1 OF 8"','"2 OF 8"','"3 OF 8"',$
         '"4 OF 8"','"5 OF 8"','"6 OF 8"','"7 OF 8"',$
         '"8 OF 8"','"SUM"','}'],rcol1
   16 : xpdmenu,['"INT."{','"1 OF 16"','"2 OF 16"','"3 OF 16"',$
         '"4 OF 16"','"5 OF 16"','"6 OF 16"','"7 OF 16"',$
         '"8 OF 16"','"9 OF 16"','"10 OF 16"','"11 OF 16"',$
         '"12 OF 16"','"13 OF 16"','"14 OF 16"','"15 OF 16"',$
         '"16 OF 16"','"SUM"','}'],rcol1
   endcase
endelse
xpdmenu,['"OPTION"{','"NET ON"','"NET OFF"','"OFF+"',$
        '"OFF-"','"ON SRC"','"ANY"','}'],rcol1
;********************************************************************
; Prompt for filename storage or not
;********************************************************************
if (fnme eq 'get idl file' or fnme eq 'get ascii file' $
     or fnme eq 'get fits file')then begin
   str = strmid(fnme,4,strlen(fnme)-4)
   str = strcompress('ENTER ' + strupcase(str))
   w3 = widget_base(rcol1,/frame,/column)
   w1 = widget_label(w3,value=str)
   w1 = widget_text(w3,value='',uvalue=33,xsize=13,ysize=1,$
        /editable)
   w2 = widget_base(rcol1,/frame,/column)
   if (fnme eq 'get fits file')then begin
      str3 = strcompress('FILE=ROOT,BKG')  
      w1 = widget_label(w2,value=str3)
      str3 = strcompress('BKG=-1,0,+1')
      w1 = widget_label(w2,value=str3)
      str3 = strcompress('FOR -,BOTH,+')
      w1 = widget_label(w2,value=str3)
   endif
endif else begin
   xpdmenu,['"SESSION"{','"SAVE"{','"ASCII FILE"','"IDL FILE"',$
           '"FITS FILE"','}',$
        '"DONE"','"CLEAR"','}'],rcol1
endelse
;********************************************************************
; Create update button for doing changes
;********************************************************************
w1 = widget_button(rcol1,value='UPDATE')
;********************************************************************
; Thats all ffolks
;********************************************************************
return
end
