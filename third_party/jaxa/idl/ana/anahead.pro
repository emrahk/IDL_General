FUNCTION anahead, filename

;returns just the header from a Rice compressed f0 file.

OPENR,unit,filename,/GET_LUN
rf = ASSOC(unit,BYTARR(256))

h = BYTARR(256)
h = rf(1)

FREE_LUN,unit
RETURN,STRING(h)
END
