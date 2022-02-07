import vedisnim/[high_level, low_level]

const MAX_RECORDS = 100

let vdb = initVedis "vedis.db"

echo "Starting insertions of random records"

try:
  for i in 1 .. MAX_RECORDS:
    echo i
    isOk vdb.vedis_kv_store("hamid", 5, "ffad", "ffad".len)

    if i == 12:
      isOk vdb.vedis_kv_store("sentinel", 8, "I'm", 3)

  echo "Done...Fetching the 'sentinel' record: "

  # TODO: ...

  var
    ln = 40
    buff = newStringOfCap(40)

  # echo vdb.vedis_kv_fetch("sentinel", 8 , addr buff[0], ln)
  echo vdb.execAndGet "GET sentinel"
  vdb.close

except VedisError:
  let err = (VedisError)getCurrentException()

  echo "+++++++++++++++++"
  echo err.reason
  echo "-----------------"
