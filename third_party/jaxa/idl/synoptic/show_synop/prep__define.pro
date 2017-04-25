
;-- Stubs for instrument objects to inherit
;-- 17-Nov-2009, Zarro (ADNET), written.


function prep::init,_ref_extra=extra

dprint,'Initializing Prep...'

return,1
end

;-------------------------------------------------------------
function prep::have_cal,_ref_extra=extra

return,1b

end

;-------------------------------------------------------------------
function prep::have_path,_ref_extra=extra

return,1b

end

;-------------------------------------------------------------------
function prep::is_valid,file,_ref_extra=extra

return,1b

end

;-------------------------------------------------------------------
;-- check if input file is level 0 but cannot be prepped

function prep::check_prep,file

valid=self->is_valid(file,level=level)

if level gt 0 then return,0b

have_path=self->have_path()
have_cal=self->have_cal() 

can_prep=have_path and have_cal

return,valid and (level eq 0) and ~can_prep
end

;----------------------------------------------------------------------

; Return modified extra structure in new, since don't know how to modify extra.

pro prep::get_prep_opts, prep_widg=prep_widg, _extra=extra, new=new

if keyword_set(prep_widg) then begin
  if have_method(self,'prep_widget') then begin
    self->prep_widget
    opts = self->get_prep()
    ; if extra is structure, join with opts, but opts values take priority
    new = is_struct(extra) ? join_struct(opts,extra) : opts
    return
  endif
end

if is_struct(extra) then new = extra
return
end

;----------------------------------------------------------------------

pro prep__define

void ={prep,prep_prop:0b}

end

