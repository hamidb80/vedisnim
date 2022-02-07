when compileOption "threads":
    {.emit: """
#ifndef VEDIS_ENABLE_THREADS
#define VEDIS_ENABLE_THREADS
#endif VEDIS_ENABLE_THREADS
""".}

{.compile: "../../lib/vedis.c".}
{.pragma: hdr, header: "../lib/vedis.h".}

const
  SXRET_OK = 0
  SXERR_MEM = -1
  SXERR_IO = -2
  SXERR_EMPTY = -3
  SXERR_LOCKED = -4
  # SXERR_ORANGE = -5
  SXERR_NOTFOUND = -6
  SXERR_LIMIT = -7
  # SXERR_MORE = -8
  SXERR_INVALID = -9
  SXERR_ABORT = -10
  SXERR_EXISTS = -11
  # SXERR_SYNTAX = -12
  SXERR_UNKNOWN = -13
  SXERR_BUSY = -14
  # SXERR_OVERFLOW = -15
  # SXERR_WILLBLOCK = -16
  SXERR_NOTIMPLEMENTED = -17
  SXERR_EOF = -18
  SXERR_PERM = -19
  SXERR_NOOP = -20
  # SXERR_FORMAT = -21
  # SXERR_NEXT = -22
  # SXERR_OS = -23
  SXERR_CORRUPT = -24
  # SXERR_CONTINUE = -25
  # SXERR_NOMATCH = -26
  # SXERR_RESET = -27
  SXERR_DONE = -28
  # SXERR_SHORT = -29
  # SXERR_PATH = -30
  # SXERR_TIMEOUT = -31
  # SXERR_BIG = -32
  # SXERR_RETRY = -33
  # SXERR_IGNORE = -63

type
  VedisDB {.importc: "struct vedis", hdr.} = object
  VedisValue {.importc: "struct vedis_value", hdr.} = object
  VedisCtx {.importc: "struct vedis_context", hdr.} = object

  VedisDBPtr* = ptr VedisDB
  VedisValuePtr* = ptr VedisValue
  VedisCtxPtr* = ptr VedisCtx

  Vi64* = clonglong

type
  VedisCodes* = enum
    vcOK = 0
    vcLOCKERR
    vcREAD_ONLY
    vcCANTOPEN
    vcFULL
    vcDONE
    vcCORRUPT
    vcNOOP
    vcPERM
    vcEOF
    vcNOTIMPLEMENTED
    vcBUSY
    vcUNKNOWN
    vcEXISTS
    vcABORT
    vcINVALID
    vcLIMIT
    vcNOTFOUND
    vcLOCKED
    vcEMPTY
    vcIOERR
    vcNOMEM

func toVedisErrorCode*(c: cint): VedisCodes =
    case c:
    of -76: vcLOCKERR 
    of -75: vcREAD_ONLY 
    of -74: vcCANTOPEN 
    of -73: vcFULL 
    of SXERR_DONE: vcDONE 
    of SXERR_CORRUPT: vcCORRUPT 
    of SXERR_NOOP: vcNOOP 
    of SXERR_PERM: vcPERM 
    of SXERR_EOF: vcEOF 
    of SXERR_NOTIMPLEMENTED: vcNOTIMPLEMENTED 
    of SXERR_BUSY: vcBUSY 
    of SXERR_UNKNOWN: vcUNKNOWN 
    of SXERR_EXISTS: vcEXISTS 
    of SXERR_ABORT: vcABORT 
    of SXERR_INVALID: vcINVALID 
    of SXERR_LIMIT: vcLIMIT 
    of SXERR_NOTFOUND: vcNOTFOUND 
    of SXERR_LOCKED: vcLOCKED 
    of SXERR_EMPTY: vcEMPTY 
    of SXERR_IO: vcIOERR 
    of SXERR_MEM: vcNOMEM 
    of SXRET_OK: vcOK 
    else:
        raise newException(ValueError, "invalid error code")



{.push importc, header: "../lib/vedis.h".}

## Vedis Datastore Handle
proc vedis_open*(vedis: var VedisDBPtr, path: cstring): cint
proc vedis_close*(vedis: VedisDBPtr): cint

## Command Execution Interfaces
proc vedis_exec*(vedis: VedisDBPtr, zCmd: cstring, nLen: int): cint
proc vedis_exec_result*(vedis: VedisDBPtr, value: var VedisValuePtr): cint

## Foreign Command Registar
proc vedis_register_command*(vedis: VedisDBPtr, zName: cstring, cmd: proc(
    ctx: VedisCtxPtr, err: cint, value: var VedisValuePtr): cint,
    pUserdata: pointer): cint
proc vedis_delete_command*(vedis: VedisDBPtr, zName: cstring): cint

# Raw Data Store/Fetch (http://vedis.org)
proc vedis_kv_store*(vedis: VedisDBPtr, pKey: cstring, nKeyLen: cint,
    pData: cstring, nDataLen: Vi64): cint
proc vedis_kv_append*(vedis: VedisDBPtr, pKey: cstring, nKeyLen: cint,
    pData: cstring, nDataLen: Vi64): cint
proc vedis_kv_fetch*(vedis: VedisDBPtr, pKey: cstring, nKeyLen: cint,
    pBuf: var cstring, pBufLen: var Vi64): cint
proc vedis_kv_fetch_callback*(vedis: VedisDBPtr, pKey: cstring,
                     nKeyLen: cint, xConsumer: proc(s: cstring, i: cuint,
                         bf: var cstring): cint, pUserData: ptr pointer): cint
proc vedis_kv_config*(vedis: VedisDBPtr, iOp: cint): cint {.varargs.}
proc vedis_kv_delete*(vedis: VedisDBPtr, pKey: cstring, nKeyLen: cint): cint

## Manual Transaction Manager
proc vedis_begin*(vedis: VedisDBPtr): cint
proc vedis_commit*(vedis: VedisDBPtr): cint
proc vedis_rollback*(vedis: VedisDBPtr): cint

# Call Context Key/Value Store Interfaces
proc vedis_context_kv_store*(ctx: VedisCtxPtr, pKey: cstring, nKeyLen: cint,
    pData: cstring, nDataLen: Vi64): cint
proc vedis_context_kv_append*(ctx: VedisCtxPtr, pKey: cstring, nKeyLen: cint,
    pData: cstring, nDataLen: Vi64): cint
proc vedis_context_kv_fetch*(ctx: VedisCtxPtr, pKey: cstring, nKeyLen: cint,
    pBuf: ptr pointer, pBufLen: Vi64): cint
proc vedis_context_kv_fetch_callback*(ctx: VedisCtxPtr, pKey: cstring,
                    nKeyLen: cint, xConsumer: proc(s: cstring, ilne: cuint,
                        bf: ptr pointer): cint, pUserData: ptr pointer): cuint
proc vedis_context_kv_delete*(ctx: VedisCtxPtr, pKey: cstring,
    nKeyLen: cint): cint

## Command Execution Context Interfaces
proc vedis_context_throw_error*(ctx: VedisCtxPtr, iErr: cint,
    err: cstring): cint
proc vedis_context_random_num*(ctx: VedisCtxPtr): cuint
proc vedis_context_random_string*(ctx: VedisCtxPtr, buf: var cstring,
    nBuflen: cint): cint
proc vedis_context_user_data*(ctx: VedisCtxPtr): pointer
proc vedis_context_push_aux_data*(ctx: VedisCtxPtr, pUserData: pointer): cint
proc vedis_context_peek_aux_data*(ctx: VedisCtxPtr): pointer
proc vedis_context_pop_aux_data*(ctx: VedisCtxPtr): pointer

## Setting The Return Value Of A Vedis Command
proc vedis_result_int*(ctx: VedisCtxPtr, iValue: cint): cint
proc vedis_result_int64*(ctx: VedisCtxPtr, iValue: Vi64): cint
proc vedis_result_bool*(ctx: VedisCtxPtr, iBool: cint): cint
proc vedis_result_double*(ctx: VedisCtxPtr, d: cdouble): cint
proc vedis_result_null*(ctx: VedisCtxPtr): cint
proc vedis_result_string*(ctx: VedisCtxPtr, str: cstring, nLen: cint): cint
proc vedis_result_value*(ctx: VedisCtxPtr, value: VedisValuePtr): cint

## Extracting Vedis Commands Parameter/Return Values
proc vedis_value_to_int*(value: VedisValuePtr): cint
proc vedis_value_to_bool*(value: VedisValuePtr): cint
proc vedis_value_to_int64*(value: VedisValuePtr): Vi64
proc vedis_value_to_double*(value: VedisValuePtr): cdouble
proc vedis_value_to_string*(value: VedisValuePtr, len: var cint): cstring

## Dynamically Typed Value Object Query Interfaces
proc vedis_value_is_int*(value: VedisValuePtr): cint
proc vedis_value_is_float*(value: VedisValuePtr): cint
proc vedis_value_is_bool*(value: VedisValuePtr): cint
proc vedis_value_is_string*(value: VedisValuePtr): cint
proc vedis_value_is_null*(value: VedisValuePtr): cint
proc vedis_value_is_numeric*(value: VedisValuePtr): cint
proc vedis_value_is_scalar*(value: VedisValuePtr): cint
proc vedis_value_is_array*(value: VedisValuePtr): cint

## Populating dynamically Typed Objects
proc vedis_value_int*(val: VedisValuePtr, i: cint): cint
proc vedis_value_int64*(val: VedisValuePtr, i: Vi64): cint
proc vedis_value_bool*(val: VedisValuePtr, b: cint): cint
proc vedis_value_null*(val: VedisValuePtr): cint
proc vedis_value_double*(val: VedisValuePtr, d: cdouble): cint
proc vedis_value_string*(val: VedisValuePtr, str: cstring, nLen: cint): cint
proc vedis_value_reset_string_cursor*(val: VedisValuePtr): cint
proc vedis_value_release*(val: VedisValuePtr): cint

## On-demand Object Value Allocation
proc vedis_context_new_scalar*(ctx: VedisCtxPtr): VedisValuePtr
proc vedis_context_new_array*(ctx: VedisCtxPtr): VedisValuePtr
proc vedis_context_release_value*(ctx: VedisCtxPtr, value: VedisValuePtr)

## Working with Vedis Arrays
proc vedis_array_fetch*(varr: VedisValuePtr, index: cuint): VedisValuePtr
proc vedis_array_insert*(varr: VedisValuePtr, value: VedisValuePtr): cint
proc vedis_array_count*(varr: VedisValuePtr): cuint
proc vedis_array_reset*(varr: VedisValuePtr): cint
proc vedis_array_next_elem*(varr: VedisValuePtr): VedisValuePtr

## Global Library Management Interfaces
proc vedis_lib_init*(): cint
proc vedis_lib_config*(nConfigOp: cint): cint {.varargs.}
proc vedis_lib_shutdown*(): cint
proc vedis_lib_is_threadsafe*(): cint
proc vedis_lib_version*(): cstring
proc vedis_lib_signature*(): cstring
proc vedis_lib_ident*(): cstring
proc vedis_lib_copyright*(): cstring

{.pop.}
