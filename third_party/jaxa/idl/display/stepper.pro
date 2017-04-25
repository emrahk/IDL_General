PRO  STEPPER, input1, input2, input3, $
	XSIZE=XSIZE, YSIZE=YSIZE, START=START, $
	INFO_ARRAY=INFO_ARRAY,$
	NOSCALE=NOSCALE, SUBSCRIPT=SUBSCRIPT, MOVIE=MOVIE, INTERP=INTERP, $
	COLOR=COLOR, LASTSS=LASTSS, $
	noinfo=noinfo, panels=panels0, filter_panels=filter_panels, sequence_panels=sequence_panels, qstop=qstop, $
	nolcur=nolcur, nonormalize=nonormalize
;+
;  NAME:
;	STEPPER
;  PURPOSE:
;	Step through individual images a single frame at a time.
;  SAMPLE CALLING SEQUENCE:
;	STEPPER, DATA
;	STEPPER, INDEX, DATA
;	STEPPER, INDEX, DATA, INFO_ARRAY
;	STEPPER, DATA, INFO_ARRAY		; Info can be the 2nd parameter
;	STEPPER, INDEX, DATA, /FILTER_PANELS	; To show each filter separate
;  INPUTS:
;	DATA = Three-dimensional array
;  OPTIONAL INPUTS:
;	INDEX         = The index structure that goes with the data
;       INFO_ARRAY    = descriptive text string (pass as parameter or keyword)
;  OPTIONAL INPUT KEYWORDS:
;	XSIZE,YSIZE = If present, the routine will use rebin to using the
;			the /sample option.  If only XSIZE is present, YSIZE
;			will be set equal to XSIZE.
;
;			If one of the "panels" options is used, then this is the
;			size of a single panel (the size that a single image 
;			should be displayed)
;	START	    = Index of starting image
;	INFO_ARRAY  = String array containing descriptive text
;	NOSCALE	    = If set, will turn off tvscale
;	SUBSCRIPT   = Subset of array is displayed.
;	MOVIE	    = If present and =1, will initiate movie mode when called
; 	INTERP      = Controls how REBIN is done.  If present and set to 1,
;		      /INTERP ==> REBIN(A,xsize,ysize)
;		      else    ==> REBIN(A,xsize,ysize,/sample)
;	COLOR	    = The color to use for displaying the info text string.
;
;	noinfo	- If set, then do not build the INFO_ARRAY string even
;		  when the index is passed in.
;	panels	- An array with the same number of images as the data saying
;		  which panel to display the image in (ie: 0,1,2,3,0,1,2...).
;		  This allows images from a different filters to be displayed
;		  in a different region on the x-window.
;	filter_panels - If set, then build the "panels" array based on the
;		  unique filters
;	sequence_panels - If set, then build the "panels" array based on the
;		  SXT sequence number
;	nolcur	- If set, then stepper is being called from LCUR_IMAGE and
;		  it should not allow the LCUR option to be used
;  VERSION:
;	V1.2    17-NOV-92
;	V2.0	19-Oct-93
;  HISTORY:
;	Written 20-sep-91, JRL and LWA
;	Updated 21-sep-91, JRL:  Added xloadct and zoom options.
;	Updated 24-sep-91, JRL:  Added SUBSCRIPT and MOVIE options.
;	Updated  2-dec-91, JRL:  Break the text string into two lines if
;				 info_array is > 44
;	Updated 15-dec-91, slf;  Replaced get_kbrd calls with get_kbrd2
;				 to work around SGI anomoly
;	Updated 16-apr-92, slf;  To work with single image
;	Updated 28-apr-92, JRL:  Break text if strlen(info) > 38 
;	Updated 29-apr-92, JRL:  Added the INTERP keyword
;	Updated 17-nov-92, JRL:  Added color keyword.  Allow info_array to
;				 be a 2nd parameter
;	Updated 15-mar-93, JRL:  Added an option to call profiles
;	Updated 13-may-93, SLF;  Return last selected in lastss
;	------------------------------------------------------------
;	Updated 17-Oct-93, MDM;  Broke the routine into two parts
;				 Allowed new options
;					"g" will plot sxt grids
;					"l" will call LCUR_PLOT to plot curves
;					"h" will make hardcopies
;					"c" will call loadct
;					different panels for different filters
;	Updated 29-Nov-93, MDM;  Added NOLCUR option
;	Updated 24-Aug-94, MDM;  Added NONORMALIZE option
;-
on_error,2		; Return to caller

;  If no arguments, show the caller the sequence:

if n_params() eq 0 then begin
  print,'STEPPER, DATA'
  print,'STEPPER, INDEX, DATA
  print,'STEPPER, INDEX, DATA, INFO_ARRAY
  print,'STEPPER, DATA, INFO_ARRAY'
  return
endif
;
typ1 = data_type(input1)
typ2 = data_type(input2)
;
if (keyword_set(filter_panels) and (typ1 eq 8)) then begin
     filta = gt_filta(input1)
     filtb = gt_filtb(input1)
     ss = where(filta eq 6)
     if (ss(0) ne -1) then filta(ss) = 1	;make ND filters same as open
     filts = filta + filtb*10
     ufilts = filts( uniq(filts, sort(filts)) )
     temp = intarr(max(ufilts+1))
     temp(ufilts) = indgen(n_elements(ufilts))
     panels = temp( filts )			;should be 0,1,2,3...
end
if (keyword_set(sequence_panels) and (typ1 eq 8)) then begin
    seqs = gt_seq_num(input1)
    useqs = seqs( uniq(seqs, sort(seqs)) )
    temp = intarr(max(useqs+1))
    temp(useqs) = indgen(n_elements(useqs))
    panels = temp( seqs )			;should be 0,1,2,3...
end
if (n_elements(panels0) ne 0) then panels = panels0
;
case 1 of
    (typ2 eq 0): STEPPER_s1, input1, $						;only data passed
			XSIZE=XSIZE, YSIZE=YSIZE, START=START, $
			INFO_ARRAY=INFO_ARRAY,$
			NOSCALE=NOSCALE, SUBSCRIPT=SUBSCRIPT, MOVIE=MOVIE, INTERP=INTERP, $
			COLOR=COLOR, LASTSS=LASTSS, $
			panels=panels, nonormalize=nonormalize
    (typ1 eq 8): begin								;index,data or index,data,info passed
		if (n_elements(input3) ne 0) then info_array = input3
		if (not keyword_set(noinfo) and (n_elements(info_array) eq 0)) then info_array = get_info(input1, /noninteractive)
		STEPPER_s1, input2, $
			XSIZE=XSIZE, YSIZE=YSIZE, START=START, $
			INFO_ARRAY=INFO_ARRAY,$
			NOSCALE=NOSCALE, SUBSCRIPT=SUBSCRIPT, MOVIE=MOVIE, INTERP=INTERP, $
			COLOR=COLOR, LASTSS=LASTSS, $
			index=input1, panels=panels, nolcur=nolcur, nonormalize=nonormalize
		end
    (typ2 eq 7): STEPPER_s1, input1, $						;data, info_array passed
			XSIZE=XSIZE, YSIZE=YSIZE, START=START, $
			INFO_ARRAY=input2, $
			NOSCALE=NOSCALE, SUBSCRIPT=SUBSCRIPT, MOVIE=MOVIE, INTERP=INTERP, $
			COLOR=COLOR, LASTSS=LASTSS, $
			panels=panels, nonormalize=nonormalize
endcase

if (keyword_set(qstop)) then stop
end
