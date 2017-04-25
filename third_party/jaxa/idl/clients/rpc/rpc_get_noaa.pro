;+
; Project     : SOLAR-B/EIS
;
; Name        : RPC_GET_NOAA
;
; Purpose     : RPC wrapper around GET_NAR
;
; Category    : planning
;
; Explanation : Get NOAA AR pointing info
;
; Syntax      : IDL>nar=rpc_get_nar(tstart)
;
; Inputs      : TSTART = start time
;
; Opt. Inputs : TEND = end time
;
; Outputs     : NAR = structure array with NOAA info
;
; Keywords    : see GET_NAR
;
; History     : 16-Feb-2006, Zarro (L-3Com/GSFC) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function rpc_get_noaa,tstart,tend,_extra=extra

o=obj_new('idl_rpc_client')

if exist(tstart) then s_tstart="'"+tstart+"'" else s_tstart='tstart'
if exist(tend) then s_tend="'"+tend+"'" else s_tend='tend'

nar_cmd="nar=get_nar_arr("+s_tstart+","+s_tend+")"

val=''
status=o->rpcinit(host=rpc_server())
if status then status=o->rpcexecutestr(nar_cmd)
if status then status=o->rpcgetvariable(name='nar',value=val)
if status then begin
 s=size(val)
 out={time:0l,day:0,noaa:0,x:0.,y:0.}
 if s[0] eq 2 then begin
  out=replicate(out,s[1])
  for i=0,4 do out.(i)=val[*,i]
 endif else for i=0,4 do out.(i)=val[i]
endif

obj_destroy,o
return,out

end
