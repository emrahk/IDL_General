;+
; Project     : HESSI
;
; Name        : obj_restore
;
; Purpose     : Restores an object and compiles its methods
;
; Explanation : Use with obj_save.
;               The reason not to simply use save and restore with objects:
;               If an object is restored before its methods are compiled,
;               then it doesn't have access to many of its methods.  This is because
;               usually the methods are in the __define.pro file, which is
;               usually compiled on object creation, but not on restoring an object.
;               At this point, even creating a new object of that class won't compile
;               the methods, since IDL thinks they're already there.
;               So we must compile all
;               the methods explicitly before restoring the object.
;               Normally, given the class name, this could be done using
;               the routine obj_compile.  However that only finds classes that
;               are inherited by the class.  In some cases (e.g. HESSI) the
;               objects don't inherit a class, but include an object of a
;               different class as a property.  So to cover this case, we
;               create a temporary object of the requested class, and then
;               destroy it.  This will compile all the methods in the __define.pros.
;               (However, even this won't work for property objects
;               that are not instantiated in the init of the original object.
;               I don't have a solution for that case.)
;
;               obj_save will write the class name of the object in the save
;               file as the first part of the filename followed
;               by two underscores.  Otherwise we wouldn't know the class until
;               after we restored the object, at which point it's too late to
;               attempt to compile the methods.
;
; Restrictions: WARNING!!! The restored object will not be usable if the object
;               structure definitions have changed.  This is for short-term saving
;               of objects only.
;
; Category    : utility objects
;
; Syntax      : IDL> obj_restore, object
;
; Inputs:     : None
;
; Outputs     : object - restored object
;
; Input Keywords:
;               file - file name to restore from. If not supplied, get dialog box
;               nocompile - if set, don't try to compile object methods
; Output Keywords:
;               err_msg - error string if any, otherwise blank string
;
; Restrictions: Use in conjunction with obj_save (otherwise methods might not be
;               available)
;
; History     : Written 4-Mar-2003, Kim Tolbert
; Modifications:
;  11-Oct-2005, Kim.  Added warning in header doc
;
;-

pro obj_restore, obj, file=file, nocompile=nocompile, err_msg=err_msg

err_msg = ''

if not keyword_set(file) then begin
	file = dialog_pickfile (path=curdir(),  $
		filter='*.geny', $
		title = 'Select file to restore object from')
endif

; I know restgenx would do these tests, but it wouldn't give any feedback to the
; calling routine.  err_msg passes the info back.

if file eq '' then begin
	err_msg = 'No file selected.'
	message, err_msg, /cont
	return
endif

; file_test function doesn't exist before IDL 5.4, so skip this test if < 5.4
if since_version('5.4') then begin
	if not call_function('file_test', file, /read, /regular ) then begin
		err_msg = 'File ' + file + ' does not exist or is not readable.'
		message, err_msg, /cont
		return
	endif
endif

; get class name from file name if available
class = (ssw_strsplit(file_break(file,/name), '__', /head))[0]

; If class name available, compile methods by creating a temporary object and deleting it.
; Must do this before restoring object, because methods won't get compiled once object exists.

if not keyword_set(nocompile) then begin
	if class eq '' then begin
		err_msg = 'No class name in file name.  Object may not have access to its methods.'
	endif else begin
		which, class + '__define', out=out, /quiet
		if out[0] eq '' then begin
			err_msg = class + '__define not found.  Object may not have access to its methods.'
		endif else begin
			temp = obj_new(class)
			obj_destroy, temp
		endelse
	endelse
endif

if err_msg ne '' then message, err_msg, /cont

restgenx, obj, file=file, /relaxed_structure_assignment

message,'Restored from file ' + file, /cont

end