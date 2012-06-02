pro pha_menus,edges,col
;**********************************************************************
; Program displays the pha display choice options for the given
; pha bin edges. Variables are:
;          edges................array of bin edges
;           col................subwidget
;********************************************************************** num_bins = n_elements(edges) - 1
edges_str = strarr(num_bins + 1)
edges_str = string(edges)
lpha = edges_str(0:num_bins - 1)
upha = edges_str(1:num_bins)
labels = strarr(num_bins + 4)
labels(0) = '"PHA"{' 
for i = 0,num_bins - 1 do begin
 labels(i+1) = '"' + lpha(i) + ' TO ' + upha(i) + '"'
 labels(i+1) = strcompress(labels(i+1))
endfor 
labels(num_bins+1:num_bins+3) = ['"ALL"','"TOTAL"}']
xpdmenu,labels,col
;*********************************************************************
; Thats all ffolks
;*********************************************************************
return
end

