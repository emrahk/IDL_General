;+
; Project     : VSO
;
; Name        : RPC_DIR
;
; Purpose     : Create and return RPC directory for writing temporary
; files
;
; Category    : utility system sockets 
;
; Syntax      : IDL> rdir=rpc_dir()
;
; Inputs      : None
;
; Outputs     : RDIR = name of temporary directory
;
; Keywords    : None
;
; History     : 30-Oct-2015, Zarro (ADNET) - Written
;
; Contact:    : dzarro@stanford.edu
;-

function rpc_dir

tdir=concat_dir(get_temp_dir(),'rpc')
if ~file_test(tdir,/dir) then file_mkdir,tdir
return,tdir

end

