;+
; Project     : HESSI
;
; Name        : obj_save
;
; Purpose     : Saves an object.  Use with obj_restore (to handle compiling methods).
;
; Explanation : See the header documentation to obj_restore to read why
;               a simple save and restore don't always work for objects.
;
;               obj_save modifies the name of the output file to include the
;               class name of the object as the first part of the filename followed
;               by two underscores.  This will be used by obj_restore to enable
;               it to compile the methods for the class before restoring the object.
;
;               Object save files can be large.  Use of the /compress keyword is recommended.
;
; Restrictions: WARNING!!! The restored object will not be usable if the object
;               structure definitions have changed.  This is for short-term saving
;               of objects only.
;
; Category    : utility objects
;
; Syntax      : IDL> obj_save, object
;
; Inputs:     : object - object to save
;
; Outputs     : object - restored object
;
; Input Keywords:
;               file - file name to save into.  Default is 'class_name'__obj.geny
;                 e.g. hsi_spectrum__obj.geny
;               no_dialog - If set, and no filename is supplied, just use default name.
;                 Otherwise, pop up dialog for file name.
;               overwrite - If set, overwrite an existing file.  If not set, and file
;                 exists, and no_dialog is not set, ask user whether to overwrite existing file.
;               _extra - keywords to pass on to savegenx, like compress
; Output Keywords:
;               err_msg - error string if any, otherwise blank string
;
; Restrictions: Use in conjunction with obj_restore (otherwise methods might not be
;               available)
;
; History     : Written 4-Mar-2003, Kim Tolbert
; Modifications:
;  11-Oct-2005, Kim.  Added warning in header doc
;
;-


pro obj_save, object_save, file=file, no_dialog=no_dialog, overwrite=overwrite, _extra=_extra, err_msg=err_msg

err_msg = ''

if size(object_save, /tname) ne 'OBJREF' then begin
	err_msg = 'Error: calling syntax is obj_save, object [, file=file, no_dialog=no_dialog, ... ]'
	message, err_msg, /cont
	return
endif

class = strlowcase(obj_class(object_save))

if not keyword_set(file) then begin
	file = class + '__obj'
	if not keyword_set(no_dialog) then begin
		file = dialog_pickfile (path=curdir(),  $
			file=file, $
			title = 'Select file to save object in')
		if file eq '' then return
	endif
endif

dir = file_break(file,/path)
if strlowcase( (ssw_strsplit(file_break(file,/name), '__', /head))[0]) ne class then $
	file = concat_dir(dir, class + '__' + file_break (file, /name))

; savegenx doesn't return any information to caller about success (but does print
; msg in output log), so do some checks here so we can return errors in err_msg

if dir eq '' then dir = curdir()
if not write_dir(dir) then begin
	err_msg = 'Can not write in selected directory.'
	message, err_msg, /cont
	return
endif

; savegenx is going to add .geny if filename doesn't already have it.
if file_break(file,/ext) ne '.geny' then file = file + '.geny'

; file_test function doesn't exist in IDL < 5.4
if since_version('5.4') then begin
	if call_function('file_test',file) then begin
		if not keyword_set(overwrite) then begin
			if not keyword_set(no_dialog) then begin
				ans = dialog_message(/question, 'Do you want to overwrite the existing file?')
				if ans eq 'Yes' then overwrite = 1
			endif
			if not keyword_set(overwrite) then begin
				err_msg = 'File exists and you did not select to overwrite.'
				message, err_msg, /cont
				return
			endif
		endif
	endif
endif

savegenx, object_save, file=file, overwrite=overwrite, _extra=_extra
message,'Object saved in file ' + file, /cont

end

