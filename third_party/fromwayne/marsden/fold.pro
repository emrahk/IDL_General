pro fold,counts,period,t_res,phase_arr,counts_fold,phz_bns
;*********************************************************************
; Program folds a time ordered counts array on a given period. For 
; simplicity the counts are assumed to occur as a delta function
; in the center of the counts bins.
; Variables are:
;         counts...............time ordered counts array
;        counts_...............  "     "      "      "   renor'med
;         period...............period in seconds to fold on
;          t_res...............time resolution of the counts
;         t_res_...............  "       "      "  "  folding grid
;  ledgs0,uedgs0...............upper/lower time edges of counts array
;      cnts_edgs...............cnts edges at center of bins
;        big_arr...............array of phase binned counts
;    counts_fold...............counts array folded
;        phz_bns...............number of phase bins
;          delta...............width of phase bins
;      phase_arr...............phase array to plot (x)
; 5/30/94 Error routine added if period too long for the #
;         of phase bins requested.
; 8/26/94 Annoying print statements removed
; First get some variables:
;*********************************************************************
counts_fold = lonarr(phz_bns)
phase_arr = findgen(phz_bns)/float(phz_bns)
delta = period/float(phz_bns)
len = n_elements(counts)
len_ = fix(float(len)*t_res/delta)
ledgs0 = findgen(len_+1)*delta
uedgs0 = ledgs0 + delta
big_arr = lonarr(len_+1)
cnts_edgs = findgen(len)*t_res + .5*t_res
;********************************************************************
; If period is too long for the number of phase bins
; then print error message and return empty array
;********************************************************************
if (len_ eq 0) then begin
   print,'!PERIOD TOO LONG FOR # OF PHASE BINS!'
   return
endif
;********************************************************************
; Cycle through the time bins and deposit counts into big_arr
;********************************************************************
for i = 0,len-1 do begin
 edge = cnts_edgs(i)
 ndx = where(edge ge ledgs0 and edge lt uedgs0)
 if (ndx(0) ne -1)then big_arr(ndx(0)) = big_arr(ndx(0)) + counts(i)
endfor
;********************************************************************
; Total counts in the same phase bins
;********************************************************************
arr = findgen(len_) + 1
for i = 0,phz_bns - 1 do begin
 ndx = where(arr mod phz_bns eq i)
 if (ndx(0) ne -1)then counts_fold(i) = total(big_arr(ndx))
endfor
;********************************************************************
; Thats all ffolks
;********************************************************************
return
end
