function ssw_whereis_perl, default=default, status=status
;
;+
;   Name: ssw_whereis_perl
;
;   Purpose: return path to perl on this system
;
;   Calling Sequence:
;      perlpath=ssw_whereis_perl
;
;   Keyword Parameters:
;      default (switch) - if set, return 'SSW default' but dont verify
;      (for use in caller via "if ssw_whereis_perl() ne  ssw_whereis_perl(/default) then ..."
;      status - 1 if returned path to perl is valid on system (ie, exists)
;
;   Motiviation:
;      ssw_upgrade helper function - in case perl is not in the place "expected"
;         by the default Mirror.pl script historically /usr/local/bin/perl
;
;-
;
;
defperl='/usr/local/bin/perl'  ; historical default
if keyword_set(default) then return,defperl ; !unstructured exit!
 
chkdef=where(file_exist(defperl),dcnt)
retval=''
if dcnt gt 0 then retval=defperl else begin 
   others=['/usr/bin/perl'] ; common other locations...
   ssexist=where(file_exist(others),ecnt)
   if ecnt gt 0 then retval=others(ssexist(0)) else begin 
      spawn,['whereis','perl'],out,/noshell 
      if file_exist(out(0)) then retval=out(0) else status=0
   endelse
endelse

status=file_exist(retval)
return,retval
end

;
;

 
