; panels_selected - panel numbers to get profiles for
; p1 - start x,y location of line to use for profiles.  If not defined, uses start 
;  location from last time in profiles.  If that's not defined either, use lower left corner of plot.
; p2 - end x,y location of line to use. Similar to p1.
; outfile - name of output .sav file to save profile structure in
; prof_arr - output array of structures containing profile information


pro plotman::multi_profile, panels_selected, p1=p1, p2=p2, outfile=outfile, prof_arr=prof_arr, show=show

common profiles2_common, xstart, ystart, xdata, ydata

if exist(xstart) then begin
  default, p1, [xstart,ystart]
  default, p2, [xdata,ydata]
endif

;print, 'Line for profiles: Start x,y = ' + arr2str(trim(p1)) + '  End x,y = ' + arr2str(trim(p2))
print,' '

psel = panels_selected
count = n_elements(psel)
if psel[0] eq -1 then begin
  message,'No panels selected. Aborting.', /cont
  return
endif

panel_plot_types = self -> get(/all_panel_plot_type)
q = where (panel_plot_types[panels_selected] eq 'image', count, compl=compl, ncompl=ncompl)
psel = count gt 0 ? panels_selected[q] : -1
if ncompl gt 0 then message,trim(ncompl) + ' panels rejected - not image(s).', /cont

first = 1

if psel[0] ne -1 then begin

  current_panel_number = self -> get(/current_panel_number)
  panels = self -> get(/panels)

  for ii = 0, count-1 do begin
    p = panels -> get_item(psel[ii])

    self -> focus_panel, *p, psel[ii]

    image_info = self -> get(/image_info)
    
    ; xvals, yvals are bottom,left edges of pixels. add element for top,right of last pixel.
    xaxis = image_info.xvals
    xaxis = [xaxis, last_item(xaxis)+ (xaxis[1]-xaxis[0])]
    yaxis = image_info.yvals
    yaxis = [yaxis, last_item(yaxis)+ (yaxis[1]-yaxis[0])]
    if first then begin
      xmmsave = minmax(xaxis)  &  ymmsave = minmax(yaxis)
    endif

    image = self -> get(/saved_data_data)

    if total(image) ne 0 and same_data(minmax(xaxis),xmmsave) and same_data(minmax(yaxis),ymmsave)then begin
      profile = get_image_profile (p1=p1, p2=p2, xaxis=xaxis, yaxis=yaxis, image=image, verbose=first)
      
      profile = add_tag(profile, (*p).description, 'panel')
      
      if keyword_set(show) then begin
        window,/free
        plot,profile.dist,profile.profile,title=profile.panel
      endif
  
      if first then begin
        prof_arr = profile
        ; put actual values used back in common
        xstart = p1[0] & ystart = p1[1] & xdata  = p2[0] & ydata = p2[1]        
        first = 0        
      endif else begin
        ;if not first profile, dimensions must match first, or we reject it
        if n_elements(profile.profile) eq n_elements(prof_arr[0].profile) then begin
          prof_arr = append_arr(prof_arr, profile)
        endif else begin
          message,'Panel ' + trim(psel[ii]) + ' rejected - not the same size as first image profile in list.', /cont
        endelse
      endelse
      
    endif else print,'Panel ' + trim(psel[ii]) + ' rejected because image is all zero or has a different FOV from first image.'
  endfor
  
  self->focus_panel, dummy, current_panel_number  ; restore focus to user's current panel
  
  if first then begin
    message,'No good panels selected.  Aborting.', /cont
  endif else begin 
    if keyword_set(outfile) then begin
      line_start = p1  &  line_end = p2
      save, file=outfile, prof_arr, line_start, line_end
      np = n_elements(prof_arr)
      message, 'Profiles for ' + trim(np) + ' images stored in IDL save file ' + outfile, /cont
    endif
  endelse
  
endif else message,'No image panels selected for profiles. Aborting.', /cont

return
end




