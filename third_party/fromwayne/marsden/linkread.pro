function linkread
;
; 1994 June 22 P. R. Blanco, added directory path to 'gselink.so' reference
;
	x = bytarr(1000)
        y = call_external('/disk1/home/hexdev/gselink.so','linkread',x,100)
        fname = strtrim(x)
        return,fname
end
