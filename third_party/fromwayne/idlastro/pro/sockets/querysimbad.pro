PRO QuerySimbad, name, ra, de, id, Found = found
;+
; NAME: 
;   QUERYSIMBAD
;
; PURPOSE: 
;   Query the SIMBAD name resolver at the European Southern Observatory
;
; EXPLANATION: 
;   Uses the IDL SOCKET command to query the SIMBAD nameserver over the Web.    
;   Requires IDL V5.4 or later.
;
;   SIMBAD can resolve astronomical object names and return coordinates
;   in J2000.0. For details on the service, see 
;   http://simbad.u-strasbg.fr/Simbad .
;
; CALLING SEQUENCE: 
;    QuerySimbad, name, ra, dec, [ id, Found=]
;
; INPUTS: 
;    name - a scalar string containing the target name in SIMBAD
;           nomenclature. For details see
;           http://vizier.u-strasbg.fr/cgi-bin/Dic-Simbad .
;
; OUTPUTS: 
;     ra - the right ascension of the target in J2000.0 in *degrees* 
;     dec - declination of the target in degrees
;
; OPTIONAL OUTPUT: 
;     id - the primary SIMBAD ID of the target.
;
; OPTIONAL KEYWORD OUTPUT:
;     found - set to 1 if the translation was successful, or to 0 if the
;           the object name could not be translated by SIMBAD
;
; EXAMPLES:
;     (1) Find the J2000 coordinates for the ultracompact HII region
;         G45.45+0.06 
;
;      IDL> QuerySimbad,'GAL045.45+00.06', ra, dec
;      IDL> print, adstring(ra,dec,1)
;           ===>19 14 20.77  +11 09  3.6
; PROCEDURES USED:
;          WEBGET()
;
; MODIFICATION HISTORY: 
;     Written by M. Feldt, Heidelberg, Oct 2001   <mfeldt@mpia.de>
;     Minor updates, W. Landsman   August 2002
;
;-
  if N_params() LT 3 then begin
       print,'Syntax - QuerySimbad, name, ra, dec, [ id ]'
       print,'   Input - object name, scalar string'
       print,'   Output -  Ra, dec of object'
  endif
  ;;
  QueryURL = "http://archive.eso.org/skycat/servers/sim-server?&o=" + $
              strcompress(name,/remove)
  ;;
  Result = webget(QueryURL)
  found = 0
  ;;

  IF strmid(Result.Text[0], 0, 2) EQ 'Id' THEN BEGIN 
      found = 1
      ;;
      ;; prepare the result fields
      ;;
      ra = dblarr(N_Elements(Result.Text)-3)
      de =  ra
      id = strarr(N_Elements(Result.Text)-3) 
      ;;
      ;; decode the result
      ;;
      FOR ii=2, N_Elements(Result.Text)-2 DO BEGIN
          TheseFields = strsplit(Result.Text[ii], string(9B), /extract)
          id[ii-2] = TheseFields[0]
          ra[ii-2] = float(TheseFields[1])
          de[ii-2] = float(TheseFields[2])
      ENDFOR 
      ;;
      ;; ready for return
      ;;
      IF N_Elements(Result.Text) EQ 4 THEN BEGIN 
          ra = ra[0] ; do not return single-element arrays
          de = de[0]
          id = id[0]
      ENDIF 
      return
  ENDIF ELSE BEGIN 
      message, 'No objects returned by server. The server answered:', /info
      print, Result.Text
  ENDELSE 
END 
  
