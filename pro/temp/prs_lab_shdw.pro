prshdw=rshdw(12:71,3:62)
openw,unit,'prshdw.txt',/get_lun
FOR i = 0,59 DO BEGIN 
    printf,unit, bigmap(*,59-i), format='(91f6.3)'

END
free_lun,unit
END
