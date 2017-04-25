function decompress_8to12,data
;+
; NAME:
; decompress_8to12
; PURPOSE:
;   Restore HXT and WBS data from the 8-bit telemetry format to 
; the full 12 bits
; HISTORY:
; Written by Jim McTiernan and Hugh Hudson, 19-Dec-1991
; Renamed from hxt_decomp and put in ssw gen, Kim Tolbert 12-Oct-2010
;-

lookup = intarr(256)               ; lookup table
lookup(0:15) = findgen(16)

dn = findgen(240) + 16
lookup(16:255) = fix(dn^2/16. + 0.5)

return, lookup(data)
end