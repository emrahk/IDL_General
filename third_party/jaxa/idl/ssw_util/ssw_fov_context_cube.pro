function ssw_fov_context_cube, index, data, _extra=_extra, $
   fdindex_in=fdindex_in, fddata_in=fddata_in

nim=data_chk(data,/nimage)

first=ssw_fov_context(index(0),data(*,*,0), _extra=_extra)

case nim of
    0: begin
          box_message,'No input images'
          return,-1
    endcase
    1: retval=first
    else: begin
          retval=make_array(data_chk(first,/nx),data_chk(first,/ny),nim,$
                    type=data_chk(first,/type))
          retval(0,0,0)=first
          for i=1,nim-1 do begin 
             delvarx,first,temp
             temp=ssw_fov_context(index(i),data(*,*,i), _extra=_extra)
             retval(0,0,i)=temp
          endfor  
    endcase
endcase

return, retval

end


