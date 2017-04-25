pro ssw_read_xxx,files, index, data, mreadfits=mreadfits


mreadfits=keyword_set(mreadfits)
case 0 of
   mreadfits: readstr='mreadfits,files,index,data,_extra=_extra'
   else: readstr='mreadfits,files,index,data,_extra=_extra'
endcase

estat=execute(readstr)

return
end
