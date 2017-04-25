;+
; Name: plotman__multi_overlay
; Purpose: Allow users to select panels for overlays for a number of base panels at once by matching patterns
; and/or selecting closest times.
; 
; Method: This is called from plotman__multi_panel.  User selects base panels from multi-panel
;  widget, then clicks 'Set Multi Overlays'. Initial widget will show base panels, and at least one
;  overlay widget for panel selection. If overlay panels are already selected for any of base panels,
;  then initial widget shows enough overlay panels to show all currently selected overlays.
;
; Written, Kim Tolbert, 10-Jan-2010
; 02-Feb-2010, Kim. Added more complicated searching using ! (required text) and * (wildcard)
; 05-Feb-2010, Kim. Use xdisplayfile instead of dialog_message to show help so it doesn't block overlay widget
; 03-Mar-2015, Kim. Call strep2 instead of strep (DMZ renamed it)
;-

;------
;
; Function to find pattern in input array of strings.
; Converts '*' wildcard in pattern to '.*' for stregex. 
; Returns indices of matches of pattern in input array, and number of matches (in count)
function plotman_multi_overlay_find, input, pattern, count
patt = str_replace(pattern,'*','.*')
ind = stregex(input, patt, /fold_case, /bool)
q = where(ind eq 1, count)
return, q
end

;------
;
; Return search pattern.  If pattern1 has !(s), find values in input string in location of ! (anchored by
; whatever is adjacent to the !(s), and construct search pattern by replacing the corresponding locations
; in pattern2 that have !! (anchored by whatever they're adjacent to), e.g.
; input='Sim 2 blah blah', pattern1='Sim!!', pattern2='Recon!!*back*', then return 'Recon 1*back*
; (the !! anchored by 'Sim' has value ' 2', so ' 2' replaces the !! anchored by 'Recon' in pattern2
; If pattern1 has no !, then replace pattern1 by pattern2 in input string and return that.

function plotman_multi_overlay_replace, input, pattern1, pattern2

p1 = strlowcase(pattern1)
p2 = strlowcase(pattern2)

if strpos(p1,'!') ne -1 then begin

  ; First make sure we have same number of ! groups in p1 and p2
  n1 = numchar(rem_mult_char(p1,'!'), '!')  & n2 = numchar(rem_mult_char(p2,'!'), '!')
  if n1 ne n2 then return, 'ABORT' 
  
  ; Modify user's pattern1 with something stregex can use
  ; Replace groups of ! with (.) for stregex.  e.g. !!! -> (...).  Also replace any *s with
  ; .* for stregex.
  ind = str_index(p1, '!')
  groups = find_contig(ind, ss1, ss2)
  ngroups1 = n_elements(groups)
  ind = reform(transpose(ind[ss2]))
  for i=ngroups1 - 1, 0, -1 do begin
    p1 = strinsert(p1, ')', ind[1,i]+1)
    p1 = strinsert(p1, '(', ind[0,i])
  endfor
  p1 = str_replace(p1, '!', '.')
  p1 = str_replace(p1, '*', '.*')
  ;stregex will return and array containing the entire string matched, followed by the strings
  ; in the subexpressions.  We only want the subexpression strings, so want matches[1:*]
  matches = stregex(input, p1, /subexp, /extract, /fold_case)
  if n_elements(matches) gt 1 then begin
    subexp = matches[1:*]
    ;Replace '!' groups with single !, Then replace ! with subexp[i] in left to right order one by one. Once 
    ; we do a replace have to call strpos again, since next ! might be shifted by replace.  Don't use str_replace
    ; because that replaces all occurrences, strep2 just replaces first.
    ; If run out of ! p2 before we run out of subexp elements, set p2 to 'bad' and return.
    p2 = rem_mult_char(p2, '!')
    for i = 0, n_elements(subexp)-1 do begin
      ind = strpos(p2, '!')
      if ind[0] eq -1 then return, 'BAD'   
      p2 = strep2(p2, '!', subexp[i], /notrim)
    endfor
  endif
  
endif else begin
  ; There are no ! in p1.  p2 to return is input string with p1 pattern replaced by p2 (and remove time stamp)
  qb = where (strpos(strlowcase(input), p1) ne -1, count)
  if count gt 0 then begin        
    p2 = str_replace(strlowcase(input), p1, p2)
    ; get rid of (time) at end of panel when looking for matches
    temp = ssw_strsplit (p2, '(', /tail, head=head)
    p2 = head[0]
  endif
endelse 

return, p2

end

;-----  Event handler for multi_overlay (can't be a method, so this calls the method)

pro plotman_multi_overlay_event, event
widget_control, event.top, get_uvalue=state
state.plotman_obj -> multi_overlay_event, event
end

;-----

pro plotman::multi_overlay_event, event

if tag_names(event,/struc) eq 'WIDGET_KILL_REQUEST' then goto, exit

widget_control, event.top, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue

case uvalue of

  'find': begin
    iover = (where (state.w_find  eq event.id))[0]
    widget_control, state.w_ov_patt1[iover], get_value=patt1
    widget_control, state.w_ov_patt2[iover], get_value=patt2 
    closest = widget_info(state.w_closest[iover], /button_set)
    patt1 = trim(patt1) & patt2 = trim(patt2)
    basep = state.panel_desc[state.p_sel]
        
    ; If no patterns to search for, set overlay panels to base panels
    if patt1 eq '' and patt2 eq '' then begin
      plist = basep
      goto, done
    endif

    baset = get_edges(self->get_panel_times(state.p_sel), /mean)
    nbase = n_elements(state.p_sel)
    plist = strarr(nbase)
    if patt1 eq '' then begin
      qpatt2 = plotman_multi_overlay_find(state.panel_desc, patt2, kpatt2)
;      qpatt2 = where (strpos(state.panel_desc, patt2) ne -1, kpatt2)
      if kpatt2 gt 0 then tpatt2 = get_edges(self -> get_panel_times(qpatt2), /mean) else goto, done
    endif

    for i=0,nbase-1 do begin
    
      ; if no base pattern, then use panels that match patt2.  If closest set, find closest in time,
      ; otherwise just use them in order.  If not enough, repeat the last one found.
      if patt1 eq '' then begin
        if closest then begin
          qn = where_near(tpatt2, baset[i])
          plist[i] = state.panel_desc[qpatt2[qn]]
        endif else plist[i] = state.panel_desc[qpatt2[i < (kpatt2-1)]]          

      endif else begin
      
        ; if base pattern set, first make sure that pattern is in base panel.
        ; if so, then replace patt1 with patt2 and find panels with that string,
        ; then if more than one was found, and closest set, use closest in time, otherwise
        ; use first one found.
          pattern = plotman_multi_overlay_replace(basep[i], patt1, patt2)
;          print,'after plotman_multi_overlay_replace: pattern=', pattern
          count = 0
          if pattern eq 'ABORT' then begin
            print, 'Number of ! groups in base and overlay pattern do not match. Aborting'
            goto, done
          endif
          if pattern ne 'BAD' then qrepl = plotman_multi_overlay_find(state.panel_desc, pattern, count) 
          case 1 of
            count eq 0:
            count eq 1: plist[i] = state.panel_desc[qrepl[0]]
            count gt 1: begin
              if closest then begin
                t = get_edges(self -> get_panel_times(qrepl), /mean)
                qn = where_near(t, baset[i])
                plist[i] = state.panel_desc[qrepl[qn]]
              endif else plist[i] = state.panel_desc[qrepl[0]]
              end
          endcase
;        endif
      endelse           
    endfor
    
    done:
    state.plist[iover+1,*] = plist   ; add one because 0th overlay reserved for self
    widget_control, state.w_ov[iover], set_value=plist
    sel = widget_info(state.w_list0, /list_select)
    if sel[0] ne -1 then widget_control, state.w_ov[iover], set_list_select=sel   
    end
    
  'list': begin
    sel = widget_info(state.w_list0, /list_select)
    if sel[0] ne -1 then for i=0,state.nover-1 do widget_control, state.w_ov[i], set_list_select=sel    
    end               
   
  'remove': begin
    iover = (where (state.w_remove  eq event.id))[0]
    sel = widget_info(state.w_ov[iover], /list_select)
    if sel[0] ne -1 then begin
      plist = state.plist[iover+1,*]
      plist[sel] = ''
      state.plist[iover+1,*] = plist
      widget_control, state.w_ov[iover], set_value=plist
    endif
    end
    
  'remove_widg': begin
    iover = (where (state.w_remove_widg  eq event.id))[0]
    state.plist[iover+1,*] = ''
    state.nover = state.nover - 1
    self -> multi_overlay_lists, state
    end
    
  'plot': begin
    sel = widget_info(state.w_list0, /list_select)
    if sel[0] ne -1 then begin
      for ip=0,n_elements(sel)-1 do begin
        span = self.panels->get_item(state.p_sel[sel[ip]])
        (*span).plot_control.overlay_panel = state.plist[*,sel[ip]]
      endfor
      self->show_panel, panel_number=state.p_sel[sel]
    endif else message,'No panels selected for plotting.',/info
    end

  'help': begin
    xdisplayfile, dummy, text=state.help_text, done_button='Close', group=state.w_base, /grow_to_screen, $
      width=95, title='PLOTMAN Multi Overlay Widget Help', return_id=x_id
    widget_control, x_id, xoffset=100
    end
  
  'examples': begin
    file = concat_dir(local_name('$SSW/gen/idl/plotman/doc'), 'plotman_multi_overlay_examples.txt')
    xdisplayfile, file, done_button='Close', group=state.w_base, /grow_to_screen, $
      width=90, title='PLOTMAN Multi Overlay Search Examples', return_id=x_id
    widget_control, x_id, xoffset=300
    end
  
  'addlist': begin
    state.nover = state.nover + 1
    self -> multi_overlay_lists, state
    end
    
  'cancel': begin
    for i=0,n_elements(state.p_sel)-1 do begin
      span = self.panels -> get_item(state.p_sel[i])
      (*span).plot_control.overlay_panel = state.orig_overlay[*,i]
    endfor
    goto, exit
    end
  
	'accept': begin
	  for i=0,n_elements(state.p_sel)-1 do begin
      span = self.panels -> get_item(state.p_sel[i])
      (*span).plot_control.overlay_panel = state.plist[*,i]
    endfor
    goto, exit
    end

	else: 

	endcase

if xalive(event.top) then widget_control, event.top, set_uvalue=state
return

exit:
widget_control, event.top, /destroy

end

;-----

pro plotman::multi_overlay_lists, state

if xalive(state.w_ov_base) then widget_control, state.w_ov_base, /destroy

state.w_ov_base = widget_base(state.w_lists, /row, /scroll, ypad=0)  

widget_control, state.w_ov_base, update=0
for i = 0,state.nover-1 do begin 
  state.w_ovb[i] = widget_base(state.w_ov_base, /column, /frame, ypad=1, space=0)
  tmp = widget_label (state.w_ovb[i], value='Overlay #'+trim(i+1) + ' panels:', /align_left)
  state.w_ov[i] = widget_list (state.w_ovb[i], $
    /multiple, $
    ysize=state.ysize, $
    xsize=state.xsize, $   
    value=state.plist[i+1,*], $
;    value=state.panel_desc[state.p_sel], $
    uvalue='')
;  widget_control, state.w_ov[i], set_value=state.plist[i+1,*]
  
  state.w_ov_patt1[i] = cw_field (state.w_ovb[i], $
          /string, $
          title='Base Pattern: ', $
          value=strpad(' '), xsize=20, uvalue='base_pattern' )
          
  state.w_ov_patt2[i] = cw_field (state.w_ovb[i], $
          /string, $
          title='Overlay Pattern: ', $
          value=strpad(' '), xsize=20, uvalue='over_pattern' )

  w_but_base = widget_base (state.w_ovb[i], /row)
  w_but = widget_base (w_but_base, /nonexclusive, /column, space=0)
  state.w_closest[i] = widget_button (w_but, value='Closest Time', uvalue='closest')  
  state.w_find[i] = widget_button (w_but_base, value='Find Panels', uvalue='find')
  w_but_base2 = widget_base (state.w_ovb[i], /row)
  state.w_remove[i] = widget_button (w_but_base2, value='Remove Selected', uvalue='remove', /align_left)
  if (i gt 0 and i eq state.nover-1) then $
    state.w_remove_widg[i] = widget_button (w_but_base2, value='Remove', uvalue='remove_widg')
endfor

; limit size of widget with added overlay interfaces to .4 * xsize of screen
; On unix since overlay widget base has scroll option, it doesn't size the widget by default, so have to
; explicitly set x and y size.  Also on unix doesn't report size w_ov_base would be without scroll bars 
; so use size of w_ovb and add a little (plus=10) for size of borders.  Unix is a royal pain.
; Also on unix, if have two screens, device returns x screen size for the sum of them. So for unix
; assume that width won't be more than 1.8 times height
device, get_screen_size=scrsize
if os_family() eq 'Windows' then begin
  g = widget_info(state.w_ov_base, /geometry)
  plus = 0
  xsize = g.xsize
  max_xsize = .4*scrsize[0] 
endif else begin
  g = widget_info(state.w_ovb[0], /geometry)
  plus = 10
  xsize = state.nover * (g.xsize + plus)
  max_xsize = .4*scrsize[0]  <   .4 * (1.8*scrsize[1])
endelse  
widget_control, state.w_ov_base, xsize = (xsize < max_xsize), ysize = g.ysize+plus  
widget_control, state.w_ov_base, update=1

sel = widget_info(state.w_list0, /list_select)
if sel[0] ne -1 then begin
  for i=0,state.nover-1 do widget_control, state.w_ov[i], set_list_select=sel
endif

end
;-----

pro plotman::multi_overlay, parent, p_sel

if xregistered('plotman_multi_overlay') then begin
  xmessage,'plotman_multi_overlay is already running.  Only one copy allowed.'
  return
endif

title = 'PLOTMAN Multi-Overlay Options'

if p_sel[0] eq -1 then begin
  message,'No panels selected.  Aborting.', /cont
  return
end

;panels = self -> get(/panels)
;npanels = panels -> get_count()
panel_desc = self -> get(/all_panel_desc)
npanel = n_elements(panel_desc)
nmax_overlay = self -> get(/nmax_overlay)

nsel = n_elements(p_sel)
orig_overlay = strarr(nmax_overlay, nsel)

; number of overlays to show on entry will be 1 or the highest number overlay already set in any of the selected panels
nover = 1
for i = 0,nsel-1 do begin
  panel = self.panels ->get_item(p_sel[i])
  orig_overlay[*,i] = (*panel).plot_control.overlay_panel
  q = where (orig_overlay[*,i] ne '', count)
  if count gt 0 then nover = nover > max(q)
endfor

get_font, font, big_font=big_font

widget_control, default_font = font

tlb = widget_base ( /column, $
					title=title, $
					mbar=mbar, $
					/tlb_kill, $
					group=parent, $
					space = 10 )

;w_base = widget_base (tlb, /row, space=10)

w_base = widget_base (tlb, /column, space=2, /frame)

tmp = widget_label (w_base, value='Multi-Overlay Options', font=big_font)
tmp = widget_label (w_base, value='Select overlays for multiple panels based on panel description. Click help for details. ', /align_center)

help_text = ["Overlay panels are found as follows.  Click Examples to see examples of the different search types.", $
  "", $
  "  If Base Pattern and Overlay Pattern are both blank, overlays are set to base panels.", $
  "  If Base Pattern is blank, Overlay Pattern is search pattern for overlays.  Overlays will be set in the order found.  ", $
  "    If not enough, last one found is repeated.", $
  "  If Base Pattern is set, search pattern is the base panel name with Base Pattern string replaced by Overlay Pattern string.", $
  "", $
  "  Use ! to require match in specified columns (anchored by adjacent text) and * for wildcard (don't care).", $
  "", $
  "  If more than one overlay possibility is found for a base panel:", $
  "    If Closest Time is selected, the overlay panel whose mid-time is closest to the base panel's mid-time is used.", $
  "    If Closest Time is not selected, the first overlay panel found is used.", $
  "", $
  "Plot Selected button plots the highlighted panels in the base panel list.  When base panels are highlighted,", $
  "  the corresponding overlay panels are highlighted too.", $
  "", $
  "Remove Selected button removes highlighted overlay panels from list.", $
  "Remove button removes widget for overlay n AND unsets all the overlay panels for overlay n.", $
  "", $ 
  "Note:  Set contour properties for multiple panels via Multi-Panel Options / Change Plot Options."]
for i=0,n_elements(text)-1 do tmp = widget_label (w_base, value=text[i], /align_left)

w_lists = widget_base (w_base, /row, space=5, /frame)

w_list_base = widget_base( w_lists, /column, /frame)
tmp = widget_label (w_list_base, value='Base panels:', /align_left)

xsize = os_family() eq 'Windows' ? 40 : 25
ysize = nsel + 3 < 20
w_list0= widget_list (w_list_base,  $
					/multiple, $
					ysize=ysize, $
					xsize=xsize, $
					value=panel_desc[p_sel], $
					uvalue='list')
					
tmp = widget_button (w_list_base, value='Plot Selected', uvalue='plot', /align_center)					

;w_ov_base = widget_base(w_lists, /row, /scroll)   

w_but = widget_base (w_base, /row, space=10, /align_center)
tmp = widget_button (w_but, value='Help', uvalue='help', /align_center)
tmp = widget_button (w_but, value='Examples', uvalue='examples', /align_center)
tmp = widget_button (w_but, value='Add overlay', uvalue='addlist', /align_center)
tmp = widget_button (w_but, value='Cancel', uvalue='cancel')
tmp = widget_button (w_but, value='Accept and Close', uvalue='accept')
                     
nmax = self->get(/nmax_overlay) - 1

state = {plotman_obj: self, $
  help_text: help_text, $
  orig_overlay: orig_overlay, $
  panel_desc: panel_desc, $
  p_sel: p_sel, $
  xsize: xsize, $
  ysize: ysize, $
  nover: nover, $
  w_base: w_base, $
  w_lists: w_lists, $
  w_list0: w_list0, $
  w_ov_base: 0L, $
  w_ovb: lonarr(nmax), $
  w_ov: lonarr(nmax), $
  plist: orig_overlay, $
  w_ov_patt1: lonarr(nmax), $
  w_ov_patt2: lonarr(nmax), $
  w_closest: lonarr(nmax), $
  w_find: lonarr(nmax), $ 
  w_remove: lonarr(nmax), $
  w_remove_widg: lonarr(nmax) }
  
self -> multi_overlay_lists, state
  
widget_control, tlb, set_uvalue=state

if xalive(parent) then begin
	widget_offset, parent, xoffset, yoffset, newbase=tlb
	widget_control, tlb, xoffset=xoffset, yoffset=yoffset
endif

widget_control, tlb, /realize

xmanager, 'plotman_multi_overlay', tlb

end


