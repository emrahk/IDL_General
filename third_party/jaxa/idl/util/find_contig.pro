function find_contig, ss, ss_sel, ss_sel_2d, qdebug=qdebug
;+
;NAME:
;	find_contig
;PURPOSE:
;	Find the contiguous integers in the input array, ss.  Used for finding
;	unique peaks.
;INPUTS:
;	ss - array of integers, must be monotonically increasing
;OUTPUTS:
;	ss_sel - indices on ss array indicating first element of a run of contiguous integers
;	ss_sel_2d - indices on ss array giving first and last elements of a run
;		of contiguous integers, dimensioned Nx2
;Result:
;	contig = find_contig( ss )
;		An element of SS becomes an element of CONTIG for each SS[i] such that (SS[i] - SS[i-1]) gt 1 and SS[i+1]-SS[i] = 1
;METHOD:
;	Return the first element of each run of contiguous integers
;
;	ss = [4,5,6,  10,  21,22]  returns [4,10,21]
;	ss = [1,    10,    30]     returns [1,10,30]
;	ss = [1,2,3,4]		  returns [1]
;	ss = 10			  returns 10
;HISTORY:
;   Written 29-Jul-97 by M.Morrison
;   22-Jun-2004, Kim Tolbert.  Added ss_sel_2d argument to return 2-d array of
;     start,end indices for contiguous ranges. If a=[4,5,6,  10,  21,22], then
;     ss_sel_2d is [3,2] and equals [ [0,3,4], [2,3,5] ].  If a=[4,5,6] then
;     ss_sel_2d equals [0,2]
;	12-nov-2008, documentation added by RAS
;-
;
ss_sel = 0
ss_sel_2d = [0,0]
nss = n_elements(ss)
if (nss eq 0) then return, -1
if (nss eq 1) then return, 0
;
dss = [deriv_arr(ss)]
ss2 = where(dss ne 1, nss2)
if (nss2 ne 0) then ss_sel = [0,ss2+1] $
		else ss_sel = 0
;
if (keyword_set(qdebug)) then begin
    print, 'Input:            ', ss
    print, 'Where delta <> 1: ', ss2
    print, 'SS_SEL            ', ss_sel
end
;
out = ss[ss_sel]
if n_elements(ss_sel) eq 1 then ss_sel_2d = [0, n_elements(ss)-1] else $
	ss_sel_2d = [ [ss_sel], [ [ss_sel(1:*),n_elements(ss)]-1] ]
return, out
end
