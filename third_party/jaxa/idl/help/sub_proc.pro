;+
; Project     : HESSI
;
; Name        : SUB_PROC
;
; Purpose     : Substitute strings in a procedure (or function).
;               Useful trick to recompile a procedure to temporarily
;               behave differently from its original intention.
;               Use with care.
;
; Category    : Utility
;
; Syntax      : IDL> sub_proc,proc_name,insub,outsub
;
; Inputs      : PROC = procedure filename to mess with
;               INSUB = string text to change from
;               OUTSUB = string text to change to
;
; Outputs     : None
;
; Keywords    : VERBOSE
;
; History     : Written 20 March 2009, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sub_proc,proc,insub,outsub,verbose=verbose

verbose=keyword_set(verbose)
if is_blank(insub) or is_blank(outsub) or is_blank(proc) then begin
 pr_syntax,'sub_proc,procedure_name,input_string,replacement_string'
 return
endif

insub=strtrim(insub)
outsub=strtrim(outsub)
if insub eq outsub then return

sname=file_break(proc,/no_ext)+'.pro'
chk=have_proc(sname,out=sfile,/init)
if ~chk then begin
 message,'file not found - '+sname,/cont
 return
endif

if verbose then message,'reading from '+sfile,/cont
temp=rd_ascii(sfile)
out=str_replace(temp,insub,outsub)
out_file=get_temp_file('test.pro')
pro_dir=file_break(out_file,/path)
pro_name=file_break(out_file,/no_ext)
out=[out,' ','pro '+pro_name,'return & end']
if verbose then message,'writing to '+out_file,/cont
wrt_ascii,out,out_file,/no_pad
cd,pro_dir,curr=curr
resolve_routine,file_break(out_file,/no_ext),/either,/compile_full_file
cd,curr
file_delete,out_file,/quiet
return 
end
