pro quality_filter, index, data, gcnt
;
;+
;   Name: quality_filter
;
;   Purpose: filter data with some qualitative checks
;
;   Restrictions:
;      functional place holder
;
;   History:
;      12-sep-1998 - S.L.Freeland - online but under construction
;                    (called by 'special_movie.pro')
;
;   Side Effects:
;     may change index & data (filter out 'bad' data)  
;-
nf=n_elements(index)
message,/info,"Applying data quality filter to " + strtrim(nf,2) + " images"
dq=data_quality(data)
qcut=.6*(max(dq))
okdq=where(dq ge qcut,gcnt)
bdq=where(dq lt qcut,bcnt)

case 1 of
   (size(data))(1) ge 512: message,/info,"Ignoring filter for large image"
   bcnt eq 0: message,/info,"All images ok..."
   gcnt eq 0: message,/info,"No images ok (cant happen...)"
   else: begin
      prstr,strjustify(["Number of bad  images: "+strtrim(bcnt,2), $     
                        "Number of good images: "+strtrim(gcnt,2)],/box)
                                             
      data=temporary(data(*,*,okdq))      
      index=index(okdq)
  endcase
endcase

return
end
