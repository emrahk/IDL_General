PRO dip_bisect, x, y, pivotx, pivoty, bisectors, fitval=fitval
;+
; NAME:     dip_bisect
;
;
;
; PURPOSE: create a number of bisectors in a given dip structure within
;          data set. The bisectors are defined by its start/stop value
;          and their heigh (units of x,y)
;
;
;
; CATEGORY: RX J1940.1-1025
;
;
;
; CALLING SEQUENCE: dip_bisect, x, y, pivotx, pivoty, bisectors
;
;
;
; INPUTS:        x - array containing the x values of the data set
;                    (usually time)
;                y - array containing the y values of the data set
;                    (usually rate)
;                pivotx - start value of x where to look bisectors for
;                         (going left/right in x-direction)
;                pivoty - start value of y where to look bisectors for
;                         (should be defined to define where we are
;                         within the dip structure)
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;                bisectors - 3*N dimensional array containing the
;                            bisectors found. First column contains
;                            the x start value, second column the x
;                            stop value, third column the bisector y value
;
;
;
; OPTIONAL OUTPUTS:
;                fitval    - result of line fit through intersecting
;                            data points crossing bottom line
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-


    ;; number of maximal line crossing till dip bottom is defined:
    traverse_limit = 3

    ;; resulting bisector list:
    ;; n - number of entries
    n = 0

    ;; allocate bisector list with worst case size (possibly too large. but
    ;; storage resource doesn't matter ;=):
    bisectors = dblarr(3,n_elements(x)*2)

    ;; 1.) finding left x data point

    ;; closest x - datapoint:
    dummy = min((x-pivotx)^2,xmin_index)

    ;; all datapoints before xmin and above y, topmost is desired left point
    leftx_index=(where((x lt x[xmin_index]) and (y gt pivoty)))[0]

    ;; no data points found -> exit
    IF leftx_index EQ  -1 THEN return 

    ;; left x point index, increasing:
    lx_index = leftx_index

    ;; last right datapoint, here one below rightmost one
    lastright2 = n_elements(x)-2

    ;; loop through all leftpoints till bottom
    WHILE  min(y) NE y[lx_index] AND lastright2 GT lx_index DO BEGIN 


        ;; define the  bisector start parameter:
        bisect_x1 =x[lx_index]
        bisect_y  =y[lx_index]
        
        ;; 2.) finding right x data point
        ;;     Go from left data point to right till intersecting with line of
        ;;     two datapoints -> closest datapoints on right from which one is
        ;;     above, the other below the y value
        
        ;; a.) Datapoint above bisector y value and right from startpoint:
        ind1 = where(y ge bisect_y and x gt pivotx)

        ;; none found -> try next one:
        IF ind1[0] EQ -1 THEN BEGIN 
            lx_index = lx_index + 1
            CONTINUE 
        ENDIF 
        
        ;; look for closest one:
        right1 = ind1[0]
        
        ;; b.) Datapoint below bisector y value: (must be below or equal y on
        ;;     right side but before the former data point, otherwise there is
        ;;     no real trough)
        ind2 = where(y lt bisect_y and x lt x[right1])

        ;; none found -> try next one:
        IF ind2[0] EQ -1 THEN BEGIN 
            lx_index = lx_index + 1
            CONTINUE 
        ENDIF 

        ;; find rightmost matching x:
        right2 = max(ind2)



        ;; c.) Find intersection x of right1/right2 (via line equation)
        bisect_x2 = x[right1] + $
          (x[right1] - x[right2]) / (y[right1] - y[right2]) * (bisect_y - y[right1])
        
        
        ;; 3.) make shure we are not at bottom of the dip
        ;;     This is done by computing the numbers of intersections with
        ;;     data point connection lines which must not exceed an upper limit
        traversing_points = 0
        
        ;; check all datapoints from left to last (lower) right:
        FOR  i = lx_index, lastright2 DO BEGIN 
            
            ;; if current point below bisector y and next above -> line crossed:
            IF  y[i] lt y[lx_index] and y[i+1] gt y[lx_index] THEN $
              traversing_points = traversing_points+1
        ENDFOR 

        ;; bottom reached -> finish
        IF traversing_points gt traverse_limit THEN BREAK 

        
        lastright2=right2 
        
        ;; 4.) store bisector:
        bisectors[0,n] = bisect_x1
        bisectors[1,n] = bisect_x2
        bisectors[2,n] = bisect_y
        
        
        ;; next entry
        n = n+1

        ;; 5.) next data point for bisector test:
        lx_index = lx_index+1

    ENDWHILE 

    ;; 6.) restrict result to actual one:
    bisectors = bisectors[*,0:n-1]

    ;; 7.) Fit bottom:
    ;; a.) restrict range:
    IF lastright2 EQ lx_index THEN lastright2 = lx_index+1 ; for safety

    ind = indgen(abs(lastright2 - lx_index)) + lx_index - 1

    ;; b.) fit:
    bottomfitval=poly_fit(x[ind], y[ind],0,chisq=chisq, yfit=yfit)


    ;; 8.) Fit bisector mean values:    
    linfitval = linfit((bisectors[0,*]+bisectors[1,*])/2.D0, bisectors[2,*],/double)

    b = linfitval[0] ;; y axis intercept
    m = linfitval[1] ;; slope
    
    ;; compute intersection bottom/fit value:
    IF m NE 0 THEN $
      fitval = (bottomfitval - b)/m $
    ELSE                     $
      fitval = (bisectors[0,0] + bisectors[1,0])/2.D0 ;; special case: vertical line

END 

