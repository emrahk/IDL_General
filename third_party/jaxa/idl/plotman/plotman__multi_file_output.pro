;+
; Name: plotman::multi_file_output
; Purpose: Plotman method for handling writing fits, save, or plot files for multiple panels.
;	User is prompted for base name of output files, then panel number is appended to each
;	file to make it unique.
;	
;	Input arguments:
;	panels_selected - array of 0s and 1s corresponding to each panel.  1 means panel was selected
;	type - string specifying output choice: 'PS', 'Multipage PS', 'PNG', 'TIFF', 'JPEG', 'writesave', 'writefits', or 'printplot'
;
; Written: Kim Tolbert, 20-Jun-2002
; Modifications:
; 21-Nov-2008, Kim. Call create_plot_file method instead of plotman_create_files_event routine
; 23-Jul-2015, Kim. Enable multi-page PS output file.
;
;-


pro plotman::multi_file_output, panels_selected, type

action = type
multipage = 0
case type of
	'writesav': ext = '.sav'
	'writefits': ext='.fits'
	'PS': begin
		action = 'plotfile'
		id = (self->get(/widgets)).psid
		ext='.ps'
		end
  'Multipage PS': begin
    action = 'plotfile'
    type = 'PS'
    id = (self->get(/widgets)).psid
    ext='.ps'
    multipage = 1
    end
	'PNG': begin
		action = 'plotfile'
		id = (self->get(/widgets)).pngid
		ext='.png'
		end
	'TIFF': begin
		action = 'plotfile'
		id = (self->get(/widgets)).tiffid
		ext='.tiff'
		end
	'JPEG': begin
		action = 'plotfile'
		id = (self->get(/widgets)).jpegid
		ext='.jpeg'
		end
	'printplot': begin
		action='plotfile'
		id=(self->get(/widgets)).printid
		ext='.ps'
		end
	else: ext=''
end

use_filename = type eq 'printplot' ? 0 : 1

selfile_msg = $
  ['  Select base name for output files', $
  '', $
  '  Panel number will be appended to base name', $
  '  to make a unique file name for each panel.']

pickfile_title = multipage ? 'Select output file name' : 'Select base name for output files'
  
q0 = where (panels_selected eq 1, count0)
delvarx, q
; make sure the selected panels are valid
if count0 gt 0 then begin
  count = 0
  panels = self -> get(/panels)
  for ii = 0, count0-1 do begin
    if ~ptr_valid(panels -> get_item(q0[ii])) then continue
    count = count + 1
    q = append_arr(q, q0[ii])
  endfor
endif else count = 0

if count gt 0 then begin
	current_panel_number = self -> get(/current_panel_number)
	panels = self -> get(/panels)
	out = ''
	if use_filename then begin
		filter = '*' + ext
		def_file = 'idl' + ext
		if ~multipage then xack, selfile_msg, title='Select base name', /suppress, space=2
		filename = dialog_pickfile (filter=filter, $
			file=def_file, $
			title = pickfile_title,  $
			group=group)
		if filename eq '' then begin
			err_msg = 'No output file selected.'
			message, err_msg, /cont
			return
		endif
		break_file, filename, disk, dir, ff, ext
		base_name = disk+dir+ff
	endif
	lastii = count-1
	for ii = 0, count-1 do begin
		p = panels -> get_item(q[ii])
		if ptr_valid(p) then begin
			self -> focus_panel, *p, q[ii]
			
			if multipage then begin
			 firstpage=ii eq 0
			 midpage=(ii gt 0) and (ii lt lastii)
			 lastpage=ii eq lastii
			endif else begin
			  if use_filename then filename = base_name + '_' + trim(q[ii],'(i3.3)') + ext
			endelse
			
			case action of
				'writesav': self -> export, /idlsave, /quiet, $
					filename=filename, msg=msg
				'writefits': self -> export, /fits, /quiet, $
					filename=filename, msg=msg
				'plotfile': self->create_plot_file, type=type, filename=filename, /quiet, msg=msg, $
				  firstpage=firstpage, midpage=midpage, lastpage=lastpage			  
			endcase
		endif else msg = 'Invalid panel'
		if ~multipage then out = [out, 'Panel ' + trim(q[ii]) + ':  ' + msg]
	endfor
	if multipage then out = 'Selected panels written into multipage PS file ' + filename
	self->focus_panel, dummy, current_panel_number
endif else out = 'No panels were selected or none of selected panels were valid.'

a = dialog_message(out, /info)

end
