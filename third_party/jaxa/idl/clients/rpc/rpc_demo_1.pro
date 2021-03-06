PRO RPC_DEMO_1, host, var_name, val, IDL_RPC_ID = idl_rpc_id, CONNECT_TIMEOUT = connect_timeout

; This is a demonstration program to show how to pass variables to and from a remote IDL session.
; The program takes three parameteres: the host to open the remote session on, the name of the
; variable to send to the host, and the value to set that variable to.  The program then creates the
; requested variable on the remote IDL session.  If this succeeds, it then reads back this variable
; and prints its value.

; First we create an IDL_RPC_CLIENT object.  There are two important keywords that can be
; included when we initialize the object.  The first important keyword  is 'IDL_RPC_CLIENT which
; specifies the ID of the rpc server that we wish to connect to.  If not set, then it will default
; to a value of 0x2010CAFE (which default ID for an IDL server).  The other important keyword is
; CONNECT_TIMEOUT which specifies the amount of time we should for a socket connection to be
; established.  The default value for this keyword is 5 seconds.

rpc = OBJ_NEW ('IDL_RPC_CLIENT', IDL_RPC_ID = idl_rpc_id, CONNECT_TIMEOUT = connect_timeout )

; Run the RPCInit method.  This method will usually be the first one that is called on the
; client object.  The important keyword here is HOSTNAME.  This specifies the hostname of
; remote IDL server.  It performs all the tasks necessary to set up communication with the
; remote server (including checking for the existence of the server itself).  Like all
; methods in the IDL_RPC_CLIENT object, this method will return 1 for success and 0 for
; failure.

; Some notes on using this method.  The remote host must not have port 111 blocked. This is
; because the RPC client object uses the port mapper on the remote to determine what port the
; the IDL RPC server is listening to.  Also, the timeout is currently set to 120 sec. so if
; something does go wrong, prepare for the client session to hang for a while.

IF NOT rpc->RPCInit (HOSTNAME = host) THEN RETURN

; The RPCSetVariable method copies the value passed as the keyword VAL to the remote IDL
; session and gives it the name passed as the keyword NAME.  The method returns the result
; of the operation, a 1 indicates success and a 0 indicates failure.  This method can transfer
; scalars and arrays (including arrays of strings) but not structures or objects.

status = rpc->RPCSetVariable (NAME = var_name, VAL = val)

; The RPCGetVariable method copies the variable with the name passed as the keyword NAME from
; the remote IDL session.  The actual value of that variable is returned as the keyword VAL.
; The method returns the result of the operation, a 1 indicates success and a 0 indicates failure.
; This method can transfer scalars and arrays (including arrays of strings) but not structures
; or objects.

status = rpc->RPCGetVariable (NAME = var_name, VAL = vl)

; If the previous method succeeded, print out the value of the variable that was returned.

IF status THEN PRINT, 'Returned Value of:', vl

; Time to finish up.  The RPCCleanup method closes a sesion with a remote server.  Mostly it
; just takes cares of housekeeping on the client side, but if it is passed a parameter that
; resolves to TRUE, then it will also cause the remote IDL server to exit.

print, rpc->RPCCleanup ()

; All done.  Get rid of the IDL RPC Client object and exit.

OBJ_DESTROY, rpc

RETURN

END