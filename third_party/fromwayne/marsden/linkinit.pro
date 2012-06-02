pro linkinit
;***********************************************************************
; Program initiates the linkup to the c socket
;***********************************************************************
x = call_external('/disk1/home/hexdev/gselink.so','linkinit')
print,'LINKINIT RETURNED ',x
end
