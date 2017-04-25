FUNCTION rpc_constants::get_constants

struct = {RPC_MSG_VERSION:   self.RPC_MSG_VERSION,   $
          CALL:              self.CALL,              $
          REPLY:             self.REPLY,             $
          MSG_ACCEPTED:      self.MSG_ACCEPTED,      $
          MSG_DENIED:        self.MSG_DENIED,        $
          SUCCESS:           self.SUCCESS,           $
          PROG_UNAVAIL:      self.PROG_UNAVAIL,      $
          PROG_MISMATCH:     self.PROG_MISMATCH,     $
          PROC_UNAVAIL:      self.PROC_UNAVAIL,      $
          GARBAGE_ARGS:      self.GARBAGE_ARGS,      $
          RPC_MISMATCH:      self.RPC_MISMATCH,      $
          AUTH_ERROR:        self.AUTH_ERROR,        $
          AUTH_NULL:         self.AUTH_NULL,         $
          AUTH_UNIX:         self.AUTH_UNIX,         $
          AUTH_SHORT:        self.AUTH_SHORT,        $
          AUTH_DES:          self.AUTH_DES,          $
          AUTH_BADCRED:      self.AUTH_BADCRED,      $
          AUTH_REJECTEDCRED: self.AUTH_REJECTEDCRED, $
          AUTH_BADVERF:      self.AUTH_BADVERF,      $
          AUTH_REJECTEDVERF: self.AUTH_REJECTEDVERF, $
          AUTH_TOOWEAK:      self.AUTH_TOOWEAK,      $
          IPPROTO_TCP:       self.IPPROTO_TCP,       $
          IPPROTO_UDP:       self.IPPROTO_UDP,       $
          PMAP_PROG:         self.PMAP_PROG,         $
          PMAP_VERS:         self.PMAP_VERS,         $
          PMAPPROC_NULL:     self.PMAPPROC_NULL,     $
          PMAPPROC_SET:      self.PMAPPROC_SET,      $
          PMAPPROC_UNSET:    self.PMAPPROC_UNSET,    $
          PMAPPROC_GETPORT:  self.PMAPPROC_GETPORT,  $
          PMAPPROC_DUMP:     self.PMAPPROC_DUMP,     $
          PMAPPROC_CALLIT:   self.PMAPPROC_CALLIT,   $
          XDR_ENCODE:        self.XDR_ENCODE,        $
          XDR_DECODE:        self.XDR_DECODE,        $
          IDL_NULL:          self.IDL_NULL,          $
          IDL_BYTE:          self.IDL_BYTE,          $
          IDL_INT:           self.IDL_INT,           $
          IDL_LONG:          self.IDL_LONG,          $
          IDL_FLOAT:         self.IDL_FLOAT,         $
          IDL_DOUBLE:        self.IDL_DOUBLE,        $
          IDL_COMPLEX:       self.IDL_COMPLEX,       $
          IDL_STRING:        self.IDL_STRING,        $
          IDL_STRUCT:        self.IDL_STRUCT,        $
          IDL_DCOMPLEX:      self.IDL_DCOMPLEX,      $
          IDL_POINTER:       self.IDL_POINTER,       $
          IDL_OBJREF:        self.IDL_OBJREF,        $
          IDL_UINT:          self.IDL_UINT,          $
          IDL_ULONG:         self.IDL_ULONG,         $
          IDL_LONG64:        self.IDL_LONG64,        $
          IDL_ULONG64:       self.IDL_ULONG64,       $
          RPC_RECORD:        self.RPC_RECORD         $
          }


RETURN, struct

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_constants::init

; RPC Version (Should Always Be 2)

    self.RPC_MSG_VERSION = 2

; msg_type

    self.CALL  = 0
    self.REPLY = 1

; A reply to a call message can take on two forms:
; The message was either accepted or rejected.

    self.MSG_ACCEPTED = 0
    self.MSG_DENIED   = 1

; Given that a call message was accepted, the following is the
; status of an attempt to call a remote procedure.

    self.SUCCESS       = 0 ; RPC executed successfully
    self.PROG_UNAVAIL  = 1 ; remote hasn't exported program
    self.PROG_MISMATCH = 2 ; remote can't support version #
    self.PROC_UNAVAIL  = 3 ; program can't support procedure
    self.GARBAGE_ARGS  = 4 ; procedure can't decode params

; Reasons why a call message was rejected:

    self.RPC_MISMATCH = 0  ; RPC version number != 2
    self.AUTH_ERROR = 1    ; remote can't authenticate caller

; Types (flavors) of authentication:

    self.AUTH_NULL       = 0
    self.AUTH_UNIX       = 1
    self.AUTH_SHORT      = 2
    self.AUTH_DES        = 3

; Why authentication failed:

    self.AUTH_BADCRED      = 1  ; bad credentials (seal broken)
    self.AUTH_REJECTEDCRED = 2  ; client must begin new session
    self.AUTH_BADVERF      = 3  ; bad verifier (seal broken)
    self.AUTH_REJECTEDVERF = 4  ; verifier expired or replayed
    self.AUTH_TOOWEAK      = 5  ; rejected for security reasons

; Transport Protocols:

    self.IPPROTO_TCP = 6        ; protocol number for TCP/IP
    self.IPPROTO_UDP = 17       ; protocol number for UDP/IP

; Portmapper Program Address and Version

    self.PMAP_PROG        = 100000L
    self.PMAP_VERS        = 2


; Portmapper Procedure Numbers:

    self.PMAPPROC_NULL    = 0
    self.PMAPPROC_SET     = 1
    self.PMAPPROC_UNSET   = 2
    self.PMAPPROC_GETPORT = 3
    self.PMAPPROC_DUMP    = 4
    self.PMAPPROC_CALLIT  = 5

; XDR Encode and Decode (Not Really Part Of RPC)

    self.XDR_ENCODE = 1
    self.XDR_DECODE = 0

; IDL Data Types

    self.IDL_NULL         = 0
    self.IDL_BYTE         = 1
    self.IDL_INT          = 2
    self.IDL_LONG         = 3
    self.IDL_FLOAT        = 4
    self.IDL_DOUBLE       = 5
    self.IDL_COMPLEX      = 6
    self.IDL_STRING       = 7
    self.IDL_STRUCT       = 8
    self.IDL_DCOMPLEX     = 9
    self.IDL_POINTER      = 10
    self.IDL_OBJREF       = 11
    self.IDL_UINT         = 12
    self.IDL_ULONG        = 13
    self.IDL_LONG64       = 14
    self.IDL_ULONG64      = 15
    self.RPC_RECORD       = 16

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_constants::cleanup

RETURN

END

; ------------------------------------------------------------------------------------------------


PRO rpc_constants__define

struct = {RPC_CONSTANTS,           $
          RPC_MSG_VERSION:   0L,   $
          CALL:              0L,   $
          REPLY:             0L,   $
          MSG_ACCEPTED:      0L,   $
          MSG_DENIED:        0L,   $
          SUCCESS:           0L,   $ ; RPC executed successfully
          PROG_UNAVAIL:      0L,   $ ; remote hasn't exported program
          PROG_MISMATCH:     0L,   $ ; remote can't support version #
          PROC_UNAVAIL:      0L,   $ ; program can't support procedure
          GARBAGE_ARGS:      0L,   $ ; procedure can't decode params
          RPC_MISMATCH:      0L,   $ ; RPC version number != 2
          AUTH_ERROR:        0L,   $ ; remote can't authenticate caller
          AUTH_NULL:         0L,   $
          AUTH_UNIX:         0L,   $
          AUTH_SHORT:        0L,   $
          AUTH_DES:          0L,   $
          AUTH_BADCRED:      0L,   $  ; bad credentials (seal broken)
          AUTH_REJECTEDCRED: 0L,   $  ; client must begin new session
          AUTH_BADVERF:      0L,   $  ; bad verifier (seal broken)
          AUTH_REJECTEDVERF: 0L,   $  ; verifier expired or replayed
          AUTH_TOOWEAK:      0L,   $  ; rejected for security reasons
          IPPROTO_TCP:       0L,   $  ; protocol number for TCP/IP
          IPPROTO_UDP:       0L,   $  ; protocol number for UDP/IP
          PMAP_PROG:         0L,   $
          PMAP_VERS:         0L,   $
          PMAPPROC_NULL:     0L,   $
          PMAPPROC_SET:      0L,   $
          PMAPPROC_UNSET:    0L,   $
          PMAPPROC_GETPORT:  0L,   $
          PMAPPROC_DUMP:     0L,   $
          PMAPPROC_CALLIT:   0L,   $
          IDL_NULL:          0L,   $
          IDL_BYTE:          0L,   $
          IDL_INT:           0L,   $
          IDL_LONG:          0L,   $
          IDL_FLOAT:         0L,   $
          IDL_DOUBLE:        0L,   $
          IDL_COMPLEX:       0L,   $
          IDL_STRING:        0L,   $
          IDL_STRUCT:        0L,   $
          IDL_DCOMPLEX:      0L,   $
          IDL_POINTER:       0L,   $
          IDL_OBJREF:        0L,   $
          IDL_UINT:          0L,   $
          IDL_ULONG:         0L,   $
          IDL_LONG64:        0L,   $
          IDL_ULONG64:       0L,   $
          RPC_RECORD:        0L,   $
          XDR_ENCODE:        0L,   $
          XDR_DECODE:        0L    $
          }


RETURN

END

; ------------------------------------------------------------------------------------------------
