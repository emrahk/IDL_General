
PRO NEW_SPIKE, IN_ARRAY, OUT_ARRAY, NEIGHBOURS=NEIGHBOURS, $
               MISSING=MISSING, FILL=FILL, INFO=INFO, SWTCH=SWTCH, $
               YBIN=YBIN

;+
; PROJECT:
;
;	SOHO - CDS
;
; NAME:
;
;	NEW_SPIKE
;
; CATEGORY: 
;
;	General utility.
;
; PURPOSE:
;
;	Remove cosmic ray hits from CDS-NIS data-sets.
;
; EXPLANATION:
;
;	A revised version of the routine CLEAN_SPIKE.PRO which applies a 
;	very similar technique for finding the cosmic rays, but is 
;	significantly quicker. This extra speed is made by using the IDL 
;	CONVOL routine.
;
;	The fundamental philosophy of this routine lies in identifying 
;	pixels that have a significant strength when compared with 
;	neighbouring exposures. Sometimes, however, such a method will 
;	flag real data as a cosmic ray, e.g., if a strong brightening 
;	suddenly appears in the data. Such a brightening is different from 
;	a cosmic ray in that it will be continuous in detector-X and Y 
;	directions, and so this routine only flags a cosmic ray if a spike 
;	is also seen in one of the detector-X or detector-Y directions.
;
;	The checks made in the detector-Y direction are not simply with 
;	nearest neighbour, but also with pixels one away. The criteria are 
;	more stringent for this test, however.
;
;	An additional check is made by comparing a pixel value with the 
;	median value of a 5x5 array of (detector-Y x exposure) array pixels. 
;	If the pixel is flagged and a spike is seen in both the detector-Y 
;	and detector-X directions, then the pixel is identified as a cosmic 
;	ray. This is useful if there are a lot of cosmic rays in the data.
;
; EXAMPLE:
;
;	Create a 3-D NIS array and clean:
;
;		qlds=readcdsfits('s3073r00')
;		data=gt_windata(qlds,0)
;		new_spike,data,data_clean,/neighbours,/info
;
; INPUTS:
;
;	IN_ARRAY -	A 3D array, with exposures assumed to be contained 
;			in the 2nd dimension.
;
; OPTIONAL INPUTS:
;
;	MISSING -	The value for missing data (default=-100.)
;
; OPTIONAL OUTPUTS:
;
;	OUT_ARRAY -	The output, cleaned array
;
;	SWTCH -		An integer array of the same size as IN_ARRAY, 
;			containing 1's at the position of cosmic rays 
;			and 0's elsewhere.
;
; KEYWORDS:
;
;	NEIGHBOURS -	Flag the detector-X and detector-Y nearest neighbours 
;			to the cosmic rays.
;
;	FILL -		Replace the cosmic ray intensity values with the 
;			median of the surrounding 5x5 pixel area.
;
;	INFO -		Display the number of cosmic rays found.
;
; CALLS:
;
;	CONVOL, FMEDIAN
;
; RESTRICTIONS:
;
;	The data should be de-biassed before using NEW_SPIKE.
;
;	The smallest dimensions possible for IN_ARRAY are (4,3,6) for the 
;	array (det-X,exp,det-Y).
;
;	Occasional cosmic rays appear as `blocks' of size 2x2 or 3x3 pixels, 
;	and may not be completely cleaned by NEW_SPIKE.
;
;	Some weak, single-pixel events are not removed, although their 
;	signals should not be a problem.
;
;	Some cosmic rays that hit the peak of a line profile are not 
;	removed. This seems to be because, if the signal in the line is 
;	strong, say 300, then the cosmic ray is required to give a total 
;	signal of at least 510 in order to be flagged, and so some quite 
;	significant events are skipped over.
;
; PROGRAMMING NOTES
;
;       David Brooks pointed out that real solar data was being removed when
;       data-set s25413r43 was cleaned. The particular data in question is
;       in the O V window (gt_windata(qlds,2)), and the profile ov[*,1,19].
;
;       The problem lies in the fact that this data is binned in the
;       Y-direction. All the tests I had done were on normal, unbinned data
;       (Y-binning was not used until around mid-1998 for CDS). The parameters
;       I had set up for determining cosmic rays (CUTOFF and BCKGRND)
;       unintentionally assumed a certain 'smoothness' in the data that is
;       due to the CDS PSF being broader than the pixel size. I.e., real
;       data should never show sharp spikes because of the PSF, and so must
;       be cosmic rays. When binning in the Y-direction, the Y-pixel size
;       becomes closer to the width of the PSF and so real data-spikes do
;       become possible, as witnessed by the above data-set.
;
;       I have now increased CUTOFF to 0.65, but also defined XCUTOFF and
;       YCUTOFF (where X, Y are the detector axes) to be 0.8*CUTOFF, i.e.,
;       I've *lowered* the threshold. When the keyword /YBIN is set
;       YCUTOFF=CUTOFF, increasing the threshold in this case, making it
;       harder to flag spikes when there is Y-binning.
;
;       The lowering of the threshold in the X and Y directions flags a few
;       more cosmic rays, but does not (from the tests I've done) remove real
;       data.
;
;       In the Y-direction, NEW_SPIKE checks next-neighbours for reasons
;       explained above. When /YBIN is set I now change the cutoff to be
;       YCUTOFF*3 rather than YCUTOFF*2, as next-neighbours become less
;       important when binning.
;
; HISTORY:
;
;	Ver. 1 - PRY, 18-Aug-98
;	Ver. 2 - PRY, 2-Sep-98, if all pixels in an array have intensities 
;			less than 50 or greater than 50, then an error was 
;			generated. This is now corrected.
;	Ver. 3 - PRY, 4-Sep-98, if med_array was 0. at some pixel, then 
;			arithmetic errors were generated for some rasters. 
;			Corrected this.
;	Ver. 4 - PRY, 16-Nov-98, if ind was empty, then routine crashed. 
;			Now corrected.
;	Ver. 5 - PRY, 2-Feb-99, corrected another problem with ind
;       Ver. 6 - Danielle Bewsher, 9-May-01, corrected problem with switch
;                       for compatability with IDL 5.4
;       Ver. 7 - PRY, 20-Feb-03
;                 Flags problem when IN_ARRAY is too small.
;                 Also, if there are less than 5 exposures the program 
;                 switches to using a 3x7 median filter rather than the 5x5 
;                 filter.
;       Ver. 8 - PRY, 21-Jul-03
;                 Program was not returning the SWTCH array, so corrected
;                 this now.
;       Ver. 9 - PRY, 15-Aug-03
;                 Added YBIN= keyword, and modified the parameters that
;                 identify a cosmic ray. See Programming Notes above.
;
; CONTACT:
;
;	Peter Young, Rutherford Appleton Laboratory, p.r.young@rl.ac.uk
;-


;-----------------------------------------------------
; There are six different arrays used in this routine:
;
; IN_ARRAY -	The input array
; WORK_ARRAY -	Array on which operations are performed during routine
; OUT_ARRAY -	The output array
; MED_ARRAY -	Array containing the median values
; COMP_ARRAY -	The comparison array used to see if the IN_ARRAY values 
;		are cosmic rays.
; CUTOFF_ARRAY- Contains factor by which each element of array needs to be 
;               greater than background in order to be flagged.
;-----------------------------------------------------

;-----------------------------------------------------
;Programming note:
;
; You'll notice that I use /EDGE_WRAP in the calls to CONVOL. I only use 
; kernels that are vectors, but I have to write them as 3-D arrays for 
; CONVOL. IDL automatically truncates an array of the form, e.g., (*,0,0), 
; into a vector and so I define kernels of the form bytarr(3,1,3) for the 
; lambda-direction to stop this happening. Unfortunately this means that 
; when CONVOL gets to the y-edge of the (*,x,*) array, it sets values to 
; zero, which I don't want. Hence I use EDGE_WRAP to see these values. 
; There are no spurious edge values in this technique.
;-----------------------------------------------------


IF N_PARAMS() LT 1 THEN BEGIN
  PRINT,'Use:  IDL> new_spike, in_array [, out_array, /neighbours, $ '
  PRINT,'                         /info, /fill, missing=missing, $ '
  PRINT,'                         swtch=swtch] '
  RETURN
ENDIF

IF N_ELEMENTS(missing) EQ 0 THEN missing=-100.

sz=size(in_array)
switch_x=make_array(size=sz,/int)      ; contains position of spikes
switch_y=switch_x
switch_lambda=switch_x

IF (sz[1] LT 4) OR (sz[2] LT 3) OR (sz[3] LT 6) THEN BEGIN
  print,'** The dimensions of IN_ARRAY ['+ $
       strtrim(string(sz[1]),2)+','+strtrim(string(sz[2]),2)+','+$
       strtrim(string(sz[3]),2)+'] are too small'
  print,'** The minimum possible dimensions are [4,3,6]'
  out_array=-1.
  return
ENDIF


cutoff=.65         ;      ) parameters that determine cosmic ray
bckgrnd=6.        ;      )

cutoff_arr=make_array(size=sz,/float)+cutoff

;;----------------------------------[]
; Need to create an array of same size as dat containing median values. Note 
; that the median is based on x-y values
;
med1=5
med2=5
IF sz[2] LT 5 THEN BEGIN
  med1=3
  med2=7
ENDIF
med_array=make_array(size=sz,/float)
FOR i=0,sz(1)-1 DO  $
   med_array(i,*,*)=FMEDIAN(REFORM(in_array(i,*,*)),med1,med2,missing=missing)
;;----------------------------------[]


;;----------------------------(I)
; The work_array is the same as in_array, but any missing pixels are 
; replaced with median values. This prevents any problems with the -100's 
; in the averaging done later.
;
work_array=in_array
ind_miss=WHERE(in_array EQ missing)
IF ind_miss(0) NE -1 THEN work_array(ind_miss)=med_array(ind_miss)
;;----------------------------(I)


;;-----------------------------------------<0>
; Check in EXPOSURE direction for spikes
;
kernel=intarr(1,3,3)
kernel(0,*,1)=[1,0,1]
;
comp_array=CONVOL(work_array,kernel,2,/EDGE_WRAP)
;
comp_array(*,[0,sz(2)-1],*)=work_array(*,[1,sz(2)-2],*)
ind=WHERE(comp_array EQ 0.)
IF ind(0) NE -1 THEN comp_array(ind)=0.1
;
ind=WHERE(comp_array GT 50.)
IF ind(0) NE -1 THEN cutoff_arr(ind)=0.5
;
ind=WHERE( ( ABS((work_array-comp_array)/comp_array) GT cutoff_arr) AND $
           (work_array-med_array GT bckgrnd) AND $
           (comp_array NE missing) )
;
IF ind(0) NE -1 THEN switch_x(ind)=1
;
ind=WHERE(med_array EQ 0.)               ; to prevent arithmetic errors 
IF ind(0) NE -1 THEN med_array(ind)=0.1  ; when dividing by med_array
;
ind=WHERE( ( ABS((work_array-med_array)/med_array) GT cutoff_arr) AND $
           (work_array-med_array GT bckgrnd) AND $
           (comp_array NE missing) )
;
comp_array=0
;
IF ind(0) NE -1 THEN switch_x(ind)=TEMPORARY(switch_x(ind))+10
;;-----------------------------------------<0>

IF NOT KEYWORD_SET(fill) THEN med_array=0         ; delete as not needed

;
; if the data are not binned in the y-direction, then I reduce the cutoff, 
; since the data should be fairly smooth in the y-direction (due to the CDS 
; PSF).
; For pixels with strong signal (>50), I reduce the cutoff by the factor 5/6 
; (the same as in earlier versions of the routine.
;
IF NOT keyword_set(ybin) THEN ycutoff=0.8*cutoff ELSE ycutoff=cutoff
bigcutoff=ycutoff*5./6.

;;-----------------------------------------<I>
; Look in DETECTOR-Y direction   (kernel = [1,0,1])
;
kernel=intarr(1,1,3)
kernel(0,0,*)=[1,0,1]
;
comp_array=convol(work_array,kernel,2)
;
comp_array(*,*,[0,sz(3)-1])=work_array(*,*,[1,sz(3)-2])
ind=WHERE(comp_array EQ 0.)
IF ind(0) NE -1 THEN comp_array(ind)=0.1
;
cutoff_arr(*,*,*)=ycutoff
;
ind=WHERE(comp_array GT 50.)
IF ind(0) NE -1 THEN cutoff_arr(ind)=bigcutoff
;
ind=where( ( abs((work_array-comp_array)/comp_array) GT cutoff_arr) AND $
           (comp_array NE missing) )
;
comp_array=0
;
IF ind(0) NE -1 THEN switch_y(ind)=1
;;-----------------------------------------<I>

;
; for next-nearest neighbours (nn) I multiply ycutoff by 2. If ybin set then 
; I increase this to 3.
;
nnfac=2.
IF keyword_set(ybin) THEN nnfac=3.0

;IF NOT keyword_set(ybin) THEN BEGIN
;;-----------------------------------------<0>
; Look in DETECTOR-Y direction   (kernel = [0,1,0,0,1])
;
kernel=intarr(1,1,5)
kernel(0,0,*)=[0,1,0,0,1]
;
comp_array=convol(work_array,kernel,2)
;
comp_array(*,*,1)=(work_array(*,*,0)+work_array(*,*,3))/2.
comp_array(*,*,[0,sz(3)-2,sz(3)-1])=missing
ind=WHERE(comp_array EQ 0.)
IF ind(0) NE -1 THEN comp_array(ind)=0.1
;
cutoff_arr(*,*,*)=ycutoff*nnfac
;
ind=WHERE(comp_array GT 50.)
IF ind(0) NE -1 THEN cutoff_arr(ind)=bigcutoff*nnfac
;
ind=where( ( abs((work_array-comp_array)/comp_array) gt cutoff_arr) and $
           (comp_array NE missing) )
;
comp_array=0
;
IF ind(0) NE -1 THEN switch_y(ind)=1
;;-----------------------------------------<0>


;;-----------------------------------------<I>
; Look in DETECTOR-Y direction   (kernel = [1,0,0,1,0])
;
kernel=intarr(1,1,5)
kernel(0,0,*)=[1b,0,0,1b,0]
;
comp_array=convol(work_array,kernel,2)
;
comp_array(*,*,sz(3)-2)=(work_array(*,*,sz(3)-4)+work_array(*,*,sz(3)-1))/2.
comp_array(*,*,[0,1,sz(3)-1])=missing
ind=WHERE(comp_array EQ 0.)
IF ind(0) NE -1 THEN comp_array(ind)=0.1
;
cutoff_arr(*,*,*)=ycutoff*nnfac
;
ind=WHERE(comp_array GT 50.)
IF ind(0) NE -1 THEN cutoff_arr(ind)=bigcutoff*nnfac
;
ind=where( ( abs((work_array-comp_array)/comp_array) gt cutoff_arr) and $
           (comp_array NE missing) )
;
comp_array=0
;
IF ind(0) NE -1 THEN switch_y(ind)=1
;;-----------------------------------------<I>
;ENDIF


xcutoff=cutoff*0.8

;;-----------------------------------------<0>
; Look in DETECTOR-X direction
;
kernel=intarr(3,1,3)
kernel(*,0,1)=[1b,0,1b]
;
comp_array=convol(work_array,kernel,2,/edge_wrap)
;
comp_array([0,sz(1)-1],*,*)=work_array([1,sz(1)-2],*,*)
ind=WHERE(comp_array EQ 0.)
IF ind(0) NE -1 THEN comp_array(ind)=0.1
;
cutoff_arr(*,*,*)=xcutoff
;
ind=WHERE(comp_array GT 50.)
IF ind(0) NE -1 THEN cutoff_arr(ind)=xcutoff*5./6.
;
ind=where( ( abs((work_array-comp_array)/comp_array) gt cutoff_arr) AND $
           (comp_array NE missing) )
;
comp_array=0 & cutoff_arr=0
;
IF ind(0) NE -1 THEN switch_lambda(ind)=1
;;-----------------------------------------<0>


;;----------------------------IOI
; The following logic operations load up the flagged pixels into switch
;
switch1=((switch_x eq 11) or (switch_x eq 1)) and ( switch_y or switch_lambda )
switch2=(switch_x eq 10) and ( switch_y and switch_lambda )
switch_x=0 & switch_y=0 & switch_lambda=0
swtch=switch1 or switch2
;;----------------------------IOI

switch1=0 & switch2=0

;;--------------------------------------<>
; This flags the cosmic ray neighbours. I've copied this from Stein 
; Vidar's clean_exposure routine
;
IF KEYWORD_SET(neighbours) THEN BEGIN
  pix=WHERE(swtch EQ 1)
  IF pix(0) NE -1 THEN BEGIN
    kernel=INTARR(3,1,3)
    kernel(*,0,*)=[[0,1,0],[1,1,1],[0,1,0]]
    touched=MAKE_ARRAY(size=sz)
    touched(pix)=1
    touched = CONVOL(touched,kernel,/EDGE_TRUNCATE)
    swtch(WHERE(touched GT 0))=1
  ENDIF
ENDIF
;;--------------------------------------<>

ind=WHERE(swtch EQ 1)

IF KEYWORD_SET(info) THEN BEGIN
  IF ind(0) NE -1 THEN $
        PRINT,'     Pixels flagged: ',STRTRIM(N_ELEMENTS(ind)) ELSE $
        PRINT,'     No pixels flagged'
ENDIF

out_array=in_array
IF ind(0) NE -1 THEN BEGIN
  out_array(ind)=missing
  IF KEYWORD_SET(fill) THEN out_array(ind)=med_array(ind)
ENDIF

IF N_PARAMS() EQ 1 THEN in_array=out_array

END
