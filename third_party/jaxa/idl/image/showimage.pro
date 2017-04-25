PRO SHOWIMAGE, FILE, DITHER=DITHER, CURRENT=CURRENT

;+
; NAME:
;    SHOWIMAGE
;
; PURPOSE:
;    Show the contents of a graphics file in the current window.
;
;    The input formats supported are:
;    GIF   8-bit with color table,
;    BMP   8-bit with color table or 24-bit true-color,
;    PICT  8-bit with color table,
;    TIFF  8-bit with color table or 24-bit true-color,
;    JPEG 24-bit true color,
;
;    Any conversions necessary to translate 8-bit or 24-bit files
;    to 8-bit or 24-bit images on-screen are done automatically.
;
; CATEGORY:
;    Input/Output.
;
; CALLING SEQUENCE:
;    SHOWIMAGE, FILE
;
; INPUTS:
;    FILE     Name of the output file (format is identified automatically).
;
; OPTIONAL INPUTS:
;    None.
;
; KEYWORD PARAMETERS:
;    DITHER   Set this keyword to dither the input image when displaying
;             24-bit images on an 8-bit display (default is no dithering).
;    CURRENT  Set this keyword to display the image in the current window
;             (default is to create a new window sized to fit the image).
;
; OUTPUTS:
;    None.
;
; OPTIONAL OUTPUTS:
;    None
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    The color table is modified.
;
; RESTRICTIONS:
;    Requires IDL 5.2 or higher (image QUERY functions).
;
; EXAMPLE:
;
;showimage, filepath('rose.jpg', subdir='examples/data')
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; $Id: showimage.pro,v 1.15 1999/11/19 21:20:50 gumley Exp $
;
; Copyright (C) 1999 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: showimage.pro,v 1.15 1999/11/19 21:20:50 gumley Exp $'

;-------------------------------------------------------------------------------
;- CHECK INPUT
;-------------------------------------------------------------------------------

;- Check IDL version

if float(!version.release) lt 5.2 then begin
  message, 'IDL 5.2 or higher is required', /continue
  return
endif

;- Check input arguments

case 1 of
  n_params() ne 1           : error = 'Usage: SHOWIMAGE, FILE'
  n_elements(file) eq 0     : error = 'Argument FILE is undefined'
  n_elements(file) gt 1     : error = 'Argument FILE must be a scalar string'
  (findfile(file))[0] eq '' : error = 'Argument FILE was not found'
  else                      : error = ''
endcase

if error ne '' then begin
  message, error, /continue
  return
endif

;-------------------------------------------------------------------------------
;- CHECK THE GRAPHICS DEVICE
;-------------------------------------------------------------------------------

;- Check for device supporting windows and tvrd()

if ((!d.flags and 256) eq 0) or ((!d.flags and 128) eq 0) then begin
  error = string(!d.name, format='("Graphics device (",a,") is not supported")')
  message, error, /continue
  return
endif

;- Make sure a window has been opened in this session and get visual depth

if !d.window lt 0 then begin
  window, /free, /pixmap, xsize=20, ysize=20
  wdelete, !d.window
endif
device, get_visual_depth=depth

;- If 8-bit display is low on colors, print a message

if (depth eq 8) and (!d.table_size) lt 64 then message, $
  'Display has less than 64 colors; image quality may degrade', /continue

;-------------------------------------------------------------------------------
;- IDENTIFY FILE AND READ IMAGE
;-------------------------------------------------------------------------------

;- Identify the file format

result = query_gif(file, info)
if result eq 0 then result = query_bmp(file, info)
if result eq 0 then result = query_pict(file, info)
if result eq 0 then result = query_tiff(file, info)
if result eq 0 then result = query_jpeg(file, info)
if result eq 0 then begin
  message, 'File format not recognized', /continue
  return
endif

;- Fix the channel information for GIF images

if info.type eq 'GIF' then info.channels = 1

;- Read the image

case info.type of

  'GIF' : read_gif, file, image, r, g, b

  'BMP' : begin
    if info.channels eq 1 then begin
      image = read_bmp(file, r, g, b)
    endif else begin
      image = read_bmp(file)
      image = reverse(temporary(image), 1)
    endelse
  end

  'PICT' : read_pict, file, image, r, g, b

  'TIFF' : begin
    if info.channels eq 1 then begin
      image = read_tiff(file, r, g, b, order=order)
      image = reverse(temporary(image), 2)
    endif else begin
      image = read_tiff(file, order=order)
      image = reverse(temporary(image), 3)
    endelse
  end

  'JPEG' : read_jpeg, file, image

endcase

;- If an 8-bit image was read, reduce the number of colors

if info.channels eq 1 then begin
  reduce_colors, image, index
  r = r[index]
  g = g[index]
  b = b[index]
endif

;- Get image size

dims = size(image, /dimensions)
if n_elements(dims) eq 2 then begin
  nx = dims[0]
  ny = dims[1]
endif else begin
  nx = dims[1]
  ny = dims[2]
endelse

;-------------------------------------------------------------------------------
;- CREATE A WINDOW
;-------------------------------------------------------------------------------

;- Create a draw widget sized to fit the image

if not keyword_set(current) then begin

  ;- Set default window size

  scroll = 0
  xsize = nx
  ysize = ny
  draw_xsize = nx
  draw_ysize = ny

  ;- Adjust the window size if the image is too large

  device, get_screen_size=screen
  if nx gt (0.95 * screen[0]) then begin
    xsize = 0.85 * nx
    scroll = 1
  endif
  if ny gt (0.95 * screen[1]) then begin
    ysize = 0.85 * ny
    scroll = 1
  endif

  ;- Create the draw widget

  base = widget_base(title=file)
  draw = widget_draw(base, scroll=scroll)
  widget_control, draw, xsize=xsize, ysize=ysize, $
    draw_xsize=draw_xsize, draw_ysize=draw_ysize

endif

;-------------------------------------------------------------------------------
;- HANDLE IDL 8-BIT MODE
;-------------------------------------------------------------------------------

if depth eq 8 then begin

  ;- If the color table of an 8-bit image is larger than
  ;- the current display table, convert the image to 24-bit

  if (info.channels eq 1) and (n_elements(r) gt !d.table_size) then begin

    ;- Convert to 24-bit

    dims = size(image, /dimensions)
    nx = dims[0]
    ny = dims[1]
    true = bytarr(3, nx, ny)
    true[0, *, *] = r[image]
    true[1, *, *] = g[image]
    true[2, *, *] = b[image]
    image = temporary(true)

    ;- Reset the number of channels

    info.channels = 3

  endif

  ;- If image is 24-bit, convert to 8-bit

  if info.channels eq 3 then begin

    ;- Convert 24-bit image to 8-bit

    image = color_quan(image, 1, r, g, b, colors=!d.table_size, $
      dither=keyword_set(dither))

    ;- Sort the color table from darkest to brightest

    table_sum = total([[long(r)], [long(g)], [long(b)]], 2)
    table_index = sort(table_sum)
    image_index = sort(table_index)
    r = r[table_index]
    g = g[table_index]
    b = b[table_index]
    oldimage = image
    image[*] = image_index[temporary(oldimage)]

    ;- Reset the number of channels

    info.channels = 1

  endif

endif

;-------------------------------------------------------------------------------
;- DISPLAY THE IMAGE
;-------------------------------------------------------------------------------

;- Realize the draw widget

if not keyword_set(current) then widget_control, base, /realize

;- Save current decomposed mode and display order

device, get_decomposed=current_decomposed
current_order = !order

;- Set image to display from bottom up

!order = 0

;- Display the image

if info.channels eq 1 then begin

  device, decomposed=0
  tvlct, r, g, b
  tv, image

endif else begin

  device, decomposed=1
  tv, image, true=1

endelse

;- Restore decomposed mode and display order

device, decomposed=current_decomposed
!order = current_order

END
