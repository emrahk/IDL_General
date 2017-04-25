function ssw_helio2string, helio, string2helio=string2helio
;
;   Name: ssw_helio2string
;
;   Purpose: convert 'arcmin2hel' style output to string {N/S}xx{E/W}
;
;   Input Parameters:
;      helio - 2 element array equivilent to 'arcmin2hel' output
;              [-or- if, /STRING2HELIO, string of form 'N15E45'
;
;    Output:
;       function returns string of form N15E45 
;          [-or- if, /STRING2HELIO, conver string -> [ns,ew] per arcmin2hel
;
;   Keyword Parameters
;      string2helio - (switch) - if set, reverse sense of conversion
;
;-
retval=''
case 1 of 
   n_params() eq 0: begin 
   box_message,['Need 2 element heliographic as returned from arcmin2hel',$
                '-OR-',$
                'String input such as { N03E20 , S15W90... }']
   endcase
   n_params() eq 1 and data_chk(helio,/string): begin 
     uhelio=strupcase(helio)
     nsp=max([strpos(uhelio,'N'),strpos(uhelio,'S')])
     ewp=max([strpos(uhelio,'E'),strpos(uhelio,'W')])
     ns=float(strmid(uhelio,nsp+1,2))*([1,-1])(strmid(uhelio,nsp,1) eq 'S')
     ew=float(strmid(uhelio,ewp+1,2))*([1,-1])(strmid(uhelio,ewp,1) eq 'E')
     retval=round([ns,ew])
   endcase
   n_elements(helio) eq 2: begin 
    fhns=helio(0) & fhew=helio(1)
    retval=$
                (['S','N'])(fhns gt 0)+ string(abs(fhns),format='(i2.2)') + $
                (['E','W'])(fhew gt 0)+ string(abs(fhew),format='(i2.2)')
   endcase
   else: box_message,'Incorrect input type'''
endcase

return,retval
end
