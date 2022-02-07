import std/os
import vedisnim

# TODO add docs with examples
# TODO add transaction

when isMainModule:
  var vdb = initVedis "vedis.db"
  vdb.exec "SET name 'hamid'"
  vdb.exec "SET age 20"
  vdb.exec "HMSET myhash file \"you're.png\" size 1390000 modified 19888898"

  echo vdb.execAndGet "GET test"

  for v in vdb.execAndGet "MGET name age":
    echo v

  echo "------------"
  for k, v in vdb.execAndGet("HGETALL myhash").hpairs:
    echo k, ": ", v

  echo "------------"
  echo vdb.execAndGet "HGETALL myhash"


  vdb.close
  removeFile "vedis.db"

