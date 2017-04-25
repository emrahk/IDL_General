
FUNCTION get_source_stc, datasource=datasource
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       GET_SOURCE_STC()
;
; PURPOSE: 
;       Get a source structure based on the datatype. 
;
; CATEGORY:
;       Planning, Image_tool
; 
; EXPLANATION:
;       This routine returns a structure that refelct the image
;       sources of the solar image FITS files
;
; SYNTAX: 
;       Result = get_source_stc()
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - A structure that contains the following tag names:
;          NAME    - Name of image sources to be shown
;          DIRNAME - the actual directory name for the image sources
;                    under the SYNOP_DATA or SUMMARY_DATA direcotry
;
;          By default, RESUTL is a source structure for synoptic data
;          unless the keyword SUMMARY is set.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       DATASOURCE - SOHO data source: 1 (default): synoptic data; 2:
;                    summary data; 3: private data
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, August 16, 1995, Liyun Wang, NASA/GSFC. Written
;       Version 2, June 17, 1996, Liyun Wang, NASA/GSFC
;          Added Pic du Midi Observatory
;       Version 3, July 30, 1996, Liyun Wang, NASA/GSFC
;          Added Kiepenheuer Institute for Solar Physics
;       Version 4, February 1998, Zarro (SAC/GSFC)
;          Added TRACE
;	Version 5, Nov 3, 1998, Bentley (MSSL/UCL)
;          Checks env. variables and only lists directories that are
;          present
;       Version 6, Sept 16, 2006, Zarro (ADNET/GSFC)
;          Fixed some bad coding on the part of Dr. Bentley
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;

   sources = {dir_index:0, name:'N/A', dirname:'N/A'}


   IF N_ELEMENTS(datasource) EQ 0 THEN datasource = 1

   IF datasource LT 1 OR datasource GT 3 THEN BEGIN
      MESSAGE, 'Invalid SOHO data source: '+STRTRIM(STRING(datasource),2)+$
         '. SOHO synoptic data assumed.', /cont
      datasource = 1
   ENDIF 

   if (datasource eq 1) and trim(getenv('SYNOP_DATA')) eq '' then $
    return,sources

   if (datasource eq 2) and trim(getenv('SUMMARY_DATA')) eq '' then $
    return,sources

   if (datasource eq 3) and trim(getenv('PRIVATE_DATA')) eq '' then $
    return,sources

   if datasource eq 1 then begin
      name = ['Yohkoh Soft-X Telescope', $
              'Obs. of Paris at Meudon', $
              'Kitt Peak National Observatory', $
              'Learmonth Observatory, Australia',$
              'Mt. Wilson Observatory', $
              'Space Environment Lab',$
              'Mauna Loa Solar Observatory',$
              'Holloman AFB',$
              'Mees Solar Observatory',$
              'Nobeyama Radio Observatory',$
              'Sacramento Peak Observatory',$
              'Pic du Midi Observatory',$
              'Kiepenheuer Inst. for Solar Phys.', $
              'Kanzelhohe Solar Observatory', $
              'Big Bear Solar Observatory',$
              'Other Institutes']
      dirname = ['yohk','meud', 'kpno', 'lear', 'mwno', 'kbou', $
                 'mlso', 'khmn', 'mees', 'nobe', 'ksac', 'pdmo', $
                 'kisf', 'kanz','bbso', 'other']
      if (getenv('TRACE_SUMMARY') ne '') or (getenv('TRACE_PRIVATE') ne '') then begin
       name=['Transition Region And Coronal Explorer',name]
       dirname=['trace',dirname]
      endif

;		only include directories if present
;      ff = findfile(getenv('SYNOP_DATA'),count=nff)
;      present =intarr(n_elements(dirname))
;      for js=0,n_elements(dirname)-1 do present(js)=where(dirname(js) eq ff)
;      print,dirname(where(present gt 0)) 
;      ok=where(present ge 0,cnt)
;      if cnt eq 1 then ok=ok[0]
;      if cnt gt 0 then begin
;       dirname = dirname(ok)
;       name    = name(ok)
       sources = {dir_index:0, name:name, dirname:dirname}
;      endif                               

   ENDIF ELSE BEGIN
      name = ['SOHO-EIT',$
              'SOHO-LASCO',$
              'SOHO-MDI',$
              'SOHO-UVCS',$
              'SOHO-CDS',$
              'SOHO-SUMER',$
              'SOHO-GOLF',$
              'SOHO-SWAN',$
              'SOHO-VIRGO',$
              'SOHO-CEPAC',$
              'SOHO-CELIAS']
      dirname = ['eit', 'lasco', 'mdi', 'uvcs', 'cds', 'sumer', 'golf', $
                 'swan', 'virgo', 'cepac', 'celias']

;		only include directories if present

;      if (datasource eq 2) or (datasource eq 3) then begin
;        if (datasource eq 2) then $
;         ff = findfile(getenv('SUMMARY_DATA'),count=nff) else $
;          ff = findfile(getenv('PRIVATE_DATA'),count=nff)
;         ff=strtrim(strlowcase(ff),2)
;         present =intarr(n_elements(dirname))
;         for js=0,n_elements(dirname)-1 do present(js)=where(dirname(js) eq ff)
;         ok=where(present ge 0,cnt)
;         if cnt eq 1 then ok=ok(0)
;         if cnt gt 0 then begin
;          dirname = dirname(ok)
;          name    = name(ok)
          sources = {dir_index:0, name:name, dirname:dirname}
;         endif                               
;      endif

   ENDELSE

   RETURN, sources
END


