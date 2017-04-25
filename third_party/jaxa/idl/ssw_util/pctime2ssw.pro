function pctime2ssw, pctime, out_style=out_style
;+
;   Name: pctime2ssw
;
;   Purpose: convert a PC time->SSW (anytim output)
;
;   Input Parameters:
;      pctime - vector of PC format times ( DD-MM-YYYY HH:MM:SS )  
;
;   Keyword Parameters:
;      out_style - descibe output format (see anytim.pro) - default INTERNAL
;  
;   History:
;      22-dec-1998 - S.L.Freeland
;-
if not keyword_set(out_style) then out_style='internal'

dtime=str2cols(strtrim(pctime,2))
ctime=strtrim(str2cols(reform(dtime(0,*)),'-'),2)

outtime=anytim( reform(ctime(2,*)) + '/' +  $
	        reform(ctime(0,*)) + '/' +  $
	        reform(ctime(1,*)) + ' ' +  $
                reform(dtime(1,*)), out_style=out_style)
return,outtime
end
								  
