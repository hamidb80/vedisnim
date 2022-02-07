  import ./low_level

using
  v: VedisDBPtr
  val: VedisValuePtr

type VedisError* = ref object of CatchableError
  reason*: VedisCodes

template isOk*(vedisResult: cint): untyped =
  if (let res = vedisResult; res != vcOk.int):
    raise VedisError(reason: res.toVedisErrorCode)

# TODO: allocations ... `=destroy`

proc initVedis*(path: string): VedisDBPtr =
  isOK vedis_open(result, path)

proc close*(v) =
  isOk vedis_close(v)

proc exec*(v; cmd: string) =
  isOk vedis_exec(v, cmd, -1)

proc getResult*(v): VedisValuePtr =
  isOk vedis_exec_result(v, result)

proc execAndGet*(v; cmd: string): VedisValuePtr =
  exec(v, cmd)
  getResult(v)

template transaction*(v, code): untyped =
  isOk vedis_begin v
  try:
    code
    isOk vedis_commit v
  except:
    isOk vedis_rollback v

# value ------------------------

type
  VedisValueTypes* = enum
    vvNull, vvArr
    vvInt, vvFloat, vvBool, vvStr,

proc isInt*(val): bool =
  vedis_value_is_int(val) == 1

proc isFloat*(val): bool =
  vedis_value_is_float(val) == 1

proc isBool*(val): bool =
  vedis_value_is_bool(val) == 1

proc isString*(val): bool =
  vedis_value_is_string(val) == 1

proc isNull*(val): bool =
  vedis_value_is_null(val) == 1

proc isNumeric*(val): bool =
  vedis_value_is_numeric(val) == 1

proc isScalar*(val): bool =
  vedis_value_is_scalar(val) == 1

proc isArray*(val): bool =
  vedis_value_is_array(val) == 1


proc getBool*(val): bool = 
  vedis_value_to_bool(val) == 1

proc getInt32*(val): int32 = 
  vedis_value_to_int(val)

proc getInt64*(val): int64 = 
  vedis_value_to_int64(val)

proc getFloat*(val): float64 = 
  vedis_value_to_double(val)

proc getString*(val; len = 0): cstring = 
  var i = len.cint
  vedis_value_to_string(val, i)

proc getType*(val): VedisValueTypes =
  if val.isNull: vvNull
  elif val.isBool: vvBool
  elif val.isInt: vvInt
  elif val.isFloat: vvFloat
  elif val.isString: vvStr
  elif val.isArray: vvArr
  else:
    raise newException(ValueError, "unexpected value type")


proc len*(val): int =
  assert val.isArray
  vedis_array_count(val).int

proc add*(val; item : VedisValuePtr) =
  assert val.isArray
  isOK val.vedis_array_insert item

proc `[]`*(val; index: int): VedisValuePtr =
  assert val.isArray
  vedis_array_fetch(val, cuint index)

iterator items*(val): VedisValuePtr =
  assert val.isArray

  while (let item = vedis_array_next_elem(val); item != nil):
    yield item

iterator pairs*(val): tuple[index: int, value: VedisValuePtr] =
  assert val.isArray

  var i = 0
  for v in val:
    yield (i, v)
    inc i

iterator hpairs*(val): tuple[k,v:VedisValuePtr] =
  let size = val.len
  assert size mod 2 == 0

  for i in countup(0, size - 1, 2):
    yield (vedis_array_next_elem(val), vedis_array_next_elem(val))

proc `$`*(val): string =
  $ getString val
