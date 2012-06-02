pro obox,xmin,ymin,xmax,ymax
oplot,[xmin,xmax],[ymin,ymin],line=0,/noclip
oplot,[xmax,xmax],[ymin,ymax],line=0,/noclip
oplot,[xmin,xmax],[ymax,ymax],line=0,/noclip
oplot,[xmin,xmin],[ymin,ymax],line=0,/noclip
end
