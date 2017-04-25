;+
; Name: poisson_event_bin
;
; Purpose: This function distributes integer counts into cells along
; each row based on the relative cell means
;
; Input:
;	Cell_in: a 2d n (columns) x m (rows) float array with these properties
;	The value along each row adds to an integer and the value of each
;	cell is the mean value for events in that cell. This is used for distributing
;	a known number of counts in a single bin into smaller bins as part of a rebinning
;	operation that preserves count statistics
;
;
; Keyword:
;	Seed - Seed for randomu
; Category:
;	UTIL
;
; Method: A uniform random number is generated for each photon and added to its row number. The cells
;	are then given a cumulative probability for each row to which the row numbe is added.  Using value
;	locate we find the location of each event and use histogram to bin the result. Reform sets the size
;	of the histogram vector back to the n x m long array
;
;
; History:
;	16-aug-2011, richard.schwartz@nasa.gov
;	27-Sep-2012, Kim. Use f_div to divide cell_in by ccell calculation in case a row total was 0
;-

function poisson_event_bin, cell_in, seed=seed


dim = size(/dime, cell_in)
max_sz = dim[0]
ncell = dim[1]
ccell = ftotal( cell_in, 1) ;row totals
rcell = lindgen(ncell)  ;row id
cum_row = [0,total(/cumulative, ccell)]
pcell = total(/cumulative, f_div(cell_in, transpose(reproduce(ccell,max_sz))),1)
pcell += transpose(reproduce(rcell,max_sz))
;pcell contains the cumulative prob for each row added to the row id

nphot  = round(total(ccell))
prob = randomu(seed, nphot)
padd = lindgen(nphot)
padd = value_locate(cum_row,padd)

;in the next line we add the cumulative row total to each probability
prob += padd
;Now we can find the correct cell for the given probability
ix = value_locate(pcell,prob)+1
;once we have identified the cell for each event, we use histogram to make a 2d cell histogram
;corresponding to the input event means for each cell
return, reform(histogram(ix, min=0,max=product(dim)-1),dim)
end


;test script
restore, file='dat_ran_distribute.sav'
z = reproduce( b, 10000) * 0
for i=0,9999 do z[0,0,i] =poisson_event_bin(b)
print, 'test means'
print, b
print, 'average means after 10,000 trials'
print, avg(z,2)
print, 'fractional error'
print, (b-avg(z,2))/b
end