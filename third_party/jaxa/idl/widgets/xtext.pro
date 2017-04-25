;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       XTEXT
;
; PURPOSE:
;       Text display widget with searching capability
;
; CATEGORY:
;       Utility, Widgets
;
; SYNTAX:
;       xtext, array
;
; EXAMPLES:
;       Useful as a pop up text widget.
;
;           xtext,'some text',/just_reg, wbase=wbase, group=event.top
;             ...some processing..
;           xkill, wbase
;
;       This example will pop a text window that will exist during
;       processing, after which it is destroyed by kill
;
; INPUTS:
;       ARRAY - string array to display
;
; KEYWORDS:
;       GROUP       - group leader of text widget parent
;       FONT        - font for text widget
;       TITLE       - title for text widget parent
;       SPACE       - number of lines to space text
;       JUST_REG    - just_reg
;       WBASE       - base widget id
;       XOFF,YOFF   - pixel offset relative to caller
;       WAIT        - secs to wait before killing widget
;       INSTRUCT    - instruction label for exit button [def = Dismiss]
;       XSIZE,YSIZE - X-Y sizes for text widget
;       APPEND      - append to existing text
;       NO_PRINT, NO_SAVE, NO_FIND - inhibit SAVE, PRINT, and FIND buttons
;       SCREEN      - center wrt to screen
;       CENTER      - center wrt to GROUP (if alive)
;       HOUR        - present hourglass
;       NEXT        - set to present a "NEXT" button (useful for
;                     running XTEXT multiple times in a loop
;       STATUS      - returned as 1 if NEXT button was pressed
;
; HISTORY:
;       Version 1, August 20, 1994, D. M. Zarro,  GSFC/ARC. Written
;       Version 2, August 25, 1995, Liyun Wang, GSFC/ARC
;          Added the capability of search string
;       Version 3, September 1, 1995, Liyun Wang, GSFC/ARC
;          Added buttons to go top, bottom, or a specific line
;          Fixed the bug that caused X windows protocol error for bad font
;       Version 4, April 12, 1996, Liyun Wang, GSFC/ARC
;          Set scrolling properly based on the array passed in
;       Version 5, April 19, 1996, Liyun Wang, GSFC/ARC
;          Added "Save to File" option to allow saving displayed
;             string array into a file
;       Version 6, February 4, 1997, Liyun Wang, NASA/GSFC
;          Highlight the line been reached via GoTo Line option
;       Modified, 27-Aug-05, Zarro (L-3Com/GSFC) - added XHOUR call
;       Modified, 28-Feb-07, Zarro (ADNET) - removed EXECUTE
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-

pro xtext_event, event

;---------------------------------------------------------------------------
;  event driver routine
;---------------------------------------------------------------------------

   widget_control, event.top, get_uvalue=unseen
   info=get_pointer(unseen,/no_copy)
   widget_control, event.id, get_uvalue=uvalue

   if datatype(info) ne 'STC' then return
   quit=0

   case uvalue OF

      'print': xprint, array=info.text, group=event.top

      'to_file': begin
        cd, curr=dir
        file = concat_dir(dir, 'xtext.txt')
        xinput, file, 'Enter output file name', group=event.top, /modal,$
         status=status
        if status then begin
         str2file,info.text,file,err=err
         if (err ne '') then xack,err,group=event.top
        endif
       end

      'close': quit=1

      'next': begin
        quit=1 & info.next=1
       end

      'top': begin
         info.line = 0
         info.pos = 0
         widget_control, info.wtext, set_text_select=0
         widget_control, info.wtext, set_text_top_line=0
         widget_control, info.flnum, set_value='1'
         widget_control, info.fcnum, set_value='1'
      end

      'bottom': begin
         info.line = info.tline
         np = info.line
         ln = long(strlen(info.text(info.tline-1)))+1L
         off_set = long(total([strlen(info.text), np]))
         widget_control, info.wtext, set_text_select=off_set
         widget_control, info.flnum, set_value=strtrim(info.tline,2)
         widget_control, info.fcnum, set_value='1'
      end

      'text': begin
         off_set = event.offset
         os = 0L
         i = 0
         ok = 1
         while (ok and i le info.tline-1) and xalive(info.flnum) DO begin
            os = os+info.line_char(i)+1L
            if os gt off_set then begin
               info.line = i
               info.pos = info.line_char(info.line)-(os-off_set)+1
               widget_control, info.flnum, set_value=strtrim(info.line+1,2)
               widget_control, info.fcnum, set_value=strtrim(info.pos+1,2)
               ok = 0
            endif
            i =i+1
         endwhile
      end

      'gline': begin
         widget_control, info.lnum, get_value=str
         if not num_chk(str(0),/integer) then begin
            line = fix(strtrim(str(0),2))-1 > 0
            if line lt info.tline then info.line = line else $
               info.line = info.tline-1
            if info.line le 0 then prev_char = 0 else $
               prev_char = info.line_char(0:info.line-1)
            np = info.line
            off_set = long(total([prev_char, np])) < info.tchar_num
            len = STRLEN(info.text(info.line))
;            pwait = 0.5
            widget_control, info.wtext, set_text_select=[off_set, len]
;            WAIT, pwait
;            widget_control, info.wtext, set_text_select=0
;            WAIT, pwait
;            widget_control, info.wtext, set_text_select=[off_set, len]
;            WAIT, pwait
;            widget_control, info.wtext, set_text_select=off_set
            
            widget_control, info.flnum, set_value=strtrim(info.line+1, 2)
            widget_control, info.fcnum, set_value='1'
         endif 
      end

      'find': begin
         widget_control, info.search_lb, get_value=tt
         tt = strtrim(tt(0),2)
         if tt ne '' then begin
            xhour
            if not info.case_sense then tt = strupcase(tt)
            if info.line ge info.tline then begin
               info.line = 0
               info.pos = 0
            endif
            go_on = 1
            while (go_on) DO begin
               if not info.case_sense then $
                  text = strupcase(info.text(info.line)) $
               else $
                  text = info.text(info.line)
               if info.line ge 1 then begin
                  prev_char = info.line_char(0:info.line-1)
                  np = info.line
                  off_set = long(total([prev_char, np]))
               endif else off_set = 0L
               idx = strpos(text, tt, info.pos)
               if idx ge 0 then begin
                  length = strlen(tt)
                  widget_control, info.wtext, $
                     set_text_select=[off_set+idx, length]
                  widget_control, info.flnum, $
                     set_value=strtrim(info.line+1,2)
                  widget_control, info.fcnum, set_value=strtrim(idx+1,2)
                  info.pos = idx+length
                  go_on = 0
               endif else begin
                  info.pos = 0
                  info.line = info.line+1
                  if info.line ge info.tline then begin
                     info.line = 0
                     widget_control, info.wtext, set_text_select=0
                     widget_control, info.wtext, set_text_top_line=0
                     widget_control, info.flnum, set_value='1'
                     widget_control, info.fcnum, set_value='1'
                     go_on = 0
                  endif
               endelse
            endwhile
         endif
      end

      'chg_case': info.case_sense = event.select
      else:
   endcase

   wbase=info.wbase
   set_pointer,unseen,info,/no_copy

   if quit then begin
    xtext_cleanup,[wbase,event.top]
    xkill,[wbase,event.top]
   endif

   return & end


;---------------------------------------------------------------------------


pro xtext_cleanup,id

nid=n_elements(id)
if nid eq 0 then return
if nid gt 1 then begin
 for i=0,nid-1 do xtext_cleanup,id(i)
endif else begin
 widget_control,id,get_uvalue=unseen
 info=get_pointer(unseen,/no_copy)
 if datatype(info) eq 'STC' then begin
  dprint,'% XTEXT: cleaning up...'
  xtext_reset,info
  xshow,info.group
  set_pointer,unseen,info,/no_copy
 endif
endelse
return & end

;---------------------------------------------------------------------------
;  Main routine
;---------------------------------------------------------------------------

pro xtext, array, font=font, title=title, group=group, modal=modal, $
           space=space, just_reg=just_reg, scroll=scroll, $
           append=append, wbase=wbase, wait=wait,hour=hour, $
           instruct=instruct, xsize=xsize, ysize=ysize,no_save=no_save,$
           no_print=no_print,_extra=extra,no_find=no_find,next=next,$
           status=status,unseen=unseen,detach=detach,no_block=no_block,$
           center=center

   status=0

   if not allow_windows() then return

   detach=keyword_set(detach)
   no_block=keyword_set(no_block)

   if (datatype(array) ne 'STR') then begin
;    message, 'input must be a string',/cont
    return
   endif

;-- initialize

   just_reg=keyword_set(just_reg)
   update=xalive(wbase)
   if just_reg then def_space=2 else def_space=0
   if not exist(space) then space=def_space
   modal=keyword_set(modal)
   just_reg_sav = just_reg
   if update then just_reg = 1
   append = keyword_set(append)

   if datatype(title) eq 'STR' then wtitle = title else wtitle = 'XTEXT'
   if (space gt 0) then begin
    buff = replicate(' ', space) & text=[buff, detabify(array), buff]
   endif else text = detabify(array)
   tline = n_elements(text)
   line_char = strlen(text)
   tchar_num = total([long(line_char), tline])
   
   if not update then begin

;-- fonts

    if datatype(font) eq 'STR' then tfont=font
    mk_dfont,bfont=bfont,lfont=lfont,tfont=tfont

    if not keyword_set(scroll) then $
     scroll = (n_elements(text) gt 50 or max(strlen(text)) gt 80)
    if n_elements(ysize) eq 0 then ysize = n_elements(text) < 40
    if n_elements(xsize) eq 0 then xsize = max(strlen(text)) < 80
    wbase=widget_base(title=wtitle,/column,group=group) 
    wtext = widget_text(wbase, /frame, value=text, uvalue='text',$
                        font=tfont, scroll=scroll, all_event=(not just_reg), $
                        ysize=ysize, xsize=xsize)

;---------------------------------------------------------------------------
;     If not just registering then add search and close buttons and
;     call XMANAGER
;---------------------------------------------------------------------------

    if not (just_reg) then begin
     case_sense = 0
     if detach then $ 
      wbase1=widget_base(/column,event_pro='xtext_event',group=wbase) else $
       wbase1=widget_base(wbase,/column)
     if not keyword_set(no_find) then begin
      temp = widget_base(wbase1, /row, /frame)
      tmp = widget_label(temp, value=' Go To:', font=bfont)

      tmp = widget_button(temp, value='Line', uvalue='gline', $
       font=bfont,/no_rel)
      lnum = widget_text(temp, value='', xsize=5, /edit, uvalue='gline')

      tmp = widget_label(temp, value=' ', font=bfont)
      top = widget_button(temp, value='Top',uvalue='top',font=bfont,/no_rel)
      tmp = widget_label(temp, value=' ', font=bfont)
      bottom = widget_button(temp, value='Bottom', uvalue='bottom',$
       font=bfont,/no_rel)

      temp = widget_base(wbase1, /column, /frame)
      junk = widget_base(temp, /row)
      tmp = widget_button(junk, value='Find', uvalue='find',font=bfont,/no_rel)
      search_lb = widget_text(junk, value='', xsize=20, /edit, $
       uvalue='find', font=lfont)
         
      tmp = widget_label(junk, value=' Case', font=lfont)
      xmenu, 'sensitive', junk, /nonexcl, uvalue='chg_case',buttons=tmp,font=lfont
      widget_control, tmp(0), set_button=0

      junk = widget_base(wbase1, /row, /frame)
      tmp = widget_label(junk, value=' Cursor Position:  line', font=lfont)
      flnum = widget_text(junk, value='', xsize=5, font=lfont)
      tmp = widget_label(junk, value='  column', font=lfont)
      fcnum = widget_text(junk, value='', xsize=3, font=lfont)
     endif else begin
      search_lb=0
      flnum=search_lb
      lnum=flnum
      fcnum=flnum
     endelse

     junk = widget_base(wbase1, /row,xpad=20, space=20)
     if datatype(instruct) eq 'STR' then bname = instruct else bname = 'Dismiss'

;-- PRINT and SAVE buttons

     tmp = widget_button(junk, value=bname, uvalue='close',font=bfont,/no_rel)
     if keyword_set(next) then tmp=widget_button(junk,value='Next',uvalue='next',font=bfont)
     if not keyword_set(no_print) then $
      tmp = widget_button(junk, value='Print', uvalue='print', $
       font=bfont,/no_rel)
     
     if not keyword_set(no_save) then $
      tmp = widget_button(junk, value='Save to File', uvalue='to_file', $
       font=bfont,/no_rel)
    endif

;---------------------------------------------------------------------------
;     determine placement
;---------------------------------------------------------------------------
    if not xalive(wbase1) then wbase1=wbase

    center=keyword_set(center)
    xrealize,wbase,group=group,_extra=extra,screen=just_reg and (1-center),center=center
    if detach then widget_control,wbase1,/realize
    child=widget_info(wbase,/child)
    if xalive(child) then sibling=widget_info(child,/sibling)
    if xalive(sibling) then widget_control,sibling,set_uvalue=wtitle
    if not just_reg then begin
     make_pointer, unseen
     info = {case_sense:case_sense, search_lb:search_lb, line:0, $
             text:text, tchar_num:tchar_num, next:0,wbase1:wbase1,$
             wtext:wtext, wbase:wbase,pos:0, tline:tline, flnum:flnum, $
             fcnum:fcnum, lnum:lnum, line_char:line_char,group:0l}
     if xalive(group) then info.group=group
     set_pointer,unseen,info,/no_copy
     widget_control, wbase, set_uvalue=unseen
     if detach then widget_control,wbase1,set_uvalue=unseen
    endif
   endif else begin
    wtext = widget_info(wbase, /child)
    widget_control,wtext,set_text_top_line=0
    widget_control, wtext,set_value=text,append=append
    widget_control, wbase, tlb_set_title=wtitle
    widget_control,wbase,get_uvalue=unseen
    info=get_pointer(unseen,/no_copy,/quiet)
    if datatype(info) eq 'STC' then begin
     info=rep_tag_value(info,text,'text')
     info.tchar_num=tchar_num
     info.tline=tline
     info=rep_tag_value(info,line_char,'line_char')
     wbase1=info.wbase1
     set_pointer,unseen,info,/no_copy
     widget_control, wbase, set_uvalue=unseen
     if detach then widget_control,wbase1, set_uvalue=unseen
    endif
    xshow,wbase
    xshow,wbase1
    goto,done
   endelse

;-- cleanup

   if not just_reg then begin
    if idl_release(lower=5,/inc) then $
     xmanager, 'xtext', wbase,just_reg=just_reg,modal=modal,no_block=no_block,cleanup='xtext_cleanup' else $
      xmanager, 'xtext', wbase,just_reg=just_reg,modal=modal,cleanup='xtext_cleanup'
endif

   if no_block then return
   just_reg = just_reg_sav
   if (just_reg) or modal or keyword_set(next) then begin
    info=get_pointer(unseen,/no_copy,/quiet)
    if datatype(info) eq 'STC' then status=info.next
    free_pointer,unseen
    if modal then xshow,group
   endif

done:
   if (n_elements(wait) gt 0) and (just_reg) then begin
    wait, wait & xkill, wbase
   endif
   if keyword_set(hour) then xhour
   if get_caller() eq '' then free_pointer,unseen
   return
   end
