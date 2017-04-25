;+
; PROJECT:
;       SDAC
; Name:
;	MAP_MATRIX
; Purpose:
;	This procedure creates a linear transformation matrix between two data binnings.
;
; Procedure:
; This procedure creates a linear transformation matrix which can be used
; to rebin vector data such as count rates defined on a PHA scale.
; It takes a matrix with n output bins defined on energy edges EDGE1, (n+1)
; and create a transform, MAP, to interpolate a detector response, MATRIX1, from
; narrow channels to broader output channels defined by EDGE2.  The matrix
; is defined in terms of counts/channel unless the keyword FLUX is set.
; This operation is sometimes called flux rebinning.  Matrix2 is generally
; a matrix with mostly zeroes and can be easily represented with a sparse matrix
; if the matrix is square. 
;	for a bin defined on EDGE1 which falls wholly within a bin on EDGE2
; 	the map matrix element is 1
; 	for a bin defined on EDGE1 which falls partially within a bin on EDGE2
; 	the map matrix element is given by the fraction of BIN1 contained by BIN2

; 
; Category:
;	GEN, SPECTRUM, UTILITY, 
; Calling Sequence:
;	MAP_MATRIX, Edge1, Matrix1, Edge2, Map, Matrix2
;
;
; Inputs:
;	Edge1: N+1 energy edges of N output bins or 2xN energy edges
;	Matrix1: Response matrix N output bins, M input bins
;		Output rows in Counts/bin  (NOT Counts/keV)
;	Edge2: K+1 output energy edges for new matrix, or 2xK edges
;	
; Outputs:
;	Map: The linear transform from input response, MATRIX1, to output MATRIX2
;	     i.e. matrix2 =  map # matrix1
; 	Matrix2: New response matrix with K output bins, M input bins
;		Rows in Counts/bin
; Keywords:
;	FLUX- Map operates on vectors in flux units, i.e. scaled by the
;	width of the channels.
; Restrictions: 
;	This is not an optimized procedure
;
;
; History:
; 	Version 1, RAS, 9 Aug 93
;	Version 2, RAS, 24-apr-1996, allowed 2xN energy edges
;	Version 3, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;-

pro map_matrix, edge1, matrix1, edge2, map, matrix2, flux=flux

in_edge1=edge1
in_edge2=edge2


edge_products, edge1, edges_2=edge1, width=we1
edge_products, edge2, edges_2=edge2, width=we2

n1=n_elements(edge1(0,*))  ;output bins in matrix1, energy edges, 
n2=n_elements(edge2(0,*))  ;output bins in new matrix2

map = fltarr(n2,n1)

;fill the column with the fraction from the edge2 bins that falls into
;this edge1(*,i) bin.

for i=0,n2-1 do begin
	test = ( (edge1(0,*) ge edge2(1,i)) or (edge1(1,*) le edge2(0,i)) )
	map(i,*) = 1-test
        wz  = where( test eq 0, nz) ;those channels which fall in this range
	if nz eq 1 then $
	  map(i,wz(0))= f_div( we2(i), we1(wz(0))) $
	  else if nz gt 1 then begin
		i1  = wz(0)   ;first channel in range
		i2  = wz(nz-1)	;last channel in range
		map(i,i1) = f_div( edge1(1,i1) - edge2(0,i), we1(i1))
		map(i,i2) = 1.0 - f_div(edge1(1,i2) - edge2(1,i), we1(i2))
	  endif
endfor
if keyword_set(flux) then $
	map = map * f_div(rebin(reform( we1,1,n1),n2,n1), rebin(reform(we2,n2,1),n2,n1)) 
if (size(matrix1))(1) eq (size(map))(2) then  matrix2 =  map # matrix1 else matrix2=0

edge1=in_edge1
edge2=in_edge2

end
