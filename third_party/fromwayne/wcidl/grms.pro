function grms, iflc, ierr

flc=iflc
err=ierr

q=size(flc)
nbins=double(q(1))

;Calcluate the average rate of the FLC
i_avg = total(flc)/nbins

;Calculate the error on the average rate
e_avg = sqrt(total((err)^2.d))/nbins

;Calculate \Delta I
i_del = flc - i_avg

;Calculate the error on \Delta I
e_del = sqrt((err)^2.d + e_avg^2.d)

;Calculate <\Delta I ^2.d>
i_deli2 = total(i_del^2.0d)/nbins

;Calculate the error on <\Delta I ^2.d>
e_deli2 = sqrt(total((2.d*i_del/nbins)^2.d * e_del^2.d))

;Calculate \gamma_{osc}
g_osc = sqrt(i_deli2)/i_avg

;Calculate the error on \gamma_{osc}
e_osc = g_osc * sqrt(e_deli2^2.d/(4.d*i_deli2^2.d) + e_avg^2.d/i_avg^2.d)


;frt = sqrt(4.d/(nbins^2.d) * total(i_del^2.d * e_del^2.d))
;e_osc = sqrt(frt^2.d + e_avg^2.d)

r_val=[g_osc,e_osc]

return, r_val
end
