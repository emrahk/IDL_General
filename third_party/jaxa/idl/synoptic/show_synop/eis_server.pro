;+                                                                             >
; Project     : Solar-B/EIS                                                    >
;                                                                              >
; Name        : EIS_SERVER                                                     >
;                                                                              >
; Purpose     : return URL and path to EIS FITS data server
;                                                                              >
; Category    : sockets                                                        >
;                                                                              >
; Inputs      : None                                                           >
;                                                                              >
; Outputs     : SERVER = EIS server name                                       >
;
; Keywords    : NETWORK = 1 if network is up
;               PATH = path to data                                            >
;               NO_CHECK = return server without checking network status
;                                                                              >
; History     : 1-June-2006,  D.M. Zarro (L-3Com/GSFC), Written                 >
;                                                                              >
; Contact     : DZARRO@SOLAR.STANFORD.EDU                                      >
;-                                                                                         
                                                                                           
    function eis_server,_ref_extra=extra,network=network,$                                 
          no_check=no_check,path=path,full=full                                                                
                                                                                           
    check=1b-keyword_set(no_check)                                                         
    network=0b                                                                             
    url='umbra.nascom.nasa.gov'
    path='/hinode/eis/level0'
    if check then network=have_network(url,_extra=extra) else network=1b                 
    
    if keyword_set(full) then url='http://'+url
                                                                                       
    return,url
    end                                                                                        





