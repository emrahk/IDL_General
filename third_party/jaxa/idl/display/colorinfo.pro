FUNCTION COLORINFO, QUIET=QUIET

;+
; NAME:
;    COLORINFO
;
; PURPOSE:
;    Get information about the color mode for the current IDL session.
;
; CATEGORY:
;    Color utilities.
;
; CALLING SEQUENCE:
;    RESULT = COLORINFO()
;
; INPUTS:
;    None
;
; OPTIONAL INPUTS:
;    None
;	
; KEYWORD PARAMETERS:
;    QUIET         If set, no information is printed on-screen.
;                  (default is to print the color information on-screen).
;              
; OUTPUTS:
;    RESULT        A structure containing the color information
;                  RESULT.NCOLORS      => Total number of colors available
;                  RESULT.TABLE_SIZE   => Size of the color table
;                  RESULT.VISUAL_NAME  => Name of the current visual
;                  RESULT.VISUAL_DEPTH => Bit depth of the current visual
;                  RESULT.DECOMPOSED   => Decomposed color flag
;                                         (0, 1, or 'Unknown')
;
; OPTIONAL OUTPUTS:
;    None
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    If a window has not been created in this session, this routine
;    creates (and then deletes) a pixmap window.
;
; RESTRICTIONS:
;    Only runs on X, Windows, and Macintosh displays.
;    Only runs under IDL 5.0 and higher.
;
; EXAMPLE:
;
; info = colorinfo()
;
; MODIFICATION HISTORY:
;    Written by: Liam.Gumley@ssec.wisc.edu
;    $Id: colorinfo.pro,v 1.2 1999/07/16 18:47:49 gumley Exp $
;-

rcs_id = "$Id: colorinfo.pro,v 1.2 1999/07/16 18:47:49 gumley Exp $"

;- Check for supported display

if (!d.name ne 'X') and (!d.name ne 'WIN') and (!d.name ne 'MAC') then begin
  message, 'This routine is only supported on X, WIN, and MAC displays', /continue
  return, 0
endif

;- Get IDL version number

version = float(!version.release)

;- Check for IDL 5.0 or higher

if version lt 5.0 then $
  message, 'This routine is only supported on IDL version 5.0 or higher'

;- Make sure a window has been opened in this session

current_window = !d.window
window, /free, /pixmap
wdelete, !d.window
if current_window gt 0 then wset, current_window

;- Get color information available in IDL 5.0

ncolors = !d.n_colors
table_size = !d.table_size
device, get_visual_name=visual_name

;- Get color information available in IDL 5.1 and higher

if version gt 5.0 then begin
  device, get_visual_depth=visual_depth
endif else begin
  visual_depth = 8
  if (visual_name eq 'DirectColor') or $
     (visual_name eq 'TrueColor') then visual_depth = 24
endelse

;- Get color information available in IDL 5.2 and higher

decomposed = 'Unknown'
if version gt 5.1 then device, get_decomposed=decomposed

;- Print information for the user

if not keyword_set(quiet) then begin
  print, !version
  if !version.os_family eq 'unix' then begin
    spawn, "xdpyinfo | fgrep 'class:' | sort | uniq", result
    print, 'Color modes available are ', strcompress(result, /remove_all)
  endif
  print, 'Number of colors:      ', strcompress(ncolors, /remove_all)
  print, 'Color table size:      ', strcompress(table_size, /remove_all)
  print, 'Current color mode:    ', strcompress(visual_name, /remove_all)
  print, 'Current color depth:   ', strcompress(visual_depth, /remove_all)
  print, 'Decomposed color flag: ', strcompress(decomposed, /remove_all)
endif

;- Return color information structure

return, {ncolors:ncolors, $
         table_size:table_size, $
         visual_name:visual_name, $
         visual_depth:visual_depth, $
         decomposed:decomposed}
         
END
