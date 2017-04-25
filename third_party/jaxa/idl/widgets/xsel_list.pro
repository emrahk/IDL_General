;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       XSEL_LIST()
;
; PURPOSE:
;       To select one item from a list.
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       Result = XSEL_LIST(options)
;
; INPUTS:
;       OPTIONS -- String array that contains the lists.
;
; OPTIONAL INPUTS:
;       TITLE=TITLE, Title of the widget. Default: 'XSET_LIST'
;
; OUTPUTS:
;       RESULT -- Selected item (one of elements from the LISTS
;                 array). A null string is returned if no selection is
;                 made.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       INDEX   - Return index of the selected item
;                 otherwise the content of the selected item.
;       UPDATE  - Set this keyword to make selection widget editable and any
;                 new entries will be added to the given OPTIONS upon exit
;       INITIAL - Initial selection
;       STATUS  - 1/0 if Accept/Cancel is chosen
;       SENSITIVECASE - Set this keyword to treat the list case sensitive
;       NO_REMOVE - Set this keyword will prevent the "Remove" button
;                   from showing
;       LFONT   - Name of font to be used in the list widget
;       NO_SORT - If set, don't sort options list.
;
; SIDE EFFECTS:
;       The given input parameter OPTIONS may be changed if UPDATE keyword is
;       set
;
; CATEGORY:
;       Utility, widget
;
; PREVIOUS HISTORY:
;       Written September 20, 1994, by Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, NASA/GSFC, September 20, 1994
;       Version 2, Liyun Wang, NASA/GSFC, May 19, 1995
;          Added UPDATE, INITIAL, and STATUS keywords
;          Added a "Remove" button
;          Got rid of common block
;       Version 3, November 20, 1995, Liyun Wang, NASA/GSFC
;          Fixed a bug that did not update the selected item to the list
;       Version 4, December 5, 1995, Liyun Wang, NASA/GSFC
;          Added SENSITIVECASE keyword
;       Version 5, January 25, 1996, Liyun Wang, NASA/GSFC
;          Added NO_REMOVE keyword
;       Version 6, February 15, 1996, Liyun Wang, NASA/GSFC
;          Xresource option disabled for IDL version 3.5 and earlier
;       Version 7, February 22, 1996, Zarro, NASA/GSFC
;          Changed to use of pointers
;       Version 8, April 4, 1996, Liyun Wang, NASA/GSFC
;          Added LFONT keyword
;       Version 9, June 13, 1996, Liyun Wang, NASA/GSFC
;          Fixed a bug caused by grepping string arrays
;       Version 10, Jan 13, 1997, Zarro, NASA/GSFC
;          Fixed a bug in which LFONT was not being passed
;       Version 11, May 23, 1997, Liyun Wang, NASA/GSFC
;          Fixed a bug which, when INDEX keyword is set and Cancel is
;             selected, returns a string instead of a numerical -1
;       Version 12, June 13, 1997, Zarro, NASA/GSFC
;          Trimmed and sorted options list
;       Version 13, Dec 3, 2000, Kim Tolbert, added no_sort keyword
;       Feb 4, 2001, Kim, explicitly set xsize on selection text widget
;          (required for Windows)
;       Nov 12, 2001, Kim, added ysize keyword for initial ysize of
;       widget
;       Modified, 28 Feb 2007, Zarro (ADNET)
;       - moved group & modal keywords from xmanager to widget_base
;-
;

PRO xsel_get_select, info
;---------------------------------------------------------------------------
;  Get content from the selection field and add it to the list
;---------------------------------------------------------------------------
   WIDGET_CONTROL, info.select, get_value=new_str
   new = STRTRIM(new_str(0), 2)
   IF new NE '' THEN BEGIN
      opts = info.lists
      IF (grep(new, opts, /exact, sensitive=info.casesens))(0) EQ '' THEN BEGIN
         opts = [opts, new]
         sorter = SORT([opts])
         opts = opts(sorter)
         ii = WHERE(opts NE '')
         IF ii(0) GE 0 THEN opts = opts(ii)
         info = rep_tag_value(info, opts, 'LISTS')
         WIDGET_CONTROL, info.f_list, set_value=info.lists
         i = (WHERE(info.lists EQ new))(0)
         IF i NE -1 THEN BEGIN
            info.idx = i
            WIDGET_CONTROL, info.f_list, set_list_select=i
         ENDIF
      ENDIF
   ENDIF ELSE WIDGET_CONTROL, info.accept, sensitive=0
END

PRO XSEL_LIST_EVENT, event
   WIDGET_CONTROL, event.top, get_uvalue = unseen
   info=get_pointer(unseen,/no_copy)
   if datatype(info) ne 'STC' then return

   WIDGET_CONTROL, event.id, get_uvalue = uvalue
   CASE (uvalue) OF
      'QUIT': BEGIN
         info.status = 0
         xtext_reset,info
         XKILL, event.top
      END
      'DONE': BEGIN
         WIDGET_CONTROL, info.select, get_value = name_str
         new = STRTRIM(name_str(0),2)
         IF info.update THEN xsel_get_select, info
         info.status = 1
         info.result = new
         xtext_reset,info
         XKILL, event.top
      END
      'LIST': BEGIN
         info.idx = event.index
         lists = info.lists
         WIDGET_CONTROL, info.select, set_value = lists(info.idx)
         WIDGET_CONTROL, info.accept, sensitive=1
      END
      'select': xsel_get_select, info

      'remove': BEGIN
         WIDGET_CONTROL, info.select, get_value = new_str
         new = STRTRIM(new_str(0),2)
         IF new NE '' THEN BEGIN
            opts = info.lists
            ii = (WHERE(opts EQ new))(0)
            IF ii GE 0 THEN BEGIN
;---------------------------------------------------------------------------
;              Find item to be deleted; try to set next item
;---------------------------------------------------------------------------
               IF ii LT N_ELEMENTS(opts)-1 THEN $
                  new_value = opts(ii+1) $
               ELSE BEGIN
                  IF ii EQ 0 THEN new_value = '' ELSE new_value = $
                     opts(ii-1)
               ENDELSE
               IF new_value EQ '' THEN BEGIN
                  opts = ''
               ENDIF ELSE BEGIN
                  jj = WHERE(opts NE new)
                  opts = opts(jj)
               ENDELSE
               info = rep_tag_value(info, opts, 'LISTS')
               WIDGET_CONTROL, info.f_list, set_value = info.lists
               WIDGET_CONTROL, info.select, set_value = new_value
            ENDIF
         ENDIF
      END
      ELSE:
   ENDCASE

   IF WIDGET_INFO(event.top, /valid) THEN BEGIN
      WIDGET_CONTROL, info.select, get_value=str
      IF WIDGET_INFO(info.remove, /valid) THEN $
         WIDGET_CONTROL, info.remove, sensitive=info.update AND str(0) NE ''
      WIDGET_CONTROL, info.accept, sensitive=str(0) NE ''
      IF str(0) NE '' THEN BEGIN
         ii = (WHERE(info.lists EQ str(0)))(0)
         IF ii GE 0 THEN BEGIN
            WIDGET_CONTROL, info.f_list, set_list_select = ii
            info.idx = ii
         ENDIF
      ENDIF
   ENDIF

   set_pointer, unseen, info, /no_copy

END

FUNCTION XSEL_LIST, options, group=group, index=index, title=title, $
                    subtitle=subtitle, update=update, initial=initial,$
                    status=status, sensitivecase=sensitivecase, $
                    no_remove=no_remove, lfont=lfont, no_sort=no_sort, ysize=ysize

   IF N_ELEMENTS(options) EQ 0 THEN BEGIN
      IF KEYWORD_SET(update) THEN options = '' ELSE BEGIN
         popup_msg, ['Message from XSEL_LIST:','No lists provided.'],$
            title = 'Sorry'
         RETURN,''
      ENDELSE
   ENDIF

   mk_dfont,bfont=bfont,lfont=lfont

   update = KEYWORD_SET(update)
   casesens = KEYWORD_SET(sensitivecase)

;-- trim option blanks and remove duplicates

   if  keyword_set(no_sort) then begin
      lists = options
   endif else begin
      lists=trim(options)
      sorder = uniq([lists],sort([lists]))
      lists=lists(sorder)
   endelse

   xsize = MAX(STRLEN(lists))
   checkvar, ysize, 10
   IF N_ELEMENTS(title) EQ 0 THEN title = 'XSEL_LIST'

   base = WIDGET_BASE(title = title, /column,group=group)

   IF N_ELEMENTS(subtitle) EQ 0 THEN subtitle = 'Available Selections'
   IF STRTRIM(subtitle,2) NE '' THEN $
      f_title = WIDGET_LABEL(base, value=subtitle)
   f_list = WIDGET_LIST(base, value=lists, ysize=ysize, xsize=xsize, uvalue='LIST',font=lfont)

   IF N_ELEMENTS(initial) EQ 0 THEN result = '' ELSE BEGIN
      result = STRTRIM(initial,2)
      IF update AND result NE '' THEN BEGIN
;---------------------------------------------------------------------------
;        See if "result" is already in the list; if not, add it in
;---------------------------------------------------------------------------
         IF (grep(result, lists, /exact, sensitive=casesens))(0) EQ '' THEN BEGIN
            lists = [lists, result]
            ii = WHERE(lists NE '')
            IF ii(0) GE 0 THEN lists = lists(ii)
            IF N_ELEMENTS(lists) GT 1 THEN lists = lists(SORT(lists))
            WIDGET_CONTROL, f_list, set_value = lists
         ENDIF
      ENDIF
   ENDELSE

   sel_bs = WIDGET_BASE(base, /column, /frame)
   temp = WIDGET_LABEL(sel_bs, value='Selection:')
   select = WIDGET_TEXT(sel_bs, value=strpad(' ',xsize), uvalue='select', xsize=xsize)

   WIDGET_CONTROL, select, editable = update

   cmd_bs = WIDGET_BASE(base, /row, /frame)
   IF !version.release LT '3.6' THEN BEGIN
      accept = WIDGET_BUTTON(cmd_bs, value='Accept', uvalue='DONE', $
                             font=bfont)
      quit = WIDGET_BUTTON(cmd_bs, value='Cancel', uvalue='QUIT', $
                           font=bfont)
   ENDIF ELSE BEGIN
      accept = WIDGET_BUTTON(cmd_bs, value='Accept', uvalue='DONE', $
                             font=bfont, resource='AcceptButton')
      quit = WIDGET_BUTTON(cmd_bs, value='Cancel', uvalue='QUIT', $
                           font=bfont, resource='QuitButton')
   ENDELSE
   IF NOT KEYWORD_SET(no_remove) THEN BEGIN
      remove = WIDGET_BUTTON(cmd_bs, value='Remove', uvalue='remove', $
                             font=bfont)
      WIDGET_CONTROL, remove, sensitive=0

   ENDIF ELSE remove = -1L

   IF casesens THEN $
      i = (WHERE(strtrim(lists,2) EQ result))(0) $
   ELSE $
      i = (WHERE(STRUPCASE(strtrim(lists,2)) EQ STRUPCASE(result)))(0)
   IF i NE -1 THEN BEGIN
      idx = i
      WIDGET_CONTROL, f_list, set_list_select = i
      WIDGET_CONTROL, select, set_value = lists(i)
      IF NOT KEYWORD_SET(no_remove) THEN WIDGET_CONTROL, remove, sensitive=1
   ENDIF ELSE BEGIN
      idx = 0
      WIDGET_CONTROL, select, set_value=result
      WIDGET_CONTROL, accept, sensitive=result NE ''
   ENDELSE


   xrealize,base,group=group,_extra=extra,/screen

   info = {lists:lists, f_list:f_list, idx:idx, status:0, select:select, $
           result:result, update:update,remove:remove, saved:options,$
           accept:accept, casesens:casesens}

   make_pointer, unseen
   set_pointer, unseen, info, /no_copy
   WIDGET_CONTROL,base,set_uvalue=unseen


   XMANAGER, 'xsel_list', base,/modal

   info = get_pointer(unseen, /no_copy)
   FREE_POINTER,unseen
   if datatype(info) eq 'STC' then status = info.status else status=0
   IF status THEN BEGIN
      IF KEYWORD_SET(update) THEN options = info.lists
      IF KEYWORD_SET(index) THEN BEGIN
       choice=lists(info.idx)
       ifind=where(strupcase(trim(choice)) eq strupcase(trim(options)),cnt)
       return,ifind(0)
      ENDIF ELSE RETURN, info.result
   ENDIF ELSE BEGIN
      IF KEYWORD_SET(update) AND (datatype(info) EQ 'STC') THEN $
         options = info.saved
      IF KEYWORD_SET(index) THEN RETURN, -1
      IF N_ELEMENTS(initial) NE 0 THEN RETURN, initial ELSE $
         RETURN, ''
   ENDELSE
END
