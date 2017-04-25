function get_goes_defsat,start_time,stop_time, $
   check_sswdb=check_sswdb, online=online, string_return=string_return
;+
;   Name: get_goes_defsat
;
;   Purpose: return time dependent GOES satellite number
;
;   Input Parameters:
;       start_time - time or start time of range
;       stop_time - optional stop time (if range)
;
;   Output:
;      function returns time dependent GOES satellite number ("default")
;
;
;   Keyword Parameters:
;      check_sswdb - (switch) - if set, verify dbase is online
;      online (output) - boolean - 1 if dbase is available 
;      string_return - (switch) - if set, output is string Sat#
;      
;   History: 
;      16-Apr-2003 - S.L.Freeland rd_gxd/plot_goes helper 
;      18-Jun-2009 - (Aki Takeda) modified based on the best coverage
;                                 of the updated YDB/goes data base.
;      29-dec-2010 - (Aki T) added switching to GOES14.
;       3-feb-2011 - (Aki T) simplify the switching. 
;                            (limited to GOES 7,8,10,12,14)
;       7-feb-2011 - (Aki T) added GOES 15 switch. 
;
;-

retval=-1
stringit=keyword_set(string_return)

if n_elements(start_time) eq 0 then start_time=reltime(/now) ; default T=current UT

case n_params() of 
   2:       
   else: stop_time=start_time(0)
endcase
 
t0=anytim(start_time,/ecs)
t1=anytim(stop_time,/ecs)

; def9t= '1-jul-1996'              ; GOES 7 off
; def8t= '1-jul-1998'              ; GOES 9 defunct
; def10t='8-apr-2003'              ; GOES 8 off

def8t= '1-aug-1996'              ; GOES 8 start
def10t='20-oct-1998'             ; GOES 8  --> GEOS 10
def12t='1-jun-2006'              ; switch to GOES 12 
def10t2='1-apr-2007'             ; GOES12 --> GOES 10 
def14t='1-dec-2009'              ; switch to GOES 14 
def15t='31-oct-2010'             ; switch to GOES 15 
;
case 1 of 
   ssw_deltat(t1,ref=def15t)  ge 0: retval=15
   ssw_deltat(t1,ref=def14t)  ge 0: retval=14
   ssw_deltat(t1,ref=def10t2)  ge 0: retval=10
   ssw_deltat(t1,ref=def12t)  ge 0: retval=12
   ssw_deltat(t1,ref=def10t)  ge 0: retval=10
   ssw_deltat(t1,ref=def8t)  ge 0: retval=8
   else: retval=7
endcase
if stringit then retval=strtrim(retval,2)

return,retval
end

