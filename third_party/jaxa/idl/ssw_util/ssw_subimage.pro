pro ssw_subimage, index, data, oindex, odata, $
   pixsub=pixsub, pixcen=pixcen, xycen=xycen, xypix=xypix, $
   overwrite=overwrite, debug=debug, $
   ll=ll,lr=lr,ul=ul,ur=ur, center=center
;
;+
;   Name: ssw_subimage
;
;   Purpose: extract sub images from 'index,data'
;
;   Input Parameters:
;      index, data - input 2D or 3D 
;
;   Output Parameters:
;      oindex,odata - extracted sub image 2D or 3D, SSW tags adjusted
;
;   Keyword Parameters:
;         ll,lr,ul,ur,center  - quadrant keywords
;         pixsub - sub image in pixel space - [x,y,nx,ny] (x,y=lower left)
;         pixcen - sub image center, pixel    [x,y]       (x,y=center pixel)
;         xycen  - sub image center, arcsec   [xcen,ycen]
;         xypix  - npix [nx,ny] used with pixcen -or- xycen
;         overwrite - if set, then clobber 'index,data' (memory management)
;
;   History:
;      25-July-2001 - S.L.Freeland
;
;   Restrictions:
;      Only PIXSUB for now (assume data already aligned...)
;-

debug=keyword_set(debug)
overwrite=keyword_set(overwrite)

if n_params() lt 2 then begin 
   box_message,['IDL> ssw_subimage,index,data [,oindex,odata,/overwrite]',$
                '        PIXSUB=[x,y,nx,ny]']
   return
endif

if not required_tags(index,'xcen,ycen,naxis1,naxis2,cdelt1') then begin 
   box_message,['Require SSW standard index,data']
   return
endif

asppix=gt_tagval(index,/cdelt,missing=.5)

dx0=data_chk(data,/nx)
dy0=data_chk(data,/ny)

case 1 of 
   keyword_set(ll): pixsub=[0,0,dx0/2,dy0/2]
   keyword_set(lr): pixsub=[dx0/2,0,dx0/2,dy0/2]
   keyword_set(ul): pixsub=[0,dy0/2,dx0/2,dy0/2]
   keyword_set(ur): pixsub=[dx0/2,dy0/2,dx0/2,dy0/2]
   keyword_set(center): pixsub=[dx0/4,dy0/4,dx0/2,dy0/2]
   else:
endcase

if n_elements(pixsub) eq 2 then pixsub=[pixsub,dx0-pixsub(0),dy0-pixsub(1)]

oindex=index

case 1 of 
   n_elements(pixsub) eq 4: begin 
      odata=temporary(data(pixsub(0):pixsub(0)+pixsub(2)-1 , $
                           pixsub(1):pixsub(1)+pixsub(3)-1,*))               
      index2map,index(0),data(*,*,0),map
      if overwrite then data=temporary(odata)
;     use D.M.Zarro sub_image.pro for FOV derivations
      sub_map,map,submap,xrange=[pixsub(0),pixsub(0)+pixsub(2)],$
                         yrange=[pixsub(1),pixsub(1)+pixsub(3)],/pixel
      oindex.xcen=submap.xc
      oindex.ycen=submap.yc
      oindex.naxis1=pixsub(2)
      oindex.naxis2=pixsub(3)
      oindex=struct2ssw(oindex)                  ; update other SSW tags
      if overwrite then index=temporary(oindex)
   endcase
   else: begin 
      box_message,['Only PIXSUB option currently enabled', $
                   'IDL> ssw_subimage,index,data [,oindex,odata,/overwrite]',$
                   '        PIXSUB=[x,y,nx,ny]']
   endcase
endcase

if debug then stop
return
end
