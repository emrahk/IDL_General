;+
;Project:
;       SOHO - SUMER
;Name:
;       mk_sumer_map
;Purpose:
;       Make an image map from SUMER data structure
;Explanation
;       This program is analigous to mk_cds_map. The default output is
;	a structure containing a single 2-D map and other information
;	suitable of entering in certain CDS image manipulation programs
;Catagory:
;       Imaging
;Use:
;       map= mk_sumer_map(index,data,col)
;Inputs
;       index - The index structure returned from rd_sumer.
;       data - data structrure from rd_sumer
;       col - column to use in making map. If not specified, the user will
;	be prompted.
;Output
;       Map = {data:data,xp:xp,yp:yp,id:id,time:time,soho:soho,rot:rot_num}
;               where
;               DATA  = 2d image array
;               XP,YP = 2d cartesian coordinate arrays
;               ID    = Wavelength and BTE  of map (from data tagname)
;               TIME  = start time of image
;               SOHO  = 1, flag identifying that image is SOHO-viewed
;		ROT_NUM = Direction input used for ROTATE function
;               or, if the keyword IMAGE_ONLY is used, return only the 2d map
;      
;Input Keywords:
;              Peak - make map at wavelength of peak intesity. The default is to 
;		sum over the wavelength range
;              WPRange - the range in pixels in the wavelength direction to use. 
;		Default is the entire range.
;              Image_Only - return a 2d image rather than the default, a strucuture
;	       plot_image - Return an altrnate data structure with PLOT_IMAGE
;			inputs:
;              Map = {data:data,origin:origin,scale:scale,id:id,time:time,$
;			soho:soho,rot:rot_num}
;               where
;               DATA  = 2d image array
;		ORIGIN = coordinates of bottom Left corner of map
;		SCALE = scale of map in the X and Y directions
;               ID    = Wavelength and BTE  of map (from data tagname)
;               TIME  = start time of image
;               SOHO  = 1, flag identifying that image is SOHO-viewed 
;		ROT_NUM = Direction input used for ROTATE function
;
;Calls:
;              DATATYPE,  GET_SUM_COLUMN, SGT_DIMS,  SGT_SOLAR_X, SGT_DET_Y,
;              ANYTIM2CAL
;Common:
;       None
;Written:
;       Terry Kucera,  Oct 23, 1996.
;Modifications:
;       "Time" tag now correct for sumer data with more than one raster.
;				 Dominic Zarro, May 15, 1997
;	"PLOT_IMAGE" keyword added. TAK Oct 6, 1997	
;       Added conversion to new map format - Zarro (SM&A), 29-Dec-98
;       Used boolean instead of string to determine rotation
;       - Zarro (L-3Com/GSFC), 28-May-05
;Contact:
;        tkucera@solar.stanford.edu
;-
 function mk_sumer_map,index,data,col,peak=peak,WPrange=WPRange,$
	Image_Only=Image_Only,Plot_Image=Plot_Image

false = 0b   & true = 1b

if (datatype(index) ne 'STC' ) or (datatype(data) ne 'STC') then begin
  message,'index and data must be sumer data structures',/cont
   return,0
endif

			;select the column if it isn't given
if n_elements(col) ne 1 then col = get_sum_column(index)

dims = (sgt_dims(index))(*,col)
if n_elements(WPRange) eq 2 then begin
     if WPRange(1) ge dims(0) then message,$
         'the wavelength pixel range is between 0 and '+strtrim(dims(0),2)+$
         ' Please select a new WPRange.'
endif else WPRange = [0,dims(0)-1]

			;peak - make map at wavelenght with peak flux
if keyword_set(peak) then begin  
    tmp=max(total(total(data.(col)(WPRange(0):WPRange(1),*,*),2),2),maxw)
    map = reform(data.(col)(WPRange(0)+maxw,*,*))
			;default - total along wavelength dimension
endif else  map = total(data.(col)(WPRange(0):WPRange(1),*,*),1)


;reorient map correctly.
solarx = (sgt_solar_x(index))(*,col)
solary = (sgt_det_y(index))(*,0,col)

if n_elements(solarx) eq 1 then solarx=[solarx,solarx]
if n_elements(solary) eq 1 then solary=[solary,solary]

if solarx(0) lt solarx(1) then Xflip = 0b else xflip = 1b
if solary(0) lt solary(1) then Yflip = 0b else Yflip = 1b
case 1 of
     (1-XFlip) and (1-YFlip):  rot_num=4
     (1-XFlip) and YFlip:      rot_num=3
     XFlip and (1-YFlip):      rot_num=1
     XFlip and YFlip:          rot_num=6
endcase

map=rotate(map,rot_num)

if YFlip then solary = rotate(solary,2)
if XFlip then solarx = rotate(solarx,2)

;perhaps use solar_x and solar_y to calculate xp and yp


if keyword_set(Image_Only) then return,map

dettime=min(sgt_dettime(index.(col)))
time = anytim2utc(anytim2tai(index.gen.date_obs)+dettime,/vms)

id = (tag_names(index))(col)

if keyword_set(plot_image) then begin
      origin=[solarx(0),solary(0)]
      scale=[solarx(1)-solarx(0),solary(1)-solary(0)]
      map={data:map,$
	origin:origin, scale:scale,$
        time:time,  id:id,  soho:1, rot:rot_num}
endif else begin
stop,1
      map={data:map, $
          xp: solarx#replicate(1,dims(1)), $
          yp:replicate(1,dims(2))#solary, $
          time:time,  id:id,  soho:1, rot: rot_num}
      map=mk_map_new(map)
endelse
return,map

end


