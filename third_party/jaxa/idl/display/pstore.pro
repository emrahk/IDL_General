;+
; Project     : SOHO - CDS     
;                   
; Name        : PSTORE()
;               
; Purpose     : Store Plot Region data (!P,!X,!Y,!D, and data X/Y size)
;               
; Explanation : Pstore is used to store information about plot regions
;		where data is displayed (plotted or TV'ed). 
;		The !P/!X/!Y/!D system variables should be set by
;		the caller by e.g. plotting with x/yrange set
;		to the correct values, with x/ystyle=1.
;
;		More than one plot region per window can be used,
;		just supply a unique NUMBER for each plot. If the
;		plot is redisplayed later, an identical call to
;		PSTORE will store the information on the same plot
;		region ID number as the previous one.
;
;		For TV'ed data, note that the correct ranges for the
;		axes are [coordinate of leftmost pixel - 1/2 *stepsize,
;			  coordinate of rightmost ""   + 1/2 *stepsize]
;		For plotted data (i.e., plot,x,y), xrange should
;		not be expanded in this way (the first and last data
;		points will fall _on_ the border of the plot region).
; 
;               Equidistant scales are assumed. 
;
; Use         : plot_region_no = PSTORE(NUMBER,XSIZE,YSIZE)
;    
; Inputs      : NUMBER : A user-assigned number identifying the
;			plot region(s) within this window.
;
;		X/YSIZE: The size of the displayed data. For 1D data,
;			use XSIZE=number of points, and YSIZE=1.
;               
; Opt. Inputs : None.
;               
; Outputs     : Return value: A Plot Region ID, referring to
;			the stored plot region.
;               
; Opt. Outputs: None.
;               
; Keywords    : CLEAN : Set to remove any earlier plot region definitions
;			for this window.
;
;		INIT : Restarts the common block.
;
; Calls       : None.
;
; Common      : WSTORE
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : Utility, Graphics
;               
; Prev. Hist. : None.
;
; Written     : Stein Vidar Hagfors Haugan, May 1994
;               
; Modified    : Version 2, SVHH, 7 May 1996
;                          Using D.window == -1 as a "free" indicator.
;                          Adding 100 entries at a time when expanding
;                          storage, a large gain in speed.
;               Version 3, SVHH, 30 May 1996
;                          Using -2 instead of -1 as "free" indicator, since
;                          all PS windows have !D.window = -1 !!
;
; Version     : 3, 30 May 1996
;-            

;
; DATAX,DATAY = Image size, in data pixels
; Screen size is taken from !P.clip
;

FUNCTION pstore,NN,datax,datay,clean=clean,init=init
  COMMON wstore,D,P,N,X,Y,dataxx,datayy
  
  
  IF Keyword_SET(clean)	AND N_elements(D) GT 0 THEN BEGIN
     ix = WHERE(D(*).NAME EQ !D.NAME AND D(*).WINDOW EQ !D.window,count)
     IF count GT 0 THEN D(ix).window =	-2
     IF N_PARAMS() LT 1 THEN RETURN,-2
  EndIF
  
  IF N_params()	LT 1 THEN MESSAGE,'Needs number of the plot region'
  
  IF N_params()	LT 3 THEN BEGIN
     IF N_elements(datax) EQ 0	THEN datax=1
     IF N_elements(datay) EQ 0	THEN datay=1
  EndIF
  
  
  IF N_elements(D) GT 0	AND NOT	Keyword_SET(init) THEN BEGIN
     
     ix = WHERE(D(*).NAME EQ !D.NAME AND D(*).WINDOW EQ !D.window $
                AND N(*) EQ NN, count)
     
     IF count GT 1 THEN MESSAGE,'Double window ????',/continue
     
     IF count GT 0 THEN BEGIN
        D(ix)	= !D   &  P(ix)	= !P  &	N(ix) =	NN
        X(ix)	= !X   &  Y(ix)	= !Y
        dataxx(ix)=datax   & datayy(ix)=datay
        i = ix(0)
     END ELSE BEGIN
        ix = WHERE(D(*).window EQ -2L,count)
        IF count EQ 0 THEN BEGIN
           ix = N_elements(D)
           D = [D,REPLICATE(!D,100)]
           P = [P,REPLICATE(!P,100)]
           N = [N,REPLICATE(NN,100)]
           X = [X,REPLICATE(!X,100)]
           Y = [Y,REPLICATE(!Y,100)]
           dataxx = [dataxx,REPLICATE(datax,100)] 
           datayy = [datayy,REPLICATE(datay,100)]
           D(ix:*).window = -2
        END 
        ix = ix(0)
        D(ix) = !D   &  P(ix)	= !P  &	N(ix) =	NN
        X(ix) = !X   &  Y(ix)	= !Y
        dataxx(ix)=datax   & datayy(ix)=datay
        i = ix(0)
     END
  END ELSE BEGIN
     D	= [!D]	 &  P =	[!P]   &   N = [NN]
     X	= [!X]	 &  Y =	[!Y]
     dataxx = [datax] &  datayy = [datay]
     i	= 0
  EndELSE
  
  RETURN,i
  
END



