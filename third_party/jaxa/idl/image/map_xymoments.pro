;+
; PROJECT:
;	SSW
; NAME:
;	MAP_XYMOMENTS
;
; PURPOSE:
;	Computes the centroid and standard deviation
;	 along x and y (rows and columns) of a map distribution.
;
; CATEGORY:
;	Math, Util
;
; CALLING SEQUENCE:
;	map_xymoments, map, xaxis, yaxis, centroid, stdev

;
; CALLS:
;	none
;
; INPUTS:
;       Map- 2d array of map intensities
;		Xaxis - positions of pixels along first dimension of Map
;		Yaxis - positions of pixels along second dimension of Map
;		;
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       Centroid - returns 2 element array of centroid along x and y
;			in the coordinates of xaxis and yaxis
;		Stdev   - returns 2 element array of standard deviation along
;			x and y in the coordinates of xaxis and yaxis.
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	none
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	Straighforward application of the definitions of mean and standard
;		deviations of the moments of a distribution
;
; MODIFICATION HISTORY:
;	Version 1, richard.schwartz@gsfc.nasa.gov,
;	25-Jan-2008, ras and kim, centroid calculation simplified (but same calculation) and
;	  make stdev calculation more robust if there are negative values in map (which happens
;	  with RHESSI clean images)
;
;-


pro map_xymoments, map, xaxis, yaxis, centroid, stdev

umap = map
map  = map > 0.0

xcentroid =  total( total(map,2)*xaxis ) / total( map)

ycentroid =  total( total(map,1)*yaxis ) / total( map )


centroid = [xcentroid, ycentroid]

xstdev = sqrt( total( total(map,2)*(xaxis-xcentroid)^2 ) / total(map) )
ystdev = sqrt( total( total(map,1)*(yaxis-ycentroid)^2 ) / total(map) )

map = umap

;xstdev = sqrt( (total( map ## transpose(xaxis^2 )) / total( map) - xcentroid^2))
;
;ystdev = sqrt( (total( map # yaxis^2 ) / total( map) - ycentroid^2) > 0)

stdev = [xstdev, ystdev]
end