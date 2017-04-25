; csillag@fh-aargau.ch
; Time-stamp: <Mon Feb 07 2005 12:16:21 csillag tournesol.local>
;---------------------------------------------------------------------------

pro struct2spectrogram, struct, spectrogram, time_axis, spectrum_axis, verbose  = verbose

; here is the mapper between strcuture already available around and the spectrogram object.
; This mapper can be expanded as needed.  It needs to return a structure
; {spectrogram, time_axis, spectrume_axis}
; time_axis must be in antyim format

checkvar, verbose, 0b

; attempt to guess if it's a tplot structure; if it's a tplot one, then
; convert the tplot time to anytim
; hope nobody will ever want to do another struct wit x,y,v tags.... it might
; be a little bit risky but in this context it should be safe

IF have_tag( struct, 'x' ) AND have_tag( struct, 'y' ) THEN BEGIN
; this is the phoenix spectrogram structure
      IF have_tag( struct, 'spectrogram' ) THEN BEGIN
            if verbose then Message, 'phoenix structure recognized', /info
            spectrogram =  struct.spectrogram
            time_axis= struct.x
            spectrum_axis= struct.y
      ENDIF ELSE BEGIN
; if only x and y, with optionally v, we assume i'ts a tplot structure; we convert the time to anytim.
            if verbose then Message, 'tplot structure recognized, time is converted to anytim', /info
            spectrogram = struct.y
            time_axis = tplot2any( struct.x )
            IF have_tag( struct, 'v' ) THEN BEGIN
                spectrum_axis=struct.v
            ENDIF ELSE BEGIN
                spectrum_axis=lindgen(n_elements(struct.y[0, *]))
            ENDELSE
        ENDELSE
ENDIF else if not have_tag( 'struct', spectrogram ) then begin
    message, 'unrecognized structure passed', /cont
    spectrogram = -1
    time_axis = -1
    spectrum_axis = -1
    endif else begin
        spectrogram = struct.spectrogram
        time_axis = struct.time_axis
        spectrum_axis = struct.spectrum_axis
        endelse
end
