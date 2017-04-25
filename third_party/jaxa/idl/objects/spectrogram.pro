;---------------------------------------------------------------------------
; Document name: spectrogram.pro
; Time-stamp: <Wed Jul 21 2004 12:54:58 csillag Andre-Csillaghys-Computer.local>
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI/PHOENIX
;
; NAME:
;       SPECTROGRAM()
;
; PURPOSE:
;       Constructor for the spectrogram object.
;
; CATEGORY:
;       Generic utilities
;
; CALLING SEQUENCE:
;       o = spectrogram( spectrogram [, time_axis, energy_axis] ) or
;       o = spectrogram( spectrogram_struct )
;
; INPUTS:
;       spectrogram: a 2d array containing the time/energy values
;       time_axis: the time axis associated with the spectrogram. 
;                  a 1 d vector with same # of elements as the x-axis
;                  of the spectrogram. the time is referenced to 1-jan-79
;                  (anytim format)
;       spectrum_axis: the spectrum axis associated with the spectrogram. 
;                  a 1 d vector with same # of elements as the y-axis
;                  of the spectrogram
;       spectrogram_struct: a spectrogram structure with tags:
;                           {spectrogram, time_axis, spectrum_axis}
;
; OUTPUTS:
;       o: a spectrogram object
;
; EXAMPLES:
;
;
; SEE ALSO:
;       more information in spectrogram__define
;       http://hessi.ssl.berkeley.edu/~csillag/idl/spectrogram_howto.html
;
; HISTORY:
;       20-jul-2004: documentation update
;       Version 1, August 21, 2003,
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;-
;

FUNCTION spectrogram, image, time_axis, energy_axis, _ref_extra = extra

return, make_spectrogram( image, time_axis, energy_axis, _extra = extra )

end


;---------------------------------------------------------------------------
; End of 'spectrogram.pro'.
;---------------------------------------------------------------------------
